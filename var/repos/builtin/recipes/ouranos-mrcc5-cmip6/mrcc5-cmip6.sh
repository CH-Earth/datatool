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
parsedArguments=$(getopt -a -n mrcc5-cmip6 -o i:v:o:s:e:t:l:n:p:c:m:S:M: --long dataset-dir:,variable:,output-dir:,start-date:,end-date:,time-scale:,lat-lims:,lon-lims:,prefix:,cache:,ensemble:,scenario:,model: -- "$@")
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
root="$(echo $(dirname $0) | grep -Po '(.*)(?=((/.*?){5})$)')"
# Ouranos MRCC5-CMIP6 index script
coordIdxScript="$root/etc/scripts/coord_mrcc5_idx.ncl"


# ==========================
# Necessary global variables
# ==========================
latDim="rlat"
lonDim="rlon"
timeDim="time"


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
echo "$(logDate)$(basename $0): processing Ouranos MRCC5-CMIP6..."

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

# choose a sample file as all files share the same grid
domainFile=$(find ${datasetDir} -type f -name "*.nc" | head -n 1)
# parse the upper and lower bounds of a given spatial limit
minLat=$(echo $latLims | cut -d ',' -f 1)
maxLat=$(echo $latLims | cut -d ',' -f 2)
minLon=$(echo $lonLims | cut -d ',' -f 1)
maxLon=$(echo $lonLims | cut -d ',' -f 2)

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

# =====================
# Extract dataset files
# =====================
# Typical directory structure of the dataset is:
#   ${datasetDir}/${model}/${scenario}/${ensemble}/CRCM5/v1-r1/1hr/${var}/%arbitraryVersion
# Some files come in two versions. The versioning seems to be arbitrary.
#
# Each ${var}/%arbitraryVersion directory contains files in the following nomenclature:
#   ${var}_NAM-12_${model}_${scenario}_${ensemble}_OURANOS_CRCM5_v1-r1_1hr_%yyyy010100%M_%yyyy123123%M.nc
# with the former date value indicating the starting year of data inside the
# file, and the latter demonstrating the ending date of data
#
# Build date arrays for time-series extraction
# file date intervals in years - dataset's default
interval=1

# range of jumps
range=$(seq $startYear $interval $endYear)

# date formats
subsetStartFormat="%Y-%m-%dT%H:00:00"
subsetEndFormat="%Y-%m-%dT%H:45:00"

# empty arrays
startDateArray=()
endDateArray=()

# extraction process for each year
for iter in $range; do
  # extract start and end values
  # if start year is included, make the end date accurate
  if [[ $startYear -eq $iter ]]; then
    startValue="$(date --date "${startDate}" +"${subsetStartFormat}")"
  else
    startValue="$(date --date "${iter}0101" +"${subsetStartFormat}")"
  fi

  # if end year is included, make the end date accurate
  if [[ "$endYear" -eq "$iter" ]]; then
    endValue="$(date --date "${endDate}" +"${subsetEndFormat}")"
  else
    endValue="$(date --date "${iter}0101 +1years -30minutes" +"${subsetEndFormat}")"
  fi

  # check if endValue is beyond 2100
  endValueYear="$(date --date "${endValueSub}" +"%Y")"
  # double-check end-date
  if [[ "$endValueYear" -gt 2100 ]]; then
    endValue="2100-12-31T23:45:00" # irregular last date for dataset files
  fi

  # fill up arrays
  startDateArray+=($startValue)
  endDateArray+=($endValue)
done

# create dataset directories in $cache and $outputDir
echo "$(logDate)$(basename $0): creating output directory under $outputDir"
mkdir -p "$outputDir"
echo "$(logDate)$(basename $0): creating cache directory under $cache"
mkdir -p "$cache"

# iterate over models/submodels
for modelMember in "${modelArr[@]}"; do

  # iterate over scenarios, e.g., ssp245, ssp370, ssp585 
  for scenarioMember in "${scenarioArr[@]}"; do

    # iterate over ensemble members, e.g., r1p1, r1p2, etc.
    for ensembleMember in "${ensembleArr[@]}"; do

      # template: ${datasetDir}/${scenarioMember}/${ensembleMember}/CRCM5/v1-r1/1hr/${var}/%arbitraryVersion
      pathTemplate="${modelMember}/${scenarioMember}/${ensembleMember}/CRCM5/v1-r1/1hr/"
      if [[ -e "${datasetDir}/${pathTemplate}" ]]; then
        echo "$(logDate)$(basename $0): processing ${modelMember}.${scenarioMember}.${ensembleMember} files"
      else
        echo "$(logDate)$(basename $0): WARNING! Skipping ${modelMember}.${scenarioMember}.${ensembleMember} as it does not exist."
        continue;
      fi

      # iterate over date range of interest using index
      for idx in "${!startDateArray[@]}"; do
        # defind the file year and dates (for nomenclature)
        fileYear="$(date --date "${startDateArray[$idx]}" +"%Y")"
        fileStartDate="$(date --date "${startDateArray[$idx]}" +"%Y%m%d%H%M")"
        fileEndDate="$(date --date "${endDateArray[$idx]}" +"%Y%m%d%H00")"

        # if historical scenarioMember is being analyzed, the last year of
        # analysis is 2014 and the first year is only 1950
        if [[ "${scenarioMember}" == *"historical"* ]]; then
          if [[ "$fileYear" -gt 2014 ]] ||
             [[ $fileYear -lt 1950 ]]; then
            echo "$(logDate)$(basename $0): WARNING! $fileYear is skipped for $scenarioMember"
            continue;
          fi
        fi        
        # if ssp scenarios are being analyzed, the last year of analysis
        # is 2100 and the first year is 2015
        if [[ "${scenarioMember}" == *"ssp"* ]]; then
          if [[ $fileYear -gt 2100 ]] ||
             [[ $fileYear -lt 2015 ]]; then
            echo "$(logDate)$(basename $0): WARNING! $fileYear is skipped for $scenarioMember"
            continue;
          fi
        fi

        # iterate over dataset variables of interest
        for var in "${variableArr[@]}"; do
          # find the source file
          src="$(find ${datasetDir}/${pathTemplate}/${var}/ -type f -name "*${fileYear}0101*")"
          if [[ -z "$src" ]]; then
            echo "$(logDate)$(basename $0): ERROR! ${fileYear} file not found in ${datasetDir}/${pathTemplate}/${var}/"
            exit 1;
          fi

          # destination NetCDF file
          # template: ${var}_NAM-12_${modelMember}_${scenarioMember}_${ensembleMember}_OURANOS_CRCM5_v1-r1_1hr_%yyyy010100%M_%yyyy123123%M.nc
          dst="${var}_NAM-12_${modelMember}_${scenarioMember}_${ensembleMember}_OURANOS_CRCM5_v1-r1_1hr_${fileStartDate}-${fileEndDate}.nc"

          # create destination and cache directory
          mkdir -p "${outputDir}/${pathTemplate}/${var}"
          mkdir -p "${cache}/${pathTemplate}/${var}"

          # spatial subsetting
          until ncks -A -v ${var} \
                     -d "$latDim","${latLimsIdx}" \
                     -d "$lonDim","${lonLimsIdx}" \
                     -d "$timeDim","${startDateArray[$idx]}","${endDateArray[$idx]}" \
                     "${src}" \
                     "${cache}/${pathTemplate}/${var}/${dst}"; do
                echo "$(logDate)$(basename $0): Process killed: restarting process in 10 sec" >&2
                echo "$(logDate)$(basename $0): NCKS failed" >&2
                sleep 10;
          done # until ncks

          # statement for ncap2
          # some scenarios and variable have time-stamps at the middle of
          # the hours, rather than the top. The following lines can take
          # care of these hiccups.
          # minute="$(date --date "$(ncks --dt_fmt=1 --cal -v time -C --jsn "${src}" | jq -r ".variables.time.data[0]")" +"%M")"

          # if [[ "$minute" == "30" ]] ||
          #    [[ "$minute" == "29" ]]; then
          #   ncap2Statement="where(lon>0) lon=lon-360; time=time-1.0/48.0" # shift for half an hour (1/48th of a day)
          # else
          #   ncap2Statement="where(lon>0) lon=lon-360;" # no shift required
          # fi

          # change lon values so the extents are from ~-180 to 0
          # this is solely for easymore compatibility
          until ncap2 -O -s "${ncap2Statement}" \
                      "${cache}/${pathTemplate}/${var}/${dst}" \
                      "${outputDir}/${pathTemplate}/${var}/${prefix}${dst}"; do
                echo "$(logDate)$(basename $0): Process killed: restarting process in 10 sec" >&2
                echo "$(logDate)$(basename $0): NCAP2 failed" >&2
                sleep 10;
          done # until ncap2
        done # for $variableArr
      done # for $startDateArray
    done # for $ensembleArr
  done # for $scenarioArr
done # for $modelArr

# wait for everything to finish - just in case
sleep 10

mkdir -p "$HOME/empty_dir"
echo "$(logDate)$(basename $0): deleting temporary files from $cache"
rsync -aP --delete "$HOME/empty_dir/" "$cache"
rm -r "$cache"
echo "$(logDate)$(basename $0): temporary files from $cache are removed"
echo "$(logDate)$(basename $0): results are produced under $outputDir"

