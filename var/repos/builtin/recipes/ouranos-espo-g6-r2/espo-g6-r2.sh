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
# Usage functions
# ===============
short_usage() {
  echo "usage: $(basename $0) [-cio DIR] [-v VARS] [-se DATE] [-t CHAR] [-ln REAL,REAL] [-p STR] [-MmS STR[,...]]"
}


# argument parsing using getopt - WORKS ONLY ON LINUX BY DEFAULT
parsedArguments=$(getopt -a -n espo-g6-r2 -o i:v:o:s:e:t:l:n:p:c:m:S:M: --long dataset-dir:,variable:,output-dir:,start-date:,end-date:,time-scale:,lat-lims:,lon-lims:,prefix:,cache:,ensemble:,scenario:,model: -- "$@")
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
    -m | --ensemble)      ensemble="$2"        ; shift 2 ;; # required
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
  prefix="data_"
fi

# useful log date format function
logDate () { echo "($(date +"%Y-%m-%d %H:%M:%S")) "; }


# ================
# Necessary checks
# ================

# check if the dates are within datasets date range
# define $startYear and $endYear
startYear=$(date --date "$startDate" +"%Y")
endYear=$(date --date "$endDate" +"%Y")

# if $startYear is before 1950 raise a "WARNING" and set startDate 
if [[ $startYear -lt 1950 ]]; then
  echo "$(logDate)$(basename $0): WARNING! The date range of the dataset is between 1950-01-01 and 2100-12-31"
  echo "$(logDate)$(basename $0): WARNING! \`start-date\` is set to 1950-01-01 00:00:00"
  startDate="1950-01-01"
  startYear="1950"
fi

# if $endYear is beyond 2100 raise a "WARNING" and set endDate
if [[ $endYear -gt 2100 ]]; then
  echo "$(logDate)$(basename $0): WARNING! The date range of the dataset is between 1950-01-01 and 2100-12-31"
  echo "$(logDate)$(basename $0): WARNING! \`end-date\` is set to 2100-12-31 00:00:00"
  endDate="2100-12-31"
  endYear="2100"
fi

# check if $model, $ensemble, and $scenario is given
if [[ -z $model ]] || \
   [[ -z $ensemble ]] || \
   [[ -z $scenario ]]; then
  echo "$(logDate)$(basename $0): ERROR! \`--model\`, \`--ensemble\`, and \`--scenario\` values are required"
  exit 1;
fi


# =====================
# Necessary assumptions
# =====================
# TZ to be set to UTC to avoid invalid dates due to Daylight Saving
alias date='TZ=UTC date'

# expand aliases for the one stated above
shopt -s expand_aliases

# paths
datatoolPath="$(dirname $0)/../../" # datatool's path
# daymet index scripts works on RDRSv2.1 grids as well
# and ESPO-G6-R2 has similar grid system as RDRSv2.1
coordIdxScript="$datatoolPath/assets/ncl_scripts/coord_daymet_idx.ncl"
coordClosestIdxScript="$datatoolPath/assets/ncl_scripts/coord_closest_daymet_idx.ncl"


# ==========================
# Necessary global variables
# ==========================
latDim="rlat"
lonDim="rlon"
timeDim="time"


# ===================
# Necessary functions
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


# ===============
# Data processing
# ===============
# display info
echo "$(logDate)$(basename $0): processing Ouranos ESPO-G6-R2..."

# create $modelArr array from input comma-delimited values
IFS=',' read -ra modelArr <<< $(echo $model)
# create $scenarioArr array from input comma-delimited values
IFS=',' read -ra scenarioArr <<< $(echo $scenario)
# create $ensembleArr array from input comma-delimited values
IFS=',' read -ra ensembleArr <<< $(echo $ensemble)
# create $variableArr array from input comma-delimited values
IFS=',' read -ra variableArr <<< $(echo $variables)


# ======================
# Extract domain extents
# ======================

# parse the upper and lower bounds of a given spatial limit
minLat=$(echo $latLims | cut -d ',' -f 1)
maxLat=$(echo $latLims | cut -d ',' -f 2)
minLon=$(echo $lonLims | cut -d ',' -f 1)
maxLon=$(echo $lonLims | cut -d ',' -f 2)

# unload and load necessary modules
unload_core_modules
load_ncl_module

# choose a sample file as all files share the same grid
domainFile=$(find ${datasetDir} -type f -name "*.nc" | head -n 1)

# parse the upper and lower bounds of a given spatial limit
minLat=$(echo $latLims | cut -d ',' -f 1)
maxLat=$(echo $latLims | cut -d ',' -f 2)
minLon=$(echo $lonLims | cut -d ',' -f 1)
maxLon=$(echo $lonLims | cut -d ',' -f 2)

# adding/subtracting 0.1 degree to/from max/min values
minLat=$(bc <<< "$minLat - 0.1")
maxLat=$(bc <<< "$maxLat + 0.1")
minLon=$(bc <<< "$minLon - 0.1")
maxLon=$(bc <<< "$maxLon + 0.1")

# extract the associated indices corresponding to $latLims and $lonLims
coordIdx="$(ncl -nQ 'coord_file='\"$domainFile\" 'minlat='"$minLat" 'maxlat='"$maxLat" 'minlon='"$minLon" 'maxlon='"$maxLon" "$coordIdxScript")"

# if spatial index out-of-bound, i.e., 'ERROR' is return
if [[ "${coordIdx}" == "ERROR" ]]; then
  # extract the closest index values
  coordIdx="$(ncl -nQ 'coord_file='\"$domainFile\" 'minlat='"$minLat" 'maxlat='"$maxLat" 'minlon='"$minLon" 'maxlon='"$maxLon" "$coordClosestIdxScript")"
fi

# parse the output index for latitude and longitude
lonLimsIdx+="$(echo $coordIdx | cut -d ' ' -f 1)"
latLimsIdx+="$(echo $coordIdx | cut -d ' ' -f 2)"

# reload necessary modules
unload_ncl_module
load_core_modules

# ============================================
# Build date arrays for time-series extraction
# ============================================
# file date intervals in years - dataset's default
interval=4

startFormat="%Y0101"
endFormat="%Y1231" # will be redefined later depending on the $modelName

actualFormat='%Y%m%d'

# define needed variables
let "difference = $endYear - $startYear"
let "steps = $difference / $interval"

# build $startDateFileArr, $endDateFileArr
startDateFileArr=()
endDateFileArr=()

# range of jumps
range=$(seq 0 $steps)

# filling the arrays
for iter in $range; do
  # jumps every $interval years
  let "jumps = $iter * $interval"

  # current date after necessary jumps
  let "toDate = $jumps + $startYear"

  # extract start and end values
  startValue="$(date --date "${toDate}0101" +"${startFormat}")"
  endValue="$(date --date "${toDate}0101 +${interval}years -1days" +"${endFormat}")"

  # check if endValue is beyond 2100
  endValueYear="$(date --date "${endValue}" +"%Y")"
  # double-check end-date
  if [[ "$endValueYear" -gt 2100 ]]; then
    endValue="21001231" # irregular last date for dataset files
  fi

  # fill up relevant arrays
  startDateFileArr+=("${startValue}")
  endDateFileArr+=("${endValue}")

done

# build actualStartArr array for temporal subsetting
actualStartDateArr=("${startDateFileArr[@]}")
actualStartDateArr[0]="$(date --date "${startDate}" +"${actualFormat}")"

# and similarly, the actualEndArr array
actualEndDateArr=("${endDateFileArr[@]}")
lastIndex=$(( "${#actualEndDateArr[@]}" - 1 ))
actualEndDateArr[${lastIndex}]="$(date --date "${endDate}" +"${actualFormat}")"


# =====================
# Extract dataset files
# =====================
# Typical directory structure of the dataset is:
#   ${datasetDir}/${model}/%submodel/${scenario}/${ensemble}/day/${var}/
# and each ${var} directory contains files in the following nomenclature:
#   ${var}_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_${model}_%submodel_${scenario}_${ensemble}_%yyyymmdd-%yyyymmdd.nc
# with the former date value indicating the starting year of data inside the
# file, and the latter demonstrating the ending date of data
#
# NOTE: %submodel must be determined in the upstream caller
#

# create dataset directories in $cache and $outputDir
echo "$(logDate)$(basename $0): creating output directory under $outputDir"
mkdir -p "$outputDir"
echo "$(logDate)$(basename $0): creating cache directory under $cache"
mkdir -p "$cache"

# iterate over models/submodels
for model in "${modelArr[@]}"; do
  # extract model and submodel names
  modelName=$(echo $model | cut -d '/' -f 1)
  submodelName=$(echo $model | cut -d '/' -f 2)

  # iterate over scenarios, e.g., ssp245, ssp370, ssp585 
  for scenario in "${scenarioArr[@]}"; do

    # iterate over ensemble members, e.g., r1p1, r1p2, etc.
    for ensemble in "${ensembleArr[@]}"; do

      pathTemplate="${modelName}/${submodelName}/${scenario}/${ensemble}/day/"
      if [[ -e "${datasetDir}/${pathTemplate}" ]]; then
        echo "$(logDate)$(basename $0): processing ${model}.${scenario}.${ensemble} files"
        mkdir -p "${cache}/${pathTemplate}"
        mkdir -p "${outputDir}/${pathTemplate}"
      else
        echo "$(logDate)$(basename $0): ERROR! ${model}.${scenario}.${ensemble} does not exist."
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
        actualStartDateFormatted="$(date --date $actualStartDate +'%Y-%m-%d')"
        actualEndDateFormatted="$(date --date $actualEndDate +'%Y-%m-%d')"

        # destination NetCDF file
        dst="day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_${modelName}_${submodelName}_${scenario}_${ensemble}_${actualStartDate}-${actualEndDate}.nc"

        # address inconsistencies with NetCDF file end-date values in the
        # dataset
        if [[ "$modelName" == "NIMS-KMA" ]] || \
		   [[ "$modelName" == "MOHC" ]]; then
           fileEndDate=$(date --date "${fileEndDate}" +"%Y1230")
        fi

        # iterate over dataset variables of interest
        for var in "${variableArr[@]}"; do

          # define file for further operation
          # address inconsistencies with NetCDF file name in the dataset
          if [[ "$modelName" == "DKRZ" ]]; then
            src="${var}_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_MPI-M_${submodelName}_${scenario}_${ensemble}_${fileStartDate}-${fileEndDate}.nc"
          else
            src="${var}_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_${modelName}_${submodelName}_${scenario}_${ensemble}_${fileStartDate}-${fileEndDate}.nc"
          fi

          # spatial subsetting
          until ncks -A -v ${var} \
                     -d "$latDim","${latLimsIdx}" \
                     -d "$lonDim","${lonLimsIdx}" \
                     -d "$timeDim","${actualStartDateFormatted}","${actualEndDateFormatted}" \
                     ${datasetDir}/${pathTemplate}/${var}/${src} \
                     ${cache}/${pathTemplate}/${dst}; do
                echo "$(logDate)$(basename $0): Process killed: restarting process in 10 sec" >&2
                echo "NCKS failed" >&2
                sleep 10;
          done # until ncks
        done # for $variableArr

        # change lon values so the extents are from ~-180 to 0
        # this is solely for easymore compatibility
        until ncap2 -O -s "where(lon>0) lon=lon-360" \
                    "${cache}/${pathTemplate}/${dst}" \
                    "${outputDir}/${pathTemplate}/${prefix}${dst}"; do
              echo "$(logDate)$(basename $0): Process killed: restarting process in 10 sec" >&2
              echo "NCAP2 failed" >&2
              sleep 10;
        done # until ncap2

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

