#!/bin/bash
# Global Water Futures (GWF) Meteorological Data Processing Workflow
# Copyright (C) 2022, Global Water Futures (GWF), University of Saskatchewan
#
# This file is part of GWF Meteorological Data Processing Workflow
#
# For more information see: https://gwf.usask.ca/
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
# 2. Dr. Julie Mai provided the methodology to download data from CaSPAr data portal.


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
parsedArguments=$(getopt -a -n extract-dataset -o i:v:o:s:e:t:l:n:p:c:m: --long dataset-dir:,variables:,output-dir:,start-date:,end-date:,time-scale:,lat-lims:,lon-lims:,prefix:,cache:,ensemble: -- "$@")
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
    -t | --time-scale)    timeScale="$2"       ; shift 2 ;; # required
    -l | --lat-lims)      latLims="$2"         ; shift 2 ;; # required
    -n | --lon-lims)      lonLims="$2"         ; shift 2 ;; # required
    -p | --prefix)	      prefix="$2"          ; shift 2 ;; # optional
    -c | --cache)	      cache="$2"           ; shift 2 ;; # required
    -m | --ensemble)      ensemble="$2"        ; shift 2 ;; # redundant - added for compatibility

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
  prefix="data"
fi

# ==========================
# Necessary Global Variables
# ==========================
# the structure of file names is as follows: "YYYYMMDD12.nc"
rdrsFormat="%Y%m%d" # rdrs file date format
exportFormat="%Y%m%d" # exported file date format
fileStruct="" # source dataset files' prefix constant

latVar="rlat"
lonVar="rlon"

# ===================
# Necessary Functions
# ===================
# Modules below available on Compute Canada (CC) Graham Cluster Server
load_core_modules () {
    module -q load cdo/2.0.4
    module -q load nco/5.0.6
}
load_core_modules


#######################################
# useful one-liners
#######################################
#calcualte Unix EPOCH time in seconds from 1970-01-01 00:00:00
unix_epoch () { date --date="$@" +"%s"; }

#check whether the input is float or real
check_real () { if [[ "$1" == *'.'* ]]; then echo 'float'; else echo 'int'; fi; }

#convert to float if the number is 'int'
to_float () { if [[ $(check_real $1) == 'int' ]]; then printf "%.1f" "$1"; echo; else printf "$1"; echo; fi; }

#join array element by the specified delimiter
join_by () { local IFS="$1"; shift; echo "$*"; }

#to_float the latLims and lonLims, real numbers delimited by ','
lims_to_float () { IFS=',' read -ra l <<< $@; f_arr=(); for i in "${l[@]}"; do f_arr+=($(to_float $i)); done; echo $(join_by , "${f_arr[@]}"); }


# ===============
# Data Processing
# ===============
# display info
echo "$(basename $0): processing ECCC RDRSv2.1..."

# make the output directory
echo "$(basename $0): creating output directory under $outputDir"
mkdir -p "$outputDir"

# define necessary dates
startYear=$(date --date="$startDate" +"%Y") # start year (first folder)
endYear=$(date --date="$endDate" +"%Y") # end year (last folder)
yearsRange=$(seq $startYear $endYear)

toDate="$startDate"
toDateUnix="$(unix_epoch "$toDate")"
endDateUnix="$(unix_epoch "$endDate")"

for yr in $yearsRange; do
  # creating yearly directory
  mkdir -p "$outputDir/$yr" # making the output directory

  # setting the end point, either the end of current year, or the $endDate
  endOfCurrentYearUnix=$(date --date="$yr-01-01 +1year -1day" "+%s") # last time-step of the current year
  if [[ $endOfCurrentYearUnix -le $endDateUnix ]]; then
    endPointUnix=$endOfCurrentYearUnix
  else
    endPointUnix=$endDateUnix
  fi

  # extract variables from the forcing data files
  while [[ "$toDateUnix" -le "$endPointUnix" ]]; do
    # date manipulations
    toDateFormatted=$(date --date "$toDate" +"$rdrsFormat") # current timestamp formatted to conform to RDRS naming convention

    # creating file name
    file="${toDateFormatted}12.nc" # current file name

    # extracting variables from the files and spatial subsetting
    cdo -s -L -sellonlatbox,"$lonLims","$latLims" \
        -selvar,"$variables" \
        "${datasetDir}/${yr}/${file}" "${outputDir}/${yr}/${prefix}${file}"

    [ $( jobs | wc -l ) -ge $( nproc ) ] && wait # forking shell processes

    # increment time-step by one unit
    toDate="$(date --date "$toDate 1day")" # current time-step
    toDateUnix="$(unix_epoch "$toDate")" # current timestamp in unix EPOCH time
  done

  # go to the next year if necessary
  if [[ "$toDateUnix" == "$endOfCurrentYearUnix" ]]; then
    toDate=$(date --date "$toDate 1day")
  fi

done


echo "$(basename $0): results are produced under $outputDir."

