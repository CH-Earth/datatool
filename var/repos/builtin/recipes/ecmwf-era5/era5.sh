#!/bin/bash
# Meteorological Data Processing Workflow
# Copyright (C) 2022-2023, University of Saskatchewan
# Copyright (C) 2023-2023, University of Calgary
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
# 2. Drs. Gouqiang Tang and Wouter Knoben provided the downloaded ERA5 dataset files


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
    -t | --time-scale)    timeScale="$2"       ; shift 2 ;; # required
    -l | --lat-lims)      latLims="$2"         ; shift 2 ;; # required
    -n | --lon-lims)      lonLims="$2"         ; shift 2 ;; # required
    -p | --prefix)	      prefix="$2"          ; shift 2 ;; # optional
    -c | --cache)         cache="$2"           ; shift 2 ;; # required
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
if [[ -n "$ensemble" ]] || \
   [[ -n "$scenario" ]] || \
   [[ -n "$model" ]]; then
  echo "ERROR $(basename $0): redundant argument provided";
  exit 1;
fi

# check the prefix of not set
if [[ -z $prefix ]]; then
  prefix="data_"
fi


# ==========================
# Necessary global variables
# ==========================
# the structure of file names is as follows: "ERA5_merged_YYYYMM.nc"
era5Format="%Y%m" # era5 file date format
reportFormat="%Y-%m-%d %H:%M:%S" # report format for manupulations
exportFormat="%Y-%m-%d_%H:%M:%S" # exported file date format
fileStruct="ERA5_merged" # source dataset files' prefix constant


# =================
# Useful one-liners
# =================
#calcualte Unix EPOCH time in seconds from 1970-01-01 00:00:00
unix_epoch () { date --date="$@" +"%s"; }

#format date string
format_date () { date --date="$1" +"$2"; }

#check whether the input is float or real
check_real () { if [[ "$1" == *'.'* ]]; then echo 'float'; else echo 'int'; fi; }

#convert to float if the number is 'int'
to_float () { if [[ $(check_real $1) == 'int' ]]; then printf "%.1f" "$1"; echo; else printf "$1"; echo; fi; }

#join array element by the specified delimiter
join_by () { local IFS="$1"; shift; echo "$*"; }

#to_float the latLims and lonLims, real numbers delimited by ','
lims_to_float () { IFS=',' read -ra l <<< $@; f_arr=(); for i in "${l[@]}"; do f_arr+=($(to_float $i)); done; echo $(join_by , "${f_arr[@]}"); }


#######################################
# extracts file name, date, and time 
# from CONUSI file name strings.
#
# Globals:
#   fileName: file name of the .nc data
#   fileNameDate: date (YYYYMM)
#   fileNameYear: year (YYYY)
#   fileNameMonth: month (MM)
#
# Arguments:
#   1: -> fName: the 
#
# Outputs:
#   produces the following global
#   variables:
#    a) fileName
#    b) fileNameDate
#    c) fileNameYear
#    d) fileNameMonth
#######################################
function extract_filename_info () {
  
  # define local variable for input argument
  local fPath="$1" # format: "/path/to/file/ERA5_merged_YYYYMM.nc"
  
  # file name
  fileName="$(basename $fPath | cut -d '.' -f 1)" # file name
  
  # file date
  fileNameDate="$(echo "$fileName" | cut -d '_' -f 3)" # file date (YYYYMM)
  
  # year part of the date
  fileNameYear="$(echo "$fileNameDate" | cut -c 1-4)" # file year (YYYY)
}


######################################
# populating an array of dates based
# on the input format and time-step
# ranged between the start and end
# points
#
# Globals:
#   dateRangeArr: array of dates
#
# Arguments:
#   1: start date
#   2: end date
#   3: format string parsable by `date`
#   4: time-step, e.g., "1hour"
#
# Outputs:
#   produces the following variables:
#    5) dateRangeArr
#######################################
function date_range () {
  local start=$1    # start date
  local end=$2      # end date
  local fmt=$3      # format of the ouput dates
  local tstep=$4    # the time-step value parsable by bash `date`

  local curr=$start # current time-step

  # make Unix EPOCH time 
  local currUnix="$(unix_epoch "$curr")"
  local endUnix="$(unix_epoch "$end")"

  # a global array variable
  dateRangeArr=()

  while [[ "$currUnix" -le "$endUnix" ]]; do
    dateRangeArr+=("$(format_date "$curr" "$fmt")")
    curr="$(date --date="${curr} ${tstep}")"
     
    # update $currUnix for the `while` loop
    currUnix="$(unix_epoch "$curr")"
  done
}


#######################################
# end of a chosen time-frame minus
# the value of the time-step, e.g.,
#   1. end of the year date based on
#      hourly time-steps
#   2. end of the month based on daily
#      time-steps
#
# Globals:
#   None
#
# Arguments:
#   1. dateStr
#   2. time-frame, i.e., year, mmonth, 
#			 day, hour
#      (parsable by GNU date)
#   3. time-step, i.e., year, month, 
#			day, hour
#      (parsable by GNU date)
#
# Outputs:
#   prints the end of the time-frame
#   at the last time-step to the stdout
#######################################
function time_frame_end () {
  local dateStr=$1	# date string
  local timeFrame=$2	# time-frame
  local timeStep=$3	# time-step
  local fmt=$4		# date format

  local dateStrTrim     # date string variable
  local endDateStr	# end date string

  # calculte the last time-step included in the file
  # based on the timeframe of the files;
  # e.g., ERA5_199201.nc indicates a monthly of that
  # has hourly data (ERA5 is hourly).
  case "${timeFrame,,}" in
    year)
      dateStrTrim=$(format_date "$dateStr" "%Y-01-01 00:00:00")
      ;;
    month)
      dateStrTrim=$(format_date "$dateStr" "%Y-%m-01 00:00:00")
      ;;
    day)
      dateStrTrim=$(format_date "$dateStr" "%Y-%m-%d 00:00:00")
      ;;
    hour)
      dateStrTrim=$(format_date "$dateStr" "%Y-%m-%d %H:00:00")
      ;;
  esac
  
  local endDateStr="$(date --date="${dateStrTrim} 1${timeFrame} -1${timeStep}" +"$fmt")"
  echo $endDateStr
}


#######################################
# splitting netCDF files based on the 
# tsValue
#
# Globals:
#   None
#
# Arguments:
#    1: start date
#    2: end date
#    3: time variable name
#    4: source file path
#    5: destination path
#    6: prefix file string
#    7: date format
#    8: time frame
#    9: time steps
# 
# Outputs:
#    it splits the netcdf files based
#    on the time-steps (argument #9)
#
#######################################
function split_ts () {
  # assign local variables
  local start=$1	 # start date
  local end=$2		 # end date
  local timeVar=$3	 # time variable
  local sourceFile=$4	 # source file
  local destDir=$5	 # destination directory
  local filePrefix=$6	 # file prefix
  local dateFmt=$7	 # date format
  local timeFrame=$8	 # time frame:
  			 # month, day, etc.
  local timeStep=$9	 # time step length
  
  # local variables used in the while loop
  local tBegin="$(format_date "$start" "$dateFmt")"
  local tEnd

  while [[ "$(unix_epoch "$tBegin")" -le "$(unix_epoch "$end")" ]]; do
    tEnd=$(time_frame_end "$tBegin" "$timeFrame" "$timeStep" "$dateFmt")

    if [[ $(unix_epoch "$tEnd") -gt $(unix_epoch "$end") ]]; then
      tEnd="$end"
    fi

    exportDate="$(format_date "$tBegin" "$exportFormat")"
    ncks -d "$timeVar","$tBegin","$tEnd" \
    	 -d latitude,"$(lims_to_float $latLims)" \
    	 -d longitude,"$(lims_to_float $lonLims)" \
	 -v "$variables" \
	 "$sourceFile" "${destDir}/${filePrefix}-${exportDate}.nc"

    tBegin=$(date --date="${tEnd} 1${timeStep}" "+${dateFmt}")
  done
}


#######################################
# defining start and end point for the
# netcdf file of interest (era5).
#
# Globals:
#   None
#
# Arguments:
#   1: file date 
# 
# Outputs:
#   startPoint: start point of the time
#               frame
#   endPoint: end point of the time
#             frame
#######################################
function define_time_points () {
  
  local fDate=$1

  local startPoint
  local endPoint
  local endOfCurrentMonthUnix
  local endPoinUnix

  # check dates
  if [[ "$fDate" -eq "$(format_date "$startDate" "$era5Format")" ]]; then
    endOfCurrentMonthUnix="$(time_frame_end "${fDate}01" "month" "hour" "%s")" # end of month in Unix EPOCH time
    if [[ "$endOfCurrentMonthUnix" -le "$(unix_epoch "$endDate")" ]]; then
      endPointUnix="$endOfCurrentMonthUnix"
    else
      endPointUnix="$(unix_epoch "$endDate")"
    fi
    startPoint="$(format_date "$startDate" "$reportFormat")"
    endPoint="$(format_date "@$endPointUnix" "$reportFormat")"
      
  elif [[ "$fDate" -eq "$(format_date "$endDate" "$era5Format")" ]]; then
    startPoint="$(format_date "${fDate}01" "$reportFormat")"
    endPoint="$(format_date "${endDate}" "$reportFormat")"

  else
    startPoint="$(format_date "${fDate}01" "$reportFormat")"
    endPoint="$(time_frame_end "${fDate}01" "month" "hour" "$reportFormat")"

  fi

  timePoints=("$startPoint" "$endPoint")
}


# ===============
# Data Processing
# ===============
# display info
echo "$(basename $0): processing ECMWF ERA5..."

# extract the dates using `date_range` function -> dateRangeArr
date_range "$startDate" "$endDate" "$era5Format" "1hour" # tstep is hard-coded for ERA5
# extract unique values from $dateRangeArr
uniqueDatesArr=($(echo "${dateRangeArr[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '));

# creating a temporary directory for temporary files
echo "$(basename $0): creating cache files in $HOME/.temp_gwfdata"
mkdir -p "$cache" # making the directory

# copy necessary files to the $cache
for ym in "${uniqueDatesArr[@]}"; do
  cp "${datasetDir}/${fileStruct}_${ym}.nc" "${cache}/${fileStruct}_${ym}.nc"
done

# make the output directory
mkdir -p "$outputDir"

# define empty global array for start and end timePoints
timePoints=() # 0: startPoint, 1: endPoint

# data files for the current year with extracted $variables
files=($cache/*)

# if yearly timeScale then make an empty yearsArr
if [[ "${timeScale,,}" == "y" ]]; then
  yearsArr=()
  datesArr=()
fi

for f in "${files[@]}"; do
  extract_filename_info "$f" # extract file name info
  define_time_points "$fileNameDate" # define start & end time points for subsetting
  
  case "${timeScale,,}" in
    h)
      split_ts "${timePoints[0]}" "${timePoints[1]}" "time" "$f" "$outputDir" "$prefix" "$reportFormat" "hour" "hour"
      ;;

    d)
      split_ts "${timePoints[0]}" "${timePoints[1]}" "time" "$f" "$outputDir" "$prefix" "$reportFormat" "day" "hour"
      ;;

    m)
      exportDate="$(format_date "${timePoints[0]}" "$exportFormat")"

      monthStart="$(format_date "${fDate}01" "$reportFormat")"
      monthEnd="$(time_frame_end "${fDate}01" "month" "hour" "$reportFormat")"
      if [[ "$monthStart" == "${timePoints[0]}" && "$monthEnd" == "${timePoints[1]}" ]]; then
	ncks -d latitude,$(lims_to_float "$latLims") \
	     -d longitude,$(lims_to_float "$lonLims") \
	     -v "$variables" \
	     "$f" "${outputDir}/${prefix}-${exportDate}.nc"
      
      else
	ncks -d time,"${timePoints[0]}","${timePoints[1]}" \
	     -d latitude,$(lims_to_float $latLims) \
	     -d longitude,$(lims_to_float $lonLims) \
	     -v "$variables" \
	     "$f" "${outputDir}/${prefix}-${exportDate}.nc"

      fi
      ;;

    y)
      yearsArr+=("$fileNameYear")
      exportDate="$(format_date "${timePoints[0]}" "$exportFormat")"
      datesArr+=("$exportDate")

      monthStart="$(format_date "${fDate}01" "$reportFormat")"
      monthEnd="$(time_frame_end "${fDate}01" "month" "hour" "$reportFormat")"
      if [[ "$monthStart" == "${timePoints[0]}" && "$monthEnd" == "${timePoints[1]}" ]]; then
	ncks -d latitude,$(lims_to_float "$latLims") \
	     -d longitude,$(lims_to_float "$lonLims") \
	     -v "$variables" \
	     --mk_rec_dmn time \
	     -O \
	     "$f" "$f"

      else
	ncks -d time,"${timePoints[0]}","${timePoints[1]}" \
	     -d latitude,$(lims_to_float $latLims) \
	     -d longitude,$(lims_to_float $lonLims) \
	     -v "$variables" \
	     -O \
	     --mk_rec_dmn time \
	     "$f" "$f"
 
      fi
      ;;

  esac
done

if [[ "${timeScale,,}" == "y" ]]; then
  # make an array of unique years
  uniqueYearsArr=($(echo "${yearsArr[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

  for yr in "${uniqueYearsArr[@]}"; do
    # get the first exportDate of each year
    idx=0
    for str in "${datesArr[@]}"; do
      if [[ "$yr" == $(echo "$str" | cut -d '-' -f 1) ]]; then
	break
      else
	idx=$(($idx + 1))
      fi
    done

    exportDate="${datesArr[$idx]}"
    ncrcat ${cache}/*${yr}* "${outputDir}/${prefix}-${exportDate}.nc"
  done
fi

rm -r $cache # removing the temporary directory
echo "$(basename $0): temporary files from $cache are removed."
echo "$(basename $0): results are produced under $outputDir."

