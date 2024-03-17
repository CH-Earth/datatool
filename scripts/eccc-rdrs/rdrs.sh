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
# 1. Parts of the code are taken from 
#    https://www.shellscript.sh/tips/getopt/index.html


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
  echo "usage: $(basename $0) [-cio DIR] [-v VARS] [-se DATE] [-t CHAR] [-ln REAL,REAL] [-p STR]"
}


# argument parsing using getopt - WORKS ONLY ON LINUX BY DEFAULT
parsedArguments=$(getopt -a -n rdrs -o i:v:o:s:e:t:l:n:p:c:m:S:M: --long dataset-dir:,variable:,output-dir:,start-date:,end-date:,time-scale:,lat-lims:,lon-lims:,prefix:,cache:,ensemble:,scenario:,model: -- "$@")
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
    -p | --prefix)	      prefix="$2"          ; shift 2 ;; # optional
    -c | --cache)         cache="$2"           ; shift 2 ;; # required
    -m | --ensemble)      ensemble="$2"        ; shift 2 ;; # redundant - added for compatibility
    -S | --scenario)      scenario="$2"        ; shift 2 ;; # redundant - added for compatibility
    -M | --model)         model="$2"           ; shift 2 ;; # redundant - added for compatibility

    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;

    # in case of invalid option
    *)
      echo "ERROR $(basename $0): invalid option '$1'";
      short_usage; exit 1 ;;
  esac
done

# useful log date format function
logDate () { echo "($(date +"%Y-%m-%d %H:%M:%S")) "; }

# check if $ensemble is provided
if [[ -n "$ensemble" ]] || \
   [[ -n "$scenario" ]] || \
   [[ -n "$model" ]]; then
  echo "$(logDate)$(basename $0): ERROR! redundant argument provided";
  exit 1;
fi

# check the prefix of not set
if [[ -z $prefix ]]; then
  prefix="data_"
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
# the structure of file names is as follows: "YYYYMMDD12.nc"
rdrsFormat="%Y%m%d" # rdrs file date format
exportFormat="%Y%m%d" # exported file date format
fileStruct="" # source dataset files' prefix constant

latDim="rlat"
lonDim="rlon"


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
echo "$(logDate)$(basename $0): processing ECCC RDRSv2.1..."

# make the output directory
echo "$(logDate)$(basename $0): creating output directory under $outputDir"
mkdir -p "$outputDir"
echo "$(logDate)$(basename $0): creating cache directory under $cache"
mkdir -p "$cache"


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
domainFile="$(find "${datasetDir}/" -type f -name "*.nc" | head -n 1)"
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

# reload necessary modules
unload_ncl_module
load_core_modules


# =====================
# Extract dataset files
# =====================
# define necessary dates
startYear=$(date --date="$startDate" +"%Y") # start year (first folder)
endYear=$(date --date="$endDate" +"%Y") # end year (last folder)
yearsRange=$(seq $startYear $endYear)

toDate="$startDate"
toDateUnix="$(unix_epoch "$toDate")"
endDateUnix="$(unix_epoch "$endDate")"

for yr in $yearsRange; do
  # creating yearly directory
  mkdir -p "$outputDir/$yr" # output directory
  mkdir -p "$cache/$yr" # cache directory

  # setting the end point, either the end of current year, or the $endDate
  # last time-step of the current year
  endOfCurrentYearUnix=$(date --date="$yr-01-01 +1year -1day" "+%s")
  if [[ $endOfCurrentYearUnix -le $endDateUnix ]]; then
    endPointUnix=$endOfCurrentYearUnix
  else
    endPointUnix=$endDateUnix
  fi

  # extract variables from the forcing data files
  while [[ "$toDateUnix" -le "$endPointUnix" ]]; do
    # date manipulations
    # current timestamp formatted to conform to RDRS naming convention
    toDateFormatted=$(date --date "$toDate" +"$rdrsFormat")

    # creating file name
    file="${toDateFormatted}12.nc" # current file name
    
    # extracting variables from the files and spatial subsetting
    # assuring the process finished using an `until` loop
    until ncks -A -v ${variables} \
               -d "$latDim","${latLimsIdx}" \
               -d "$lonDim","${lonLimsIdx}" \
               ${datasetDir}/${yr}/${file} \
               ${cache}/${yr}/${file}; do
      echo "$(logDate)$(basename $0): Process killed: restarting process in 10 sec" >&2
      echo "NCKS [...] failed" >&2
      sleep 10;
    done # until ncks

    # remove any left-over .tmp file
    if [[ -e ${cache}/${yr}/${file}*.tmp ]]; then
      rm -r "${cache}/${yr}/${file}*.tmp"
    fi

    # wait for any left-over processes to finish
    wait

    # change lon values so the extents are from ~-180 to 0
    # assuring the process finished using an `until` loop
    until ncap2 -O -s 'where(lon>0) lon=lon-360' \
            "${cache}/${yr}/${file}" \
            "${outputDir}/${yr}/${prefix}${file}"; do
      rm "${outputDir}/${yr}/${prefix}${file}"
      echo "$(logDate)$(basename $0): Process killed: restarting process in 10 sec" >&2
      echo "$(logDate)$(basename $0): NCAP2 -s [...] failed" >&2
      sleep 10;
    done
 
    # remove any left-over .tmp file
    if [[ -e ${cache}/${yr}/${file}*.tmp ]]; then
      rm -r "${cache}/${yr}/${file}*.tmp"
    fi

    # wait for any left-over processes to finish
    wait

    # increment time-step by one unit
    toDate="$(date --date "$toDate 1day")" # current time-step
    toDateUnix="$(unix_epoch "$toDate")" # current timestamp in unix EPOCH time
  done

  # go to the next year if necessary
  if [[ "$toDateUnix" == "$endOfCurrentYearUnix" ]]; then
    toDate=$(date --date "$toDate 1day")
  fi

done

mkdir "$HOME/empty_dir"
echo "$(logDate)$(basename $0): deleting temporary files from $cache"
rsync -aP --delete "$HOME/empty_dir/" "$cache"
rm -r "$cache"
echo "$(logDate)$(basename $0): temporary files from $cache are removed"
echo "$(logDate)$(basename $0): results are produced under $outputDir"

