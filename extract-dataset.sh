#!/bin/bash
# Meteorological Data Processing Workflow
# Copyright (C) 2022, University of Saskatchewan
# Copyright (C) 2023, University of Calgary
#
# This file is part of Meteorological Data Processing Workflow
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# =========================
# Credits and contributions
# =========================
# 1) Parts of the code are taken from https://www.shellscript.sh/tips/getopt/index.html
# 2) Parts of the code are taken from https://stackoverflow.com/a/17557904/5188208


# ================
# General comments
# ================
# 1) All variables are camelCased;


# ==============
# Help functions
# ==============
usage () {
  echo "Meteorological Data Processing Script

Usage:
  $(basename $0) [options...]

Script options:
  -d, --dataset				Meteorological forcing dataset of interest
                                        currently available options are:
  -i, --dataset-dir=DIR			The source path of the dataset file(s)
  -v, --variable=var1[,var2[...]]	Variables to process
  -o, --output-dir=DIR			Writes processed files to DIR
  -s, --start-date=DATE			The start date of the data
  -e, --end-date=DATE			The end date of the data
  -l, --lat-lims=REAL,REAL		Latitude's upper and lower bounds
  -n, --lon-lims=REAL,REAL		Longitude's upper and lower bounds
  -a, --shape-file=PATH			Path to the ESRI shapefile; optional
  -m, --ensemble=ens1,[ens2[...]]	Ensemble members to process; optional
  					Leave empty to extract all ensemble members
  -j, --submit-job			Submit the data extraction process as a job
					on the SLURM system; optional
  -k, --no-chunk			No parallelization, recommended for small domains
  -p, --prefix=STR			Prefix  prepended to the output files
  -b, --parsable			Parsable SLURM message mainly used
					for chained job submissions
  -c, --cache=DIR			Path of the cache directory; optional
  -E, --email=user@example.com		E-mail user when job starts, ends, and finishes; optional
  -V, --version				Show version
  -h, --help				Show this screen and exit


Currently, the following meteorological datasets are
available for processing:

  1.  NCAR-GWF WRF CONUS I (DOI: 10.1007/s00382-016-3327-9)
  2.  NCAR-GWF WRF CONUS II (DOI: 10.5065/49SN-8E08)
  3.  ECMWF ERA5 (DOI: 10.24381/cds.adbb2d47)
  4.  ECCC RDRSv2.1 (DOI: 10.5194/hess-25-4917-2021)
  5.  CCRN CanRCM4-WFDEI-GEM-CaPA (DOI: 10.5194/essd-12-629-2020)
  6.  WFDEI-GEM-CaPA (DOI: 10.20383/101.0111)
  7.  ORNL Daymet (DOI: 10.3334/ORNLDAAC/2129)
  8.  BCC-CSM2-MR (DOI: TBD)
  9.  CNRM-CM6-1 (DOI: TBD)
  10. EC-Earth3-Veg (DOI: TBD)
  11. GFDL-CM4 (DOI: TBD)
  12. GFDL-ESM4 (DOI: TBD)
  13. IPSL-CM6A-LR (DOI: TBD)
  14. MRI-ESM2-0 (DOI: TBD)
  15. Hybrid-observation (DOI: 10.5194/hess-23-5151-2019)

For bug reports, questions, discussions open an issue
at https://github.com/kasra-keshavarz/datatool/issues" >&1;

  exit 0;
}

short_usage () {
  echo "usage: $(basename $0) [-jh] [-i DIR] [-d DATASET] [-co DIR] [-se DATE] [-ln REAL,REAL] [-p STR]" >&1;
}

version () {
  echo "$(basename $0): version $(cat $(dirname $0)/VERSION)";
  exit 0;
}


# =====================
# Necessary Assumptions
# =====================
# TZ to be set to UTC to avoid invalid dates due to Daylight Saving
alias date='TZ=UTC date'

# expand aliases for the one stated above
shopt -s expand_aliases


# =======================
# Parsing input arguments
# =======================
# argument parsing using getopt - WORKS ONLY ON LINUX BY DEFAULT
parsedArguments=$(getopt -a -n extract-dataset -o jhVbE:d:i:v:o:s:e:t:l:n:p:c:m:ka: --long submit-job,help,version,parsable,email:,dataset:,dataset-dir:,variable:,output-dir:,start-date:,end-date:,time-scale:,lat-lims:,lon-lims:,prefix:,cache:,ensemble:,no-chunk,shape-file: -- "$@")
validArguments=$?
# check if there is no valid options
if [ "$validArguments" != "0" ]; then
  short_usage;
  exit 1;
fi

# check if no options were passed
if [ $# -eq 0 ]; then
  short_usage;
  exit 1;
fi

# check long and short options passed
eval set -- "$parsedArguments"
while :
do
  case "$1" in
    -h | --help)          usage                ; shift   ;; # optional
    -V | --version)	  version	       ; shift   ;; # optional
    -j | --submit-job)    jobSubmission=true   ; shift   ;; # optional
    -E | --email)	  email="$2"	       ; shift 2 ;; # optional
    -i | --dataset-dir)   datasetDir="$2"      ; shift 2 ;; # required
    -d | --dataset)       dataset="$2"         ; shift 2 ;; # required
    -v | --variable)	  variables="$2"       ; shift 2 ;; # required
    -o | --output-dir)    outputDir="$2"       ; shift 2 ;; # required
    -s | --start-date)    startDate="$2"       ; shift 2 ;; # required
    -e | --end-date)      endDate="$2"         ; shift 2 ;; # required
    -t | --time-scale)    timeScale="$2"       ; shift 2 ;; # required
    -l | --lat-lims)      latLims="$2"         ; shift 2 ;; # required
    -n | --lon-lims)      lonLims="$2"         ; shift 2 ;; # required
    -m | --ensemble)      ensemble="$2"        ; shift 2 ;; # optional
    -k | --no-chunk)      parallel=false       ; shift   ;; # optional
    -p | --prefix)	  prefixStr="$2"       ; shift 2 ;; # required
    -b | --parsable)	  parsable=true	       ; shift   ;; # optional
    -c | --cache)	  cache="$2"	       ; shift 2 ;; # optional
    -a | --shape-file)    shapefile="$2"       ; shift 2 ;; # optional

    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;

    # in case of invalid option
    *) echo "$(basename $0): invalid option '$1'" >$2;
       short_usage;
       exit 1;;
  esac
done

# default value for timeScale if not provided as an argument
if [[ -z $timeScale ]]; then
  timeScale="M"
fi

# default value for cache path if not provided as an argument
if [[ -z $cache ]] && [[ -n $jobSubmission ]]; then
  cache="$HOME/scratch/.temp_data_jobid"
elif [[ -z $cache ]]; then
  cache="$HOME/scratch/.temp_data_$(date +"%N")"
fi

# default value for parallelization
if [[ -z $parallel ]]; then
  parallel=true
fi

# email withought job submission not allowed
if [[ -n $email ]] && [[ -z $jobSubmission ]]; then
  echo "$(basename $0): ERROR! Email is not supported wihtout job submission;"
  exit 1;
fi

# parsable without job submission not allowed
if [[ $parsable==true ]] && [[ -z $jobSubmission ]]; then
  echo "$(basename $0): ERROR! --parsable argument cannot be used without job submission"
  exit 1;
fi

# if parsable argument is provided
if [[ -n $parsable ]]; then
  parsable="--parsable"
else
  parsable=""
fi

# if shapefile is provided extract the extents from it
if [[ -n $shapefile ]]; then
  # load GDAL module
  module -q load gdal;
  # extract the shapefile extent
  IFS=' ' read -ra shapefileExtents <<< "$(ogrinfo -so -al "$shapefile" | sed 's/[),(]//g' | grep Extent)"
  # transform the extents in case they are not in EPSG:4326
  IFS=':' read -ra sourceProj4 <<< "$(gdalsrsinfo $shapefile | grep -e "PROJ.4")" # source Proj4 value
  # transform limits and assing to variables
  IFS=' ' read -ra leftBottomLims <<< $(echo "${shapefileExtents[@]:1:2}" | gdaltransform -s_srs "${sourceProj4[1]}" -t_srs EPSG:4326 -output_xy)
  IFS=' ' read -ra rightTopLims <<< $(echo "${shapefileExtents[@]:4:5}" | gdaltransform -s_srs "${sourceProj4[1]}" -t_srs EPSG:4326 -output_xy)
  # define $latLims and $lonLims from $shapefileExtents
  lonLims="${leftBottomLims[0]},${rightTopLims[0]}"
  latLims="${leftBottomLims[1]},${rightTopLims[1]}"
  module -q unload gdal;
fi

# check mandatory arguments whether provided
if [[ -z "${datasetDir}" ]] || \
   [[ -z "${dataset}"    ]] || \
   [[ -z "${variables}"  ]] || \
   [[ -z "${outputDir}"  ]] || \
   [[ -z "${startDate}"  ]] || \
   [[ -z "${endDate}"    ]] || \
   [[ -z "${latLims}"    ]] || \
   [[ -z "${lonLims}"    ]] || \
   [[ -z "${prefixStr}"  ]]; then

   echo "$(basename $0): mandatory option(s) missing.";
   short_usage;
   exit 1;
fi


# ===========================
# Quasi-parallel requirements
# ===========================
# necessary arrays
startDateArr=() # start dates array
endDateArr=()   # end dates array

# necessary one-liner functions
unix_epoch () { date --date="$@" +"%s"; } # unix EPOCH date value 
format_date () { date --date="$1" +"$2"; } # format date

# default date format
dateFormat="%Y-%m-%d %H:%M:%S"


#######################################
# Chunking dates based on given time-
# steps
#
# Globals:
#   startDate: start date of the
#	       subsetting process
#   parallel: true by default, false if 
#	      --no-chunk is activated
#   startDateArr: array of chunked
#		  start dates
#   endDateArr: array of chunked end
#		dates
#   startDate: start date of the
#	       process
#   endDate: end date of the process
#   dateFormat: default date format
#		for manipulations
#   
#
# Arguments:
#   1: -> tStep: string of time-step
#	  	 intervals for chunks
#
# Outputs:
#   startDateArray and endDateArray
#   will be filled for each chunk of
#   date for further processing
#######################################
chunk_dates () {
  # local variables
  local toDate="$startDate"
  local tStep="$1"
  local midDate
  local toDateEnd

  # if no chunking
  if [[ "$parallel" == "false" ]]; then
    startDateArr+=("$(format_date "$startDate" "$dateFormat")")
    endDateArr+=("$(format_date "$endDate" "$dateFormat")")
    return # exit the function

  # if chunking
  elif [[ "$parallel" == "true" ]]; then

    while [[ "$(unix_epoch "$toDate")" -le "$(unix_epoch "$endDate")" ]]; do
      midDate="$(format_date "$toDate" "%Y-%m-01")"
      toDateEnd="$(format_date "$midDate $tStep -1hour" "$dateFormat")"

      # considering last month if not fully being a $tStep
      if [[ "$(unix_epoch "$toDateEnd")" -ge "$(unix_epoch "$endDate")" ]]; then
        startDateArr+=("$(format_date "$toDate" "$dateFormat")")
        endDateArr+=("$(format_date "$endDate" "$dateFormat")")
        break # break the while loop
      fi

      startDateArr+=("$(format_date "$toDate" "$dateFormat")")
      endDateArr+=("$(format_date "$toDateEnd" "$dateFormat")")

      toDate=$(date --date="$midDate $tStep")
    done
  fi
}

#######################################
# Chunking ensemble members in array
# elements
#
# Arguments:
#   1: -> esnemble: comma-separated 
#	  values of ensemble members
#
# Outputs:
#   Global ensembleArr array containing
#   individual members names or an
#   empty array if '--ensemble'
#   argument was not applicable
#######################################
chunk_ensemble () {
  # local variables
  local value="$1"

  # make global 'ensembleArr' array
  IFS=',' read -ra ensembleArr <<< "$(echo "$value")"
  
  # check to see if the '--ensemble'
  # argument was applicable
  if [[ "${#ensembleArr[@]}" -gt 0 ]]; then
    :
  else
    # make an empty array for datasets that
    # do not have any ensemble members
    ensembleArr=("")
  fi
}


# ======================
# Necessary preparations
# ======================
# put necessary arguments in an array - just for legibility
declare -A funcArgs=([jobSubmission]="$jobSubmission" \
		     [datasetDir]="$datasetDir" \
		     [variables]="$variables" \
		     [outputDir]="$outputDir" \
		     [timeScale]="$timeScale" \
		     [startDate]="$startDate" \
		     [endDate]="$endDate" \
		     [latLims]="$latLims" \
		     [lonLims]="$lonLims" \
		     [prefixStr]="$prefixStr" \
		     [cache]="$cache" \
		     [ensemble]="$ensemble" \
		    );


# ========================
# Data processing function
# ========================
call_processing_func () {
  # input arguments as local variables
  scriptFile="$1" # script local path
  local chunkTStep="$2" # chunking time-frame periods

  # local variables
  local scriptName=$(basename $scriptFile) # script/dataset name
  local logDir="$HOME/.datatool/" # local directory for logs
  local jobArrLen

  # make the $logDir if haven't been created yet
  mkdir -p $logDir

  # typical script to run for all sub-modules
  local script=$(cat <<- EOF 
	bash ${scriptFile} \
	--dataset-dir="${funcArgs[datasetDir]}" \
	--variable="${funcArgs[variables]}" \
	--output-dir="${funcArgs[outputDir]}" \
	--start-date="${funcArgs[startDate]}" \
	--end-date="${funcArgs[endDate]}" \
	--time-scale="${funcArgs[timeScale]}" \
	--lat-lims="${funcArgs[latLims]}" \
	--lon-lims="${funcArgs[lonLims]}" \
	--prefix="${funcArgs[prefixStr]}" \
	--cache="${funcArgs[cache]}" \
	--ensemble="${funcArgs[ensemble]}"
	EOF
  )

  # evaluate the script file using the arguments provided
  if [[ "${funcArgs[jobSubmission]}" == true ]]; then
    # chunk time-frame and ensembles
    chunk_dates "$chunkTStep"
    chunk_ensemble "$ensemble" # 'ensemble' is a global variable

    # length of total number of tasks and indices 
    taskLen=$(( ${#startDateArr[@]} * ${#ensembleArr[@]} ))
    jobArrLen=$(( $taskLen - 1 ))

    # parallel run 
    # FIXME: This needs to be moved into a template scheduler
    #        document
    sbatch <<- EOF
	#!/bin/bash
	#SBATCH --array=0-$jobArrLen
	#SBATCH --cpus-per-task=4
	#SBATCH --nodes=1
	#SBATCH --account=rpp-kshook
	#SBATCH --time=04:00:00
	#SBATCH --mem=8000M
	#SBATCH --job-name=DATA_${scriptName}
	#SBATCH --error=$logDir/datatool_%A-%a_err.txt
	#SBATCH --output=$logDir/datatool_%A-%a.txt
	#SBATCH --mail-user=$email
	#SBATCH --mail-type=BEGIN,END,FAIL
	#SBATCH ${parsable}
	
	$(declare -p startDateArr)
	$(declare -p endDateArr)
	$(declare -p ensembleArr)
	
	idxDate="\$(( \${SLURM_ARRAY_TASK_ID} % \${#startDateArr[@]}  ))"
	idxMember="\$(( \${SLURM_ARRAY_TASK_ID} / \${#startDateArr[@]}  ))"
	
	tBegin="\${startDateArr[\${idxDate}]}"
	tEnd="\${endDateArr[\${idxDate}]}"
	member="\${ensembleArr[\${idxMember}]}"
	
	echo "${scriptName}.sh: #\${SLURM_ARRAY_TASK_ID} chunk submitted."
	echo "${scriptName}.sh: Chunk start date is \$tBegin"
	echo "${scriptName}.sh: Chunk end date is   \$tEnd"
	if [[ -n \${member} ]]; then
	  echo "${scriptName}.sh: Ensemble member is  \$member"
	fi
	
	srun ${script} --start-date="\$tBegin" --end-date="\$tEnd" --cache="${cache}-\${SLURM_ARRAY_JOB_ID}-\${SLURM_ARRAY_TASK_ID}" --ensemble="\${member}"
	EOF

    if [[ -z $parsable ]]; then
      echo "$(basename $0): job submission details are printed under $logDir"
    fi

  # serial run
  else
    eval "$script"
  fi
}


# ======================
# Checking input dataset
# ======================

# FIXME: This list needs to become part of a configuration
#        file in future releases

scriptPath="$(dirname $0)/scripts"

case "${dataset,,}" in
  # NCAR-GWF CONUSI
  "conus1" | "conusi" | "conus_1" | "conus_i" | "conus 1" | "conus i" | "conus-1" | "conus-i")
    call_processing_func "$scriptPath/conus_i/conus_i.sh" "3months"
    ;;

  # NCAR-GWF CONUSII
  "conus2" | "conusii" | "conus_2" | "conus_ii" | "conus 2" | "conus ii" | "conus-2" | "conus-ii")
    call_processing_func "$scriptPath/conus_ii/conus_ii.sh" "1month"
    ;;

  # ECMWF ERA5
  "era_5" | "era5" | "era-5" | "era 5")
    call_processing_func "$scriptPath/era5/era5_simplified.sh" "2years"
    ;;
  
  # ECCC RDRS 
  "rdrs" | "rdrsv2.1")
    call_processing_func "$scriptPath/rdrs/rdrs.sh" "6months"
    ;;

  # CanRCM4-WFDEI-GEM-CaPA
  "canrcm4-wfdei-gem-capa" | "canrcm4_wfdei_gem_capa")
    call_processing_func "$scriptPath/canrcm4_wfdei_gem_capa/canrcm4_wfdei_gem_capa.sh" "10years" 
    ;;
  
  # WFDEI-GEM-CaPA
  "wfdei-gem-capa" | "wfdei_gem_capa" | "wfdei-gem_capa" | "wfdei_gem-capa")
    call_processing_func "$scriptPath/wfdei_gem_capa/wfdei_gem_capa.sh" "10years"
    ;;

  # Daymet dataset
  "daymet" | "Daymet" )
    call_processing_func "$scriptPath/daymet/daymet.sh" "5years"
    ;;

  # BCC-CSM2-MR
  "bcc" | "bcc_csm2_mr" | "bcc-csm2-mr" )
    call_processing_func "$scriptPath/bcc_csm2_mr/bcc_csm2_mr.sh" "50years"
    ;;

  # CNRM_CM6_1
  "cnrm" | "cnrm_cm6_1" | "cnrm-cm6-1" )
    call_processing_func "$scriptPath/cnrm_cm6_1/cnrm_cm6_1.sh" "50years"
    ;;

  # EC_EARTH3_VEG
  "ec" | "ec_earth3_veg" | "ec-earth3-veg" )
    call_processing_func "$scriptPath/ec_earth3_veg/ec_earth3_veg.sh" "50years"
    ;;

  # GFDL_CM4
  "gfdl_cm4" | "gfdl-cm4" )
    call_processing_func "$scriptPath/gfdl_cm4/gfdl_cm4.sh" "50years"
    ;;

  # GDFL_ESM4
  "gfdl_esm4" | "gfdl-esm4" )
    call_processing_func "$scriptPath/gfdl_esm4/gfdl_esm4.sh" "50years"
    ;;

  # IPSL_CM6A_LR
  "ipsl" | "ipsl_cm6a_lr" | "ipsl-cm6a-lr" )
    call_processing_func "$scriptPath/ipsl_cm6a_lr/ipsl_cm6a_lr.sh" "50years"
    ;;

  # MRI_ESM2_0
  "mri" | "mri-esm2-0" | "mri_esm2_0" )
    call_processing_func "$scriptPath/mri_esm2_0/mri_esm2_0.sh" "50years"
    ;;

  # Hybrid Observation Dataset
  "hybrid" | "hybrid-obs" | "hybrid_obs" | "hybrid_observation" | "hybrid-observation" )
    call_processing_func "$scriptPath/hybrid_obs/hybrid_obs.sh" "50years"
    ;;

  # dataset not included above
  *)
    echo "$(basename $0): missing/unknown dataset";
    exit 1;;
esac

