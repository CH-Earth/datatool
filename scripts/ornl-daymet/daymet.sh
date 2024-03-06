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
parsedArguments=$(getopt -a -n daymet -o i:v:o:s:e:t:l:n:p:c:m:S:M: --long dataset-dir:,variable:,output-dir:,start-date:,end-date:,time-scale:,lat-lims:,lon-lims:,prefix:,cache:,ensemble:,scenario:,model: -- "$@")
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


# =====================
# Necessary assumptions
# =====================
# TZ to be set to UTC to avoid invalid dates due to Daylight Saving
alias date='TZ=UTC date'

# expand aliases for the one stated above
shopt -s expand_aliases

# create $cache directory
mkdir -p $cache

# ==========================
# Necessary global variables
# ==========================
# the structure of file names is as follows: "YYYYMMDD12.nc"
daymetDateFormat="%Y" # Daymet dataset date format
daymetPrefixString="daymet_v4_daily" # source dataset files' prefix constant

# domains of the dataset files - for now, only "na" domain
domains=("na") #na: North America, pr: Peurto Rico, hi: Hawaii

# spatial 2-dimentional variable included in the dataset netCDF files
latVar="lat" # latitude variable
lonVar="lon" # longitude variable

# spatial dimension names included in the dataset netCDF files
latDim="y" # latitude dimension
lonDim="x" # longitude dimension

# paths
datatoolPath="$(dirname $0)/../../" # datatool's path
# daymet index scripts works on RDRSv2.1 grids as well
# and ESPO-G6-R2 has similar grid system as RDRSv2.1
coordIdxScript="$datatoolPath/assets/ncl_scripts/coord_daymet_idx.ncl"
coordClosestIdxScript="$datatoolPath/assets/ncl_scripts/coord_closest_daymet_idx.ncl"


# ===================
# Necessary functions
# ===================
# Modules below available on Compute Canada (CC) Graham Cluster Server
## core modules
function load_core_modules () {
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
# log date format
log_date () { echo "($(date +"%Y-%m-%d %H:%M:%S")) "; }

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

#maximum of a variable in a netcdf file
ncmax () { ncap2 -O -C -v -s "foo=${2}.max();print(foo)" ${1} "$cache/max_$(basename $1)" | cut -f 3- -d ' ' ; }

#minimum of a variable in a netcdf file
ncmin () { ncap2 -O -C -v -s "foo=${2}.min();print(foo)" ${1} "$cache/min_$(basename $1)" | cut -f 3- -d ' ' ; }

#minimum of comma delimited string
delim_min () { IFS=', ' read -r -a l <<< "$@"; printf "%s\n" "${l[@]}" | sort -n | head -n1; }

#maximum of comma delimited string
delim_max () { IFS=', ' read -r -a l <<< "$@"; printf "%s\n" "${l[@]}" | sort -n | tail -n1; }


#######################################
# compare float values using basic
# calculator, i.e., `bc`
#
# Arguments:
#   1: -> firstNum: first int/float
#   2: -> SecondNum: second int/float
#   3: -> operator: comparison operator
#######################################
function bc_compare () {
  # local variables
  local firstNum=$1
  local secondNum=$2
  local operator=$3

  # implement the comparison
  echo "$(bc <<< "$firstNum $operator $secondNum")"
}

#######################################
# print the full path of the `n`th file
# given the $parentDir and $wildcard
# variables
#
# Arguments:
#   1: -> parentDir: parent directory
#   2: -> wildcard: wildcard to use in 
#		    listing files
#   3: -> nth: nth file to return
#######################################
function nth_file () {
  # local variables
  local parentDir=$1
  local wildcard=$2
  local nth=$3

  local fileList
  
  # listing files
  fileList=($parentDir/*${wildcard}*)
  # printing nth file
  echo "${fileList[$nth]}"
}


# ===============
# Data Processing
# ===============
# display info
echo "$(log_date)$(basename $0): processing daymet v4 dataset..."

# make the output directory
echo "$(log_date)$(basename $0): creating output directory under $outputDir"
mkdir -p "$outputDir"

echo "$(log_date)$(basename $0): creating cache directory under $cache"
mkdir -p "$cache"

# define necessary dates
toDate="$startDate"
toDateUnix="$(unix_epoch "$toDate")"
endDateUnix="$(unix_epoch "$endDate")"

# create empty arrays for included domains and spatial limits
domainsCovered=() # domain strings
domainsLatIdx=() # latitude index
domainLonIdx=() # longitude index

# parse the upper and lower bounds of a given spatial limit
minLat=$(echo $latLims | cut -d ',' -f 1)
maxLat=$(echo $latLims | cut -d ',' -f 2)
minLon=$(echo $lonLims | cut -d ',' -f 1)
maxLon=$(echo $lonLims | cut -d ',' -f 2)

# load NCL module
load_ncl_module

# extract domains that are included in the given spatial limits
for domain in ${domains[@]}; do
  # select a representative file (2nd) for each domain
  domainFile=$(nth_file $datasetDir $domain 2)

  # check if the input spatial limits overlap with that of domain files
  if [[ $(bc_compare "$(delim_min $latLims)" "$(ncmax $domainFile $latVar)" "<=") -eq 1 ]] && \
     [[ $(bc_compare "$(delim_min $lonLims)" "$(ncmax $domainFile $lonVar)" "<=") -eq 1 ]] && \
     [[ $(bc_compare "$(delim_max $latLims)" "$(ncmin $domainFile $latVar)" ">=") -eq 1 ]] && \
     [[ $(bc_compare "$(delim_max $lonLims)" "$(ncmin $domainFile $lonVar)" ">=") -eq 1 ]]; then

    # extract the associated indices corresponding to latLims and lonLims
    coordIdx="$(ncl -nQ 'coord_file='\"$domainFile\" 'minlat='"$minLat" 'maxlat='"$maxLat" 'minlon='"$minLon" 'maxlon='"$maxLon" "$coordIdxScript")"
 
    # if spatial index out-of-bound, i.e., 'ERROR' is return
    if [[ "${coordIdx}" == "ERROR" ]]; then
      # extract the closest index values
      coordIdx="$(ncl -nQ 'coord_file='\"$domainFile\" 'minlat='"$minLat" 'maxlat='"$maxLat" 'minlon='"$minLon" 'maxlon='"$maxLon" "$coordClosestIdxScript")"
    fi

    # add covered domains
    domainsCovered+=($domain)

    # parse the output index for latitude and longitude
    lonLimsIdx+="$(echo $coordIdx | cut -d ' ' -f 1)"
    latLimsIdx+="$(echo $coordIdx | cut -d ' ' -f 2)"

    # add the limits to the relevant arrays
    domainsLatIdx+=("${latLimsIdx}")
    domainsLonIdx+=("${lonLimsIdx}")
    fi
done

# check if $domainsCovered is empty
if [[ "${#domainsCovered[@]}" -eq 0 ]]; then
  echo -n "$(log_date)$(basename $0): ERROR! The input spatial limits do not "
  echo "overlap with the dataset covered area. Try other extents."
  exit 1;
fi

# unload NCl module
unload_ncl_module

# load core modules again
load_core_modules

# make array of variable names
IFS=',' read -ra variablesArr <<< "$(echo "$variables")"

# status update
echo "$(log_date)$(basename $0): extracting daymet v4 netCDF files..."

# extract files given the time-series extents
while [[ "$toDateUnix" -le "$endDateUnix" ]]; do

  # date format adjustment 
  toDateFormatted=$(date --date "$toDate" +"$daymetDateFormat") 

  # for each overlapped domain
  for idx in $(seq 0 $(bc <<< "${#domainsCovered[@]} - 1")); do

    # for each variable
    for var in ${variablesArr[@]}; do

      # generating file name
      file="${daymetPrefixString}_${domainsCovered[$idx]}_${var}_${toDateFormatted}.nc"

      # extract $file
      ncks -O -d "$latDim","${domainsLatIdx[$idx]}" \
              -d "$lonDim","${domainsLonIdx[$idx]}" \
	      "${datasetDir}/${file}" "${outputDir}/${prefix}${file}"

    done # for var
  done # for domain's index

  # increment time-step by one unit
  toDate="$(date --date "$toDate 1year")" # current time-step
  toDateUnix="$(unix_epoch "$toDate")" # current timestamp in unix EPOCH time

done

# wait to assure the `while` loop is done
wait

# finalizing the workflow
mkdir "$HOME/empty_dir"
echo "$(basename $0): deleting temporary files from $cache"
rsync -aP --delete "$HOME/empty_dir/" "$cache"
rm -r "$cache"
echo "$(basename $0): temporary files from $cache are removed"
echo "$(basename $0): results are produced under $outputDir"

