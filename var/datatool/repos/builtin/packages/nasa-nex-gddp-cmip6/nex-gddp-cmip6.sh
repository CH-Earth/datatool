#!/bin/bash
# Meteorological Data Processing Workflow
# Copyright (C) 2024, University of Calgary
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
# 1. Parts of the code are taken from https://www.shellscript.sh/tips/getopt/index.html


# ================
# General comments
# ================
# * All variables are camelCased for distinguishing from function names;
# * function names are all in lower_case with words seperated by underscore for legibility;
# * shell style is based on Google Open Source Projects'
#   Style Guide: https://google.github.io/styleguide/shellguide.html


# ===============
# Usage Functions
# ===============
short_usage() {
  echo "usage: $(basename $0) [-cio DIR] [-v VARS] [-se DATE] [-t CHAR] [-ln REAL,REAL] [-p STR] [-MmS STR[,...]]"
}


# argument parsing using getopt - WORKS ONLY ON LINUX BY DEFAULT
parsedArguments=$(getopt -a -n extract-dataset -o i:v:o:s:e:t:l:n:p:c:m:S:M: --long dataset-dir:,variable:,output-dir:,start-date:,end-date:,time-scale:,lat-lims:,lon-lims:,prefix:,cache:,ensemble:,scenario:,model: -- "$@")
validArguments=$?
if [ "$validArguments" != "0" ]; then
  short_usage;
  exit 1;
fi

# check if no options were passed
if [ $# -eq 0 ]; then
  echo "ERROR $(basename $0): arguments missing";
  exit 1;
fi

# check long and short options passed
eval set -- "$parsedArguments"
while :
do
  case "$1" in
    -i | --dataset-dir)   datasetDir="$2"      ; shift 2 ;; # required
    -v | --variable)      variables="$2"       ; shift 2 ;; # required
    -o | --output-dir)    outputDir="$2"       ; shift 2 ;; # required
    -s | --start-date)    startDate="$2"       ; shift 2 ;; # required
    -e | --end-date)      endDate="$2"         ; shift 2 ;; # required
    -t | --time-scale)    timeScale="$2"       ; shift 2 ;; # redundant - added for compatibility
    -l | --lat-lims)      latLims="$2"         ; shift 2 ;; # required
    -n | --lon-lims)      lonLims="$2"         ; shift 2 ;; # required
    -p | --prefix)        prefix="$2"          ; shift 2 ;; # optional
    -c | --cache)         cache="$2"           ; shift 2 ;; # required
    -m | --ensemble)      ensemble="$2"        ; shift 2 ;; # redundant
    -S | --scenario)      scenario="$2"        ; shift 2 ;; # required
    -M | --model)         model="$2"           ; shift 2 ;; # required

    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;

    # in case of invalid option
    *)
      echo "ERROR $(basename $0): invalid option '$1'";
      short_usage; exit 1 ;;
  esac
done

# check the prefix is not set
if [[ -z $prefix ]]; then
  prefix="data"
fi

# check if $model is provided
if [[ -z $model ]]; then
    echo "ERROR $(basename $0): --model value(s) missing"
  exit 1;
fi

# useful log date format function
logDate () { echo "($(date +"%Y-%m-%d %H:%M:%S")) "; }

# check if the dates are within datasets date range
# define $startYear and $endYear
startYear=$(date --date "$startDate" +"%Y")
endYear=$(date --date "$endDate" +"%Y")


# =====================
# Necessary Assumptions
# =====================
# TZ to be set to UTC to avoid invalid dates due to Daylight Saving
alias date='TZ=UTC date'

# expand aliases for the one stated above
shopt -s expand_aliases


# ==========================
# Necessary Global Variables
# ==========================
latDim="lat"
lonDim="lon"
timeDim="time"
resolution="0.25"


# ===================
# Necessary Functions
# ===================
# Modules below available on Digital Research Alliance of Canada's Graham HPC
## core modules
function load_core_modules () {
  module -q load StdEnv/2020
  module -q load gcc/9.3.0
  module -q load cdo/2.0.4
  module -q load nco/5.0.6
}
function unload_core_modules () {
  # WARNING: DO NOT USE IF YOU ARE NOT SURE HOW TO URE IT
  module -q unload cdo/2.0.4
  module -q unload nco/5.0.6
}
## ncl modules
function load_ncl_module () {
  module -q load StdEnv/2020
  module -q load gcc/9.3.0
  module -q load ncl/6.6.2
}
function unload_ncl_module () {
  module -q unload ncl/6.6.2
}

# loading core modules for the script
load_core_modules


# =================
# Useful one-liners
# =================
#calcualte Unix EPOCH time in seconds from 1970-01-01 00:00:00
unix_epoch () { date --date="$@" +"%s"; }

#check whether the input is float or real
check_real () { if [[ "$1" == *'.'* ]]; then echo 'float'; else echo 'int'; fi; }

#convert to float if the number is 'int'
to_float () { if [[ $(check_real $1) == 'int' ]]; then printf "%.1f" "$1"; echo; else printf "%.5f" "$1"; echo; fi; }

#join array element by the specified delimiter
join_by () { local IFS="$1"; shift; echo "$*"; }

#to_float the latLims and lonLims, real numbers delimited by ','
lims_to_float () { IFS=',' read -ra l <<< $@; f_arr=(); for i in "${l[@]}"; do f_arr+=($(to_float $i)); done; echo $(join_by , "${f_arr[@]}"); }

#offset lims
offset () { float="$1"; offset="$2"; printf "%.1f," $(echo "$float + $offset" | bc) | sed 's/,$//'; }


# ================
# Useful functions
# ================
#######################################
# expand the upper and lower limits of
# $latLims by the resolution value of
# the dataset - only for the sake of an
# abundance of caution
#
# Arguments:
# 1. lims -> spatial extents in a
#            comma-delimited form
# 2. resolution -> resolution of the
#                  dataset for 
#                  expansion
#
# Globals:
# 1. globalLims -> expanded Lims
#######################################
function expand_lims () {
  # local variables
  local lims="$1"
  local res="$2"
  local limArr

  # expansion
  IFS=',' read -ra limArr <<< $lims
  limArr[0]=$(echo "${limArr[0]} - $res" | bc)
  limArr[1]=$(echo "${limArr[1]} + $res" | bc)
  echo "$(join_by , ${limArr[@]})"
}


# ===============
# Data Processing
# ===============
# create $modelArr array from input comma-delimited values
IFS=',' read -ra modelArr <<< $(echo $model)
# create $scenarioArr array from input comma-delimited values
IFS=',' read -ra scenarioArr <<< $(echo $scenario)
# create $ensembleArr array from input comma-delimited values
IFS=',' read -ra ensembleArr <<< $(echo $ensemble)
# create $variableArr array from input comma-delimited values
IFS=',' read -ra variableArr <<< $(echo $variables)

# taking care of various possible scenarios for $startDate and $endDate
## #1 if startYear is before 2015, and historical is NOT selected as a
##    scenario, issue a WARNING and add historical to $scenarioArr
if [[ "$startYear" -lt 2015 ]] && \
   [[ "${scenarioArr[*]}" == "historical" ]]; then
  # issue a warning and add historical to the scenarios
  echo "$(logDate)$(basename $0): WARNING! Dates preceeding 2015 belongs to \`hisotrical\` scenario"
  echo "$(logDate)$(basename $0): WARNING! \`historical\` is added to \`--scenario\` list"
  scenarioArr+=("historical")
fi

## #2 if endYear is beyond 2014, and SSP scenarios are NOT
##    selected, issue an ERROR and terminate with exitcode 1
if [[ "$endYear" -gt 2014 ]] && \
   [[ "${scenarioArr[*]}" == "ssp" ]]; then # `ssp` is treated as *ssp*
   echo "$(logDate)$(basename $0): ERROR! Dates past 2015 belong to \`ssp\` scenarios"
   echo "$(logDate)$(basename $0): ERROR! Choose the appropriate date range and try again"
   exit 1;
fi

# display info
echo "$(logDate)$(basename $0): processing NASA NEX-GDDP-CMIP6..."

# since, the dataset's grid cell system is gaussian, assure to to_float()
# the $latLims and $lonLims values
latLims="$(lims_to_float "$latLims")"
lonLims="$(lims_to_float "$lonLims")"

# since longitudes are within the [0, 360] range, offset input $lonLims by
# -180, if they are greater than 180.
IFS=',' read -ra lims <<< $lonLims
f_arr=()
for lim in "${lims[@]}"; do
  if [[ $(echo "$lim < 0" | bc -l ) ]]; then
    f_arr+=($(offset "$lim" 180))
  else
    f_arr+=($lim)
  fi
done
lonLims="$(join_by , ${f_arr[@]})"

# expand the upper and lower limits of latLims by the resolution value
latLims=$(expand_lims $latLims $resolution)
lonLims=$(expand_lims $lonLims $resolution)


# ============================================
# Build date arrays for time-series extraction
# ============================================
# file date intervals in years - dataset's default
interval=1

fileDateFormat="%Y"
actualDateFormat="%Y-%m-%d"

# define needed variables
let "difference = $endYear - $startYear"
let "steps = $difference / $interval"

# build $startDateFileArr, $endDateFileArr
startDateFileArr=()
endDateFileArr=()
actualStartDateArr=()
actualEndDateArr=()

# range of jumps
range=$(seq 0 $steps)

# filling the arrays
for iter in $range; do
  # jumps every $interval years
  let "jumps = $iter * $interval"

  # current date after necessary jumps
  let "toDate = $jumps + $startYear"

  # extract start and end values
  startValue="$(date --date "${toDate}0101" +"${fileDateFormat}")"
  endValue="$(date --date "${toDate}0101 +${interval}years -1days" +"${fileDateFormat}")"

  # double-check end-date
  if [[ "$endValue" -gt 2100 ]]; then
    endValue="2100" # irregular last date for dataset files
  fi

  # extract start and end values for actual dates
  actualStartValue="$(date --date "${toDate}0101" +"${actualDateFormat}")"
  actualEndValue="$(date --date "${toDate}0101 +${interval}years -1days" +"${actualDateFormat}")"

  # fill up relevant arrays
  startDateFileArr+=("${startValue}")
  endDateFileArr+=("${endValue}")

  actualStartDateArr+=("${actualStartValue}")
  actualEndDateArr+=("${actualEndValue}")
done

# build actualStartArr array for temporal subsetting
actualStartDateArr[0]="$(date --date "${startDate}" +"${actualDateFormat}")"

# and similarly, the actualEndArr array
lastIndex=$(( "${#actualEndDateArr[@]}" - 1 ))
actualEndDateArr[${lastIndex}]="$(date --date "${endDate}" +"${actualDateFormat}")"


# =====================
# Extract dataset files
# =====================
# Typical directory structure of the dataset is:
#   ${datasetDir}/${model}/${scenario}/${ensemble}/${var}/
# and each ${var} directory contains files in the following nomenclature:
#   ${var}_day_${model}_${scenario}_${ensemble}_gn_%Y.nc
# with the %Y year value indicating the starting year of data inside the
# file

# create dataset directories in $cache and $outputDir
echo "$(logDate)$(basename $0): creating output directory under $outputDir"
mkdir -p "$outputDir"
echo "$(logDate)$(basename $0): creating cache directory under $cache"
mkdir -p "$cache"

# iterate over models/submodels
for model in "${modelArr[@]}"; do
  # extract model and submodel names
  modelName=$(echo $model | cut -d '/' -f 1)

  # iterate over scenarios, e.g., ssp126, ssp245, ssp370, ssp585 
  for scenario in "${scenarioArr[@]}"; do

    # iterate over ensemble members, e.g., r1p1, r1p2, r1p3
    for ensemble in "${ensembleArr[@]}"; do

      pathTemplate="${modelName}/${scenario}/${ensemble}/"
      if [[ -e "${datasetDir}/${pathTemplate}" ]]; then
        echo "$(logDate)$(basename $0): processing ${model}.${scenario}.${ensemble} files"
        mkdir -p "${cache}/${pathTemplate}"
        mkdir -p "${outputDir}/${pathTemplate}"
      else
        echo "$(logDate)$(basename $0): ERROR! ${model}.${scenario}.${ensemble} does not exist." 2>&1
        break 1;
      fi

      # iterate over date range of interest using index
      for idx in "${!startDateFileArr[@]}"; do

        # dates for files
        fileStartDate="${startDateFileArr[$idx]}"
        fileEndDate="${endDateFileArr[$idx]}"
        # dates for subsetting
        actualStartDate="${actualStartDateArr[$idx]}"
        actualEndDate="${actualEndDateArr[$idx]}"
        # dates for ncks slabs
        actualStartDateFormatted="$(date --date "${actualStartDate}" +'%Y-%m-%d')"
        actualEndDateFormatted="$(date --date "${actualEndDate}" +'%Y-%m-%d')"

        # iterate over dataset variables of interest
        for var in "${variableArr[@]}"; do

          # define file for further operation
          src="${var}_day_${modelName}_${scenario}_${ensemble}_gn_${fileStartDate}.nc"
          dst="day_${modelName}_${scenario}_${ensemble}_gn_${fileStartDate}.nc"

          # subsetting variable, spatial extents, and temporal extents
          until ncks -A -v ${var} \
                     -d "$latDim","${latLims}" \
                     -d "$lonDim","${lonLims}" \
                     -d "$timeDim","${actualStartDateFormatted}","${actualEndDateFormatted}" \
                     ${datasetDir}/${pathTemplate}/${var}/${src} \
                     ${cache}/${pathTemplate}/${dst}; do
                echo "$(logDate)$(basename $0): Process killed: restarting process" 2>&1
                sleep 10;
          done # until ncks

          # apply offset to $lonDim values of each NetCDF file to have
          # longitude range within [-180, +180]
          until ncap2 -O -s "${lonDim}=${lonDim}-180" \
                      ${cache}/${pathTemplate}/${dst} \
                      ${cache}/${pathTemplate}/${dst}; do
                echo "$(logDate)$(basename $0): Process killed: restarting process" 2>&1
                sleep 10;
          done # until ncap2

          # copy the results
          cp -r ${cache}/${pathTemplate}/${dst} \
                ${outputDir}/${pathTemplate}/${prefix}${dst};

        done # for $variableArr
      done # for $startDateArr
    done # for $ensembleArr
  done # for $scenarioArr
done # for $modelArr

# wait for everything to finish - just in case
sleep 10

mkdir "$HOME/empty_dir"
echo "$(logDate)$(basename $0): deleting temporary files from $cache"
rsync -aP --delete "$HOME/empty_dir/" "$cache"
rm -r "$cache"
echo "$(logDate)$(basename $0): temporary files from $cache are removed"
echo "$(logDate)$(basename $0): results are produced under $outputDir"

