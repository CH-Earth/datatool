#!/bin/bash
# Meteorological Data Processing Workflow
# Copyright (C) 2022-2023, University of Saskatchewan
# Copyright (C) 2023-2024, University of Calgary
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
function short_usage () {
  echo "Usage: $(basename $0) [-jh] [-i DIR] [-d DATASET] [-co DIR] [-se DATE] [-ln REAL,REAL] [-p STR]

Try \`$(basename $0) --help\` for more options." >&1;
}

function version () {
  echo "$(basename $0): version $(cat $(dirname $0)/VERSION)";
  exit 0;
}

function usage () {
  echo "Meteorological Data Processing Script - version $(cat $(dirname $0)/VERSION)

Usage:
  $(basename $0) [options...]

Script options:
  -d, --dataset                     Meteorological forcing dataset of interest
  -i, --dataset-dir=DIR             The source path of the dataset file(s)
  -v, --variable=var1[,var2[...]]   Variables to process
  -o, --output-dir=DIR              Writes processed files to DIR
  -s, --start-date=DATE             The start date of the data
  -e, --end-date=DATE               The end date of the data
  -l, --lat-lims=REAL,REAL          Latitude's upper and lower bounds
                                    optional; within the [-90, +90] limits
  -n, --lon-lims=REAL,REAL          Longitude's upper and lower bounds
                                    optional; within the [-180, +180] limits
  -a, --shape-file=PATH             Path to the ESRI shapefile; optional
  -m, --ensemble=ens1,[ens2,[...]]  Ensemble members to process; optional
                                    Leave empty to extract all ensemble members
  -M, --model=model1,[model2,[...]] Models that are part of a dataset,
                                    only applicable to climate datasets, optional
  -S, --scenario=scn1,[scn2,[...]]  Climate scenarios to process, only applicable
                                    to climate datasets, optional
  -j, --submit-job                  Submit the data extraction process as a job
                                    on the SLURM system; optional
  -k, --no-chunk                    No parallelization, recommended for small domains
  -p, --prefix=STR                  Prefix  prepended to the output files
  -b, --parsable                    Parsable SLURM message mainly used
                                    for chained job submissions
  -c, --cache=DIR                   Path of the cache directory; optional
  -E, --email=user@example.com      E-mail user when job starts, ends, or
                                    fails; optional
  -C, --cluster=JSON                JSON file detailing cluster-specific details
  -L, --list-datasets               List all the available datasets and the
                                    corresponding keywords for '--dataset' option
  -V, --version                     Show version
  -h, --help                        Show this screen and exit

For bug reports, questions, discussions open an issue
at https://github.com/kasra-keshavarz/datatool/issues" >&1;

  exit 0;
}

function list_datasets () {
echo "Meteorological Data Processing Script - version $(cat $(dirname $0)/VERSION)

Currently, the following meteorological datasets are
available for processing:
$(cat $(dirname $0)/etc/usages/DATASETS | sed 's/^\(.*\)$/\o033[34m\1\o033[0m/')" >&1;

  exit 0;
}

# useful log date format function
logDate () { echo "($(date +"%Y-%m-%d %H:%M:%S")) "; }
logDirDate () { echo "$(date +"%Y%m%d_%H%M%S")"; }

# useful maximum function
max () { printf "%s\n" "${@:2}" | sort "$1" | tail -n1; }
count_values () { max -g $(echo $1 | tr ',' ' ' | wc -w) 1 ; }

# =====================
# Necessary Assumptions
# =====================
# TZ to be set to UTC to avoid invalid dates due to Daylight Saving
alias date='TZ=UTC date'

# expand aliases for the one stated above
shopt -s expand_aliases

# local paths
schedulersPath="$(dirname $0)/etc/schedulers/"
scriptPath="$(dirname $0)/etc/scripts" # core script path
recipePath="$(realpath $(dirname $0)/var/repos/builtin/recipes/)"
extract_submodel="$(dirname $0)/etc/scripts/extract_subdir_level.sh" # script path


# =======================
# Parsing input arguments
# =======================
# argument parsing using GNU getopt
parsedArguments=$( \
  getopt --alternative \
  --name "extract-dataset" \
  -o jhVbLE:d:i:v:o:s:e:t:l:n:p:c:m:M:S:ka:C: \
  --long submit-job,help,version, \
  --long parsable,list-datasets,email:, \
  --long dataset:,dataset-dir:,variable:, \
  --long output-dir:,start-date:,end-date:, \
  --long time-scale:,lat-lims:,lon-lims:, \
  --long prefix:,cache:,ensemble:,model:, \
  --long scenario:,no-chunk,shape-file:, \
  --long cluster: -- "$@" \
)
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
    -V | --version)       version              ; shift   ;; # optional
    -L | --list-datasets) list_datasets        ; shift   ;; # optional
    -j | --submit-job)    jobSubmission=true   ; shift   ;; # optional
    -E | --email)         email="$2"           ; shift 2 ;; # optional
    -i | --dataset-dir)   datasetDir="$2"      ; shift 2 ;; # required
    -d | --dataset)       dataset="$2"         ; shift 2 ;; # required
    -v | --variable)      variables="$2"       ; shift 2 ;; # required
    -o | --output-dir)    outputDir="$2"       ; shift 2 ;; # required
    -s | --start-date)    startDate="$2"       ; shift 2 ;; # required
    -e | --end-date)      endDate="$2"         ; shift 2 ;; # required
    -t | --time-scale)    timeScale="$2"       ; shift 2 ;; # required
    -l | --lat-lims)      latLims="$2"         ; shift 2 ;; # required
    -n | --lon-lims)      lonLims="$2"         ; shift 2 ;; # required
    -m | --ensemble)      ensemble="$2"        ; shift 2 ;; # optional
    -M | --model)         model="$2"           ; shift 2 ;; # optional
    -S | --scenario)      scenario="$2"        ; shift 2 ;; # optional
    -k | --no-chunk)      parallel=false       ; shift   ;; # optional
    -p | --prefix)        prefixStr="$2"       ; shift 2 ;; # required
    -b | --parsable)      parsable=true        ; shift   ;; # optional
    -c | --cache)         cache="$2"           ; shift 2 ;; # optional
    -C | --cluster)       cluster="$2"         ; shift 2 ;; # required
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
if [[ -n $parsable ]] && [[ -z $jobSubmission ]]; then
  echo "$(basename $0): ERROR! --parsable argument cannot be used without job submission"
  exit 1;
fi

# if parsable argument is provided
if [[ -n $parsable ]]; then
  parsable="--parsable"
else
  parsable=""
fi

# if account is not provided, use `rpp-kshook` as default
if [[ -z $account ]] && [[ $jobSubmission == "true" ]]; then
  account="rpp-kshook"
  if [[ -z $parsable ]]; then
    echo "$(basename $0): WARNING! --account not provided, using \`rpp-kshook\` by default."
  fi
fi

# if shapefile is provided extract the extents from it
if [[ -n $shapefile ]]; then
  # extract the shapefile extent
  IFS=' ' read -ra shapefileExtents <<< "$(ogrinfo -so -al "$shapefile" | sed 's/[),(]//g' | grep Extent)"
  # transform the extents in case they are not in EPSG:4326
  IFS=':' read -ra sourceProj4 <<< "$(gdalsrsinfo $shapefile | grep -e "PROJ.4")" >&2
  # Assuming EPSG:4326 if no definition of the CRS is provided
  if [[ ${#sourceProj4[@]} -eq 0 ]]; then
    echo "$(basename $0): WARNING! Assuming EPSG:4326 for --shape-file as none provided"
    sourceProj4=('PROJ4.J' '+proj=longlat +datum=WGS84 +no_defs')
  fi
  # transform limits and assign to variables
  IFS=' ' read -ra leftBottomLims <<< $(echo "${shapefileExtents[@]:1:2}" | gdaltransform -s_srs "${sourceProj4[1]}" -t_srs EPSG:4326 -output_xy)
  IFS=' ' read -ra rightTopLims <<< $(echo "${shapefileExtents[@]:4:5}" | gdaltransform -s_srs "${sourceProj4[1]}" -t_srs EPSG:4326 -output_xy)
  # define $latLims and $lonLims from $shapefileExtents
  lonLims="${leftBottomLims[0]},${rightTopLims[0]}"
  latLims="${leftBottomLims[1]},${rightTopLims[1]}"
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


# =================
# Base dependencies 
# =================
# `gdal' and `jq' or the basics we need to run this file
# initialize the cluster-dependent settings
inits="$(jq -r '.modules.init | join("; ")' $cluster)"
if [[ -n "$inits" ]]; then
  eval "$inits"
fi

# assure `jq' and `gdal' are loaded
gdal_init="$(jq -r '.modules.gdal' $cluster)"
if [[ -n "$gdal_init" ]]; then
  eval "$gdal_init"
else
  echo "$(basename $0): ERROR! GDAL missing"
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
dateFormat="%Y-%m-%dT%H:%M:%S"


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
# Arguments:
#   1: -> tStep: string of time-step
#	  	 intervals for chunks
#
# Outputs:
#   startDateArray and endDateArray
#   will be filled for each chunk of
#   date for further processing
#######################################
function chunk_dates () {
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
# Create m4 variable definitions to be
# used in m4 macro calls in CLI from 
# JSON objects
#
# Globals:
#   None
#
# Arguments:
#   1: JSON object
#
# Outputs:
#   A string in "-D__KEY__=$value"
#   format of all the fields of a JSON
#   object
#######################################
function json_to_m4_vars () {
  # local variables
  local json="$1"

  # echo the string using jq>1.6
  echo "$json" | jq -r \
    'to_entries |
     map(select(.value != null and .value != "")) |
     map(
         "-D" +
         "__" +
         (.key | tostring | ascii_upcase) +
         "__" + "=" +
         (.value | tostring)
     ) |
     join(" ")'
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
  [model]="$model" \
  [scenario]="$scenario"
);


# ========================
# Data processing function
# ========================
function call_processing_func () {
  # input arguments as local variables
  local scriptFile="$1" # script local path
  local chunkTStep="$2" # chunking time-frame periods
  local submodelFlag="$3" # flag for submodels' existence

  # local script related variables
  # script requirements
  local scriptName=$(basename $scriptFile | cut -d '.' -f 1)
  local script
  # local directory for logs
  local logDir="$HOME/.datatool/${scriptName}_$(logDirDate)/" 
  # selected scheduler
  local scheduler
  # local length variables for chunking jobs
  local startDateStr
  local endDateStr
  local jobArrLen
  local modelLen
  local scenarioLen
  local ensembleLen
  local dateLen
  local taskLen
  # local iterator variables
  local dateIter
  local modelIter
  local ensembleIter
  # local JSON variables
  local jobDirectiveJSON
  local schedulerJSON
  local jobChunkArrayJSON
  local jobChunkJSON
  local JSON
  # local variables defining module information
  local jobModules
  local jobModulesInit
  # local m4 variables
  local jobDirectiveM4
  local jobScriptM4


  # make the $logDir if haven't been created yet
  mkdir -p $logDir

  # if dataset contains sub-models, extract them
  if [[ $submodelFlag == 1 ]]; then
    model=$($extract_submodel "$datasetDir" "$model")
    funcArgs[model]=$model
  fi

  # typical script to run for all sub-modules
  script=$(cat <<- EOF 
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
	--ensemble="${funcArgs[ensemble]}" \
	--scenario="${funcArgs[scenario]}" \
	--model="${funcArgs[model]}"
	EOF
  )

  # evaluate the script file using the arguments provided
  if [[ "${funcArgs[jobSubmission]}" == true ]]; then
    # ==========================================
    # Chunk time-frame and other relevant arrays
    # ==========================================
    # chunk dates
    chunk_dates "$chunkTStep"
    # converting chunk date Bash arrays to comma-delimited strings
    startDateStr="$(IFS=,; echo "${startDateArr[*]}")"
    endDateStr="$(IFS=,; echo "${endDateArr[*]}")"

    # ========================
    # Building job array specs
    # ========================
    # relevant array lengths
    let "ensembleLen = $(count_values $ensemble)"
    let "modelLen = $(count_values $model)"
    let "scenarioLen = $(count_values $scenario)"
    let "dateLen = $(max -g ${#startDateArr[@]} 1)"

    # relevant iterator variables
    let "dateIter = $ensembleLen * $modelLen * $scenarioLen"
    let "ensembleIter = $modelLen * $scenarioLen"
    let "modelIter = $scenarioLen"

    # length of total number of tasks and indices
    let "taskLen = $dateLen * $ensembleLen * $modelLen * $scenarioLen"
    let "jobArrLen = $taskLen - 1"

    # ==============================
    # Building relevant JSON objects
    # ==============================
    # job chunk array information
    jobChunkArrayJSON="$(
      jq -n \
        --arg "startDateArr" "${startDateStr}" \
        --arg "endDateArr" "${endDateStr}" \
        --arg "ensembleArr" "${ensemble}" \
        --arg "modelArr" "${model}" \
        --arg "scenarioArr" "${scenario}" \
        '$ARGS.named | with_entries(.value |= split(","))' \
      )"

    # job chunk variable information
    jobChunkJSON="$(
      jq -n \
        --arg "ensembleLen" "$ensembleLen" \
        --arg "modelLen" "$modelLen" \
        --arg "scenarioLen" "$scenarioLen" \
        --arg "dateLen" "$dateLen" \
        --arg "dateIter" "$dateIter" \
        --arg "ensembleIter" "$ensembleIter" \
        --arg "modelIter" "$modelIter" \
        '$ARGS.named'
      )"

    # scheduler information
    scheduler="$(
      jq -r \
        '.scheduler' $cluster \
      )"
    schedulerJSON="$(
      jq -r \
        '.environment_variables' ${schedulersPath}/${scheduler}.json \
      )"

    # job directives information
    jobDirectiveJSON="$(
      jq -n \
        --arg "jobArrLen" "$jobArrLen" \
        --arg "scriptName" "$scriptName" \
        --arg "logDir" "$logDir" \
        --arg "email" "$email" \
        --arg "parsable" "$parsable" \
        --argjson "specs" "$(jq -r '.specs' $cluster)" \
        '$ARGS.named + $specs | del(.specs)' \
      )"

    # job script information
    # arguments used for pallaleization, i.e.,
    # startDate, endDate, ensemble, model, scenario,
    # are removed, as they are processed elsewhere and fed
    # as part of various other JSONs, namely
    # `$jobChunkJSON` and `$jobChunkArrJSON`
    jobScriptJSON="$(
      jq -n \
         --arg "scriptFile" "$scriptFile" \
         --arg "datasetDir" "${funcArgs[datasetDir]}" \
         --arg "variable" "${funcArgs[variables]}" \
         --arg "outputDir" "${funcArgs[outputDir]}" \
         --arg "timeScale" "${funcArgs[timeScale]}" \
         --arg "latLims" "${funcArgs[latLims]}" \
         --arg "lonLims" "${funcArgs[lonLims]}" \
         --arg "prefix" "${funcArgs[prefixStr]}" \
         --arg "cache" "${funcArgs[cache]}" \
        '$ARGS.named' \
      )"

    # job module init information - not JSON as echoed as is
    jobModulesInit="$(
      jq -r \
        '.modules.init[] | select(length > 0)' $cluster \
      )"

    # job module information - not JSON as echoed as is
    jobModules="$(
      jq -r \
        '.modules[] | 
         select(length > 0) | 
         select(type != "array")' $cluster \
      )"


    # ============
    # Parallel run
    # ============
    # determining job script path
    local jobScriptPath="$logDir/job.${scheduler}"
    local jobConfPath="$logDir/job.json"

    # create JSON config file for final submission
    JSON="$( 
      jq -n \
        --argjson "jobscript" "$jobScriptJSON" \
        --argjson "jobdirective" "$jobDirectiveJSON" \
        --argjson "scheduler" "$schedulerJSON" \
        --argjson "jobchunks" "$jobChunkJSON" \
        --argjson "jobchunksarrays" "$jobChunkArrayJSON" \
        '$jobscript + 
         $jobdirective + 
         $scheduler + 
         $jobchunks + 
         $jobchunksarrays' \
      )"

    # exporting job configurations as a JSON to the job $logDir
    echo "$JSON" > "$jobConfPath"

    # generating the submission script using m4 macros
    # m4 variables defined
    # m4 variables are in the following form: __VAR__
    jobDirectiveM4="$(json_to_m4_vars "$jobDirectiveJSON")"
    # append the main processing script using m4 macros
    jobScriptM4="-D__CONF__=$jobConfPath "
    jobScriptM4+="$(json_to_m4_vars "$schedulerJSON") "

    # create scheduler-specific job submission script
    # 1. job scheduler directives
    m4 ${jobDirectiveM4} ${schedulersPath}/${scheduler}.m4 > \
      ${jobScriptPath}

    # 2. module inititation, if applicable
    echo -e "\n${jobModulesInit}" >> "${jobScriptPath}"

    # 3. loading core modules, if applicable
    echo -e "\n${jobModules}" >> "${jobScriptPath}"

    # 4. main body of script
    m4 ${jobScriptM4} ${scriptPath}/main.m4 >> \
      ${jobScriptPath}

    # choose applicable scheduler and submit the job
    case "${scheduler,,}" in 
      "slurm")
        sbatch --export=NONE ${jobScriptPath} ;;
      "pbs")
        qsub ${jobScriptPath} ;;
      "lfs")
        bsub --env=none ${jobScriptPath} ;;
    esac

  else
    # serial mode
    # load all the necessary modules
    mods="$( \
      jq -r \
        '.modules | 
        to_entries | 
        map(
          select(
            .value | 
            type != "array" and . != ""
            )
        ) | 
        map(.value) | 
        join(" && ")' \
      $cluster)"
    eval "$mods"
    eval "${script}"
  fi
}


# ======================
# Checking input dataset
# ======================
case "${dataset,,}" in

  # ============
  # WRF products
  # ============

  # NCAR-GWF CONUSI
  "conus1" | "conusi" | "conus_1" | "conus_i" | "conus 1" | "conus i" | "conus-1" | "conus-i")
    call_processing_func "$recipePath/gwf-ncar-conus_i/conus_i.sh" "3months"
    ;;

  # NCAR-GWF CONUSII
  "conus2" | "conusii" | "conus_2" | "conus_ii" | "conus 2" | "conus ii" | "conus-2" | "conus-ii")
    call_processing_func "$recipePath/gwf-ncar-conus_ii/conus_ii.sh" "1month"
    ;;

  # ==========
  # Reanalysis
  # ==========

  # ECMWF ERA5
  "era_5" | "era5" | "era-5" | "era 5")
    call_processing_func "$recipePath/ecmwf-era5/era5_simplified.sh" "2years"
    ;;
  
  # ECCC RDRS
  "rdrs" | "rdrsv2.1")
    call_processing_func "$recipePath/eccc-rdrs/rdrs.sh" "6months"
    ;;

  # ====================
  # Observation datasets
  # ====================

  # Daymet dataset
  "daymet" | "Daymet" )
    call_processing_func "$recipePath/ornl-daymet/daymet.sh" "5years"
    ;;

  # ================
  # Climate datasets
  # ================

  # ESPO-G6-R2 dataset
  "espo" | "espo-g6-r2" | "espo_g6_r2" | "espo_g6-r2" | "espo-g6_r2" )
    call_processing_func "$recipePath/ouranos-espo-g6-r2/espo-g6-r2.sh" "151years" "1"
    ;;

  # Ouranos-MRCC5-CMIP6 dataset
  "crcm5-cmip6" | "mrcc5-cmip6" | "crcm5" | "mrcc5" )
    call_processing_func "$recipePath/ouranos-mrcc5-cmip6/mrcc5-cmip6.sh" "5years"
    ;;

  # Alberta Government Downscaled Climate Dataset - CMIP6
  "alberta" | "ab-gov" | "ab" | "ab_gov" | "abgov" )
    call_processing_func "$recipePath/ab-gov/ab-gov.sh" "151years" "0"
    ;;

  # NASA GDDP-NEX-CMIP6
  "gddp" | "nex" | "gddp-nex" | "nex-gddp" | "gddp-nex-cmip6" | "nex-gddp-cmip6")
    call_processing_func "$recipePath/nasa-nex-gddp-cmip6/nex-gddp-cmip6.sh" "100years" "0"
    ;;

  # CanRCM4-WFDEI-GEM-CaPA
  "canrcm4_g" | "canrcm4-wfdei-gem-capa" | "canrcm4_wfdei_gem_capa")
    call_processing_func "$recipePath/ccrn-canrcm4_wfdei_gem_capa/canrcm4_wfdei_gem_capa.sh" "5years"
    ;;
  
  # WFDEI-GEM-CaPA
  "wfdei_g" | "wfdei-gem-capa" | "wfdei_gem_capa" | "wfdei-gem_capa" | "wfdei_gem-capa")
    call_processing_func "$recipePath/ccrn-wfdei_gem_capa/wfdei_gem_capa.sh" "5years"
    ;;


  # dataset not included above
  *)
    echo "$(basename $0): missing/unknown dataset";
    exit 1;;
esac

