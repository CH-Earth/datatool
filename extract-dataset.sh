#!/bin/bash
# Meteorological Data Processing Workflow
# Copyright (C) 2022, University of Saskatchewan
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
                                        'CONUSI';'ERA5';'CONUSII';'RDRS';
                                        'canrcm4-wfdei-gem-capa';
  -i, --dataset-dir=DIR			The source path of the dataset file(s)
  -v, --variable=var1[,var2[...]]	Variables to process
  -o, --output-dir=DIR			Writes processed files to DIR
  -s, --start-date=DATE			The start date of the data
  -e, --end-date=DATE			The end date of the data
  -l, --lat-lims=REAL,REAL		Latitude's upper and lower bounds
  -n, --lon-lims=REAL,REAL		Longitude's upper and lower bounds
  -m, --ensemble=ens1,[ens2[...]]	Ensemble members to process; optional
  					Leave empty to extract all ensemble members
  -j, --submit-job			Submit the data extraction process as a job
					on the SLURM system; optional
  -k, --no-chunk			No parallelization, recommended for small domains
  -p, --prefix=STR			Prefix  prepended to the output files
  -c, --cache=DIR			Path of the cache directory; optional
  -E, --email=user@example.com		E-mail user when job starts, ends, and finishes; optional
  -V, --version				Show version
  -h, --help				Show this screen and exit

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
parsedArguments=$(getopt -a -n extract-dataset -o jhVE:d:i:v:o:s:e:t:l:n:p:c:m:k --long submit-job,help,version,email:,dataset:,dataset-dir:,variable:,output-dir:,start-date:,end-date:,time-scale:,lat-lims:,lon-lims:,prefix:,cache:,ensemble:,no-chunk -- "$@")
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
    -c | --cache)	  cache="$2"	       ; shift 2 ;; # optional

    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;

    # in case of invalid option
    *) echo "$(basename $0): invalid option '$1'" >$2;
       short_usage;
       exit 1;;
  esac
done

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
  echo "$(basename $0): Email is not supported wihtout job submission;"
  echo "$(basename $0): Continuing without email notification..."
fi


# ===========================
# Quasi-parallel requirements
# ===========================
# necessary arrays
startDateArr=() # start dates array
endDateArr=()   # end dates array

# necessary one-liner functions
unix_epoch () { date --date="$@" +"%s"; } # unix EPOCH command
format_date () { date --date="$1" +"$2"; } # format date

# default date format
dateFormat="%Y-%m-%d %H:%M:%S"

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


# =================================
# Template data processing function
# =================================
call_processing_func () {

  local script="$1" # script local path
  local chunkTStep="$2" # chunking time-frame periods

  local scriptName=$(echo $script | cut -d '/' -f 2) # script/dataset name

  # prepare a script in string format
  # all processing script files must follow same input argument standard
  local scriptRun
  read -rd '' scriptRun <<- EOF
	bash ${script} --dataset-dir="${funcArgs[datasetDir]}" --variable="${funcArgs[variables]}" --output-dir="${funcArgs[outputDir]}" --start-date="${funcArgs[startDate]}" --end-date="${funcArgs[endDate]}" --time-scale="${funcArgs[timeScale]}" --lat-lims="${funcArgs[latLims]}" --lon-lims="${funcArgs[lonLims]}" --prefix="${funcArgs[prefixStr]}" --cache="${funcArgs[cache]}" --ensemble="${funcArgs[ensemble]}"
	EOF

  # evaluate the script file using the arguments provided
  if [[ "${funcArgs[jobSubmission]}" == true ]]; then
    # chunk time-frame
    chunk_dates "$chunkTStep"
    local dateArrLen="$((${#startDateArr[@]}-1))"  # or $endDateArr
    # Create a temporary directory for keeping job logs
    mkdir -p "$HOME/scratch/.gdt_logs"
    # SLURM batch file
    sbatch <<- EOF
	#!/bin/bash
	#SBATCH --array=0-$dateArrLen
	#SBATCH --cpus-per-task=4
	#SBATCH --nodes=1
	#SBATCH --account=rpp-kshook
	#SBATCH --time=04:00:00
	#SBATCH --mem=8GB
	#SBATCH --job-name=GWF_${scriptName}
	#SBATCH --error=$HOME/scratch/.gdt_logs/GWF_%A-%a_err.txt
	#SBATCH --output=$HOME/scratch/.gdt_logs/GWF_%A-%a.txt
	#SBATCH --mail-user=$email
	#SBATCH --mail-type=BEGIN,END,FAIL

	$(declare -p startDateArr)
	$(declare -p endDateArr)
	tBegin="\${startDateArr[\${SLURM_ARRAY_TASK_ID}]}"
	tEnd="\${endDateArr[\${SLURM_ARRAY_TASK_ID}]}"

	echo "${scriptName}.sh: #\${SLURM_ARRAY_TASK_ID} chunk submitted."
	echo "${scriptName}.sh: Chunk start date is \$tBegin"
	echo "${scriptName}.sh: Chunk end date is   \$tEnd"
	
	srun ${scriptRun} --start-date="\$tBegin" --end-date="\$tEnd" --cache="${cache}-\${SLURM_ARRAY_JOB_ID}-\${SLURM_ARRAY_TASK_ID}"
	EOF
    # echo message
    echo "$(basename $0): job submission details are printed under ${HOME}/scratch/.gdt_logs"
 
  else
    eval "$scriptRun"
  fi
}


# ======================
# Checking input dataset
# ======================

case "${dataset,,}" in
  # NCAR-GWF CONUSI
  "conus1" | "conusi" | "conus_1" | "conus_i" | "conus 1" | "conus i" | "conus-1" | "conus-i")
    call_processing_func "$(dirname $0)/conus_i/conus_i.sh" "3month"
    ;;

  # NCAR-GWF CONUSII
  "conus2" | "conusii" | "conus_2" | "conus_ii" | "conus 2" | "conus ii" | "conus-2" | "conus-ii")
    call_processing_func "$(dirname $0)/conus_ii/conus_ii.sh" "1month"
    ;;

  # ECMWF ERA5
  "era_5" | "era5" | "era-5" | "era 5")
    call_processing_func "$(dirname $0)/era5/era5_simplified.sh" "2year"
    ;;
  
  # ECCC RDRS 
  "rdrs" | "rdrsv2.1")
    call_processing_func "$(dirname $0)/rdrs/rdrs.sh" "1year"
    ;;

  # CanRCM4-WFDEI-GEM-CaPA
  "canrcm4-wfdei-gem-capa" | "canrcm4_wfdei_gem_capa")
    # adding ensemble argument
    if [[ "$parallel" == true ]]; then
      echo "$(basename $0): Warning: Parallel processing is not supported for CanRCM4-WFDEI-GEM-CaPA dataset;"
      echo "$(basename $0): For quasi-parallel processing, consider submitting individual jobs for each ensemble member;"
      echo "$(basename $0): Continuing with serial processing of the requested domain."
    fi
    call_processing_func "$(dirname $0)/canrcm4_wfdei_gem_capa/canrcm4_wfdei_gem_capa.sh" 
    ;;

  # dataset not included above
  *)
    echo "$(basename $0): missing/unknown dataset";
    exit 1;;
esac

