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
  echo "usage: $(basename $0) [-cio DIR] [-v VARS] [-se DATE] [-t CHAR] [-ln REAL,REAL] [-p STR]"
}


# argument parsing using getopt - WORKS ONLY ON LINUX BY DEFAULT
parsedArguments=$(getopt -a -n gdfl_cm4 -o i:v:o:s:e:t:l:n:p:c:m: --long dataset-dir:,variables:,output-dir:,start-date:,end-date:,time-scale:,lat-lims:,lon-lims:,prefix:,cache:,ensemble: -- "$@")
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
    -p | --prefix)        prefix="$2"	       ; shift 2 ;; # optional
    -c | --cache)         cache="$2"	       ; shift 2 ;; # redundant - added for compatibility
    -m | --ensemble)      ensemble="$2"        ; shift 2 ;; # required 

    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;

    # in case of invalid option
    *)
      echo "ERROR $(basename $0): invalid option '$1'";
      short_usage; exit 1 ;;
  esac
done

# check the prefix of not set
if [[ -z $prefix ]]; then
  prefix="data"
fi


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
format="%Y-%m-%dT%H:%M:%S" #  date format
filePrefix="Downscaled_GFDL-CM4_MBCDS" # source dataset files' suffix constant
fileSuffix="pr_tmn_tmx" # suffix before the date format

latVar="lat"
lonVar="lon"
timeVar="time"

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
to_float () { if [[ $(check_real $1) == 'int' ]]; then printf "%.1f" "$1"; echo; else printf "%.5f" "$1"; echo; fi; }

#join array element by the specified delimiter
join_by () { local IFS="$1"; shift; echo "$*"; }

#to_float the latLims and lonLims, real numbers delimited by ','
lims_to_float () { IFS=',' read -ra l <<< $@; f_arr=(); for i in "${l[@]}"; do f_arr+=($(to_float $i)); done; echo $(join_by , "${f_arr[@]}"); }

# log date format
log_date () { echo "($(date +"%Y-%m-%d %H:%M:%S")) "; }


# ===============
# Data Processing
# ===============
# display info
echo "$(log_date)$(basename $0): processing GDFL-CM4 dataset..."

# make the output directory
echo "$(log_date)$(basename $0): creating output directory under $outputDir"
mkdir -p "$outputDir"

# make array of ensemble members
if [[ -n "$ensemble" ]]; then
  IFS=',' read -ra ensembleArr <<< "$(echo "$ensemble")" # comma separated input
else
  # if nothing has been entred, throw an error and exit
  echo "$(log_date)$(basename $0): ERROR! --ensemble argument does not" \
  "have valid value(s)"
  # exit the script
  exit 1;
fi

# define necessary dates
startYear=$(date --date="$startDate" +"%Y") # start year
endYear=$(date --date="$endDate" +"%Y") # end year
yearsRange=$(seq $startYear $endYear)

# make variable string for output file creation
IFS=',' read -ra variablesArr <<< "$(echo "$variables")" # array for vars
varStr=$(join_by "_" "${variablesArr[@]}")

for member in "${ensembleArr[@]}"; do
  # creating yearly directory
  echo "$(log_date)$(basename $0):     processing member $member"

  # loop over years
  for yr in $yearsRange; do
    # extract variables and spatially and temporally subset
    ncks -O \
    	 -d "$latVar",$(lims_to_float "$latLims") \
  	 -d "$lonVar",$(lims_to_float "$lonLims") \
  	 -v "$variables" \
  	 "$datasetDir/${filePrefix}_${member}_${fileSuffix}_${yr}.nc" \
  	 "$outputDir/${prefix}${filePrefix}_${member}_${varStr}_${yr}.nc"
  done

  # wait to assure the `for` loop is finished
  wait

done

# printing final prompt
echo "$(log_date)$(basename $0): results are produced under $outputDir."

