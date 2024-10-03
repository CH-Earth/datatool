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
# 2. Drs. Quoqiang Tang and Wouter Knoben downloaded, pre-processed, and 
#    produced relevant associated scripts.


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
  echo "usage: $(basename $0) [-cio DIR] [-v VARS] [-se DATE] [-t CHAR] [-ln REAL,REAL] [-p STR]"
}


# argument parsing using getopt - WORKS ONLY ON LINUX BY DEFAULT
parsedArguments=$(getopt -a -n era5 -o i:v:o:s:e:t:l:n:p:c:m:S:M: --long dataset-dir:,variables:,output-dir:,start-date:,end-date:,time-scale:,lat-lims:,lon-lims:,prefix:,cache:,ensemble:,scenario:,model: -- "$@")
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
    -v | --variables)     variables="$2"       ; shift 2 ;; # required
    -o | --output-dir)    outputDir="$2"       ; shift 2 ;; # required
    -s | --start-date)    startDate="$2"       ; shift 2 ;; # required
    -e | --end-date)      endDate="$2"         ; shift 2 ;; # required
    -t | --time-scale)    timeScale="$2"       ; shift 2 ;; # redundant - added for compatibility
    -l | --lat-lims)      latLims="$2"         ; shift 2 ;; # required
    -n | --lon-lims)      lonLims="$2"         ; shift 2 ;; # required
    -p | --prefix)        prefix="$2"          ; shift 2 ;; # optional
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

# check if $ensemble is provided
if [[ -n "$ensemble" ]]; then
  echo "ERROR $(basename $0): redundant argument (ensemble) provided";
  exit 1;
fi

# check the prefix of not set
if [[ -z $prefix ]]; then
  prefix="data_"
fi

# useful log date format function
logDate () { echo "($(date +"%Y-%m-%d %H:%M:%S")) "; }

# =====================
# Necessary assumptions
# =====================
# TZ to be set to UTC to avoid invalid dates due to Daylight Saving
alias date='TZ=UTC date'

# expand aliases for the one stated above
shopt -s expand_aliases


# ==========================
# Necessary global variables
# ==========================
# the structure of file names is as follows: "ERA5_merged_YYYYMM.nc"
era5Format="%Y%m" # era5 file date format
fileStruct="ERA5_merged" # source dataset files' prefix constant

latVar="latitude"
lonVar="longitude"


# ===================
# Necessary functions
# ===================
# Modules below available on Compute Canada (CC) Graham Cluster Server
function load_core_modules () {
  module -q load StdEnv/2020
  module -q load gcc/9.3.0
  module -q load cdo/2.0.4
  module -q load nco/5.0.6
}
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
echo "$(logDate)$(basename $0): processing ECMWF ERA5..."

# make the output directory
echo "$(logDate)$(basename $0): creating output directory under $outputDir"
mkdir -p "$outputDir"

# take care of dates
toDate="$startDate"
toDateUnix="$(unix_epoch "$toDate")"
endDateUnix="$(unix_epoch "$endDate")"

# parse the upper and lower bounds of a given spatial limit
minLat=$(lims_to_float $latLims | cut -d ',' -f 1)
maxLat=$(lims_to_float $latLims | cut -d ',' -f 2)
minLon=$(lims_to_float $lonLims | cut -d ',' -f 1)
maxLon=$(lims_to_float $lonLims | cut -d ',' -f 2)

# adding/subtracting 0.1 degree to/from max/min values
minLat=$(bc <<< "$minLat - 0.25")
maxLat=$(bc <<< "$maxLat + 0.25")
minLon=$(bc <<< "$minLon - 0.25")
maxLon=$(bc <<< "$maxLon + 0.25")

# creating yearly directory
mkdir -p "$outputDir" # making the output directory

# extract variables from the forcing data files
while [[ "$toDateUnix" -le "$endDateUnix" ]]; do
  # date manipulations
  toDateFormatted=$(date --date "$toDate" +"$era5Format") # current timestamp formatted to conform to CONUSI naming convention

  # creating file name
  file="${fileStruct}_${toDateFormatted}.nc" # current file name

  # wait to be trapped
  trap 'wait' CHLD

  # extracting variables from the files and spatial subsetting
  (ncks -O -v "$variables" \
       -d latitude,"${minLat},${maxLat}" \
       -d longitude,"${minLon},${maxLon}" \
       "${datasetDir}/${file}" "${outputDir}/${prefix}${file}") &

  # make sure ncks finishes
  wait $!

  # increment time-step by one unit
  toDate="$(date --date "$toDate 1month")" # current time-step
  toDateUnix="$(unix_epoch "$toDate")" # current timestamp in unix EPOCH time
done

# wait to make sure the while loop is finished
wait

# go to the next year if necessary
if [[ "$toDateUnix" == "$endOfCurrentYearUnix" ]]; then
  toDate=$(date --date "$toDate 1month")
fi

# exit message
echo "$(logDate)$(basename $0): results are produced under $outputDir."

