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
# 2. Dr. Gouqiang Tang provided the downloaded ERA5 dataset files


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
  echo "usage: $(basename $0) [-io DIR] [-v VARS] [-se DATE] [-t CHAR] [-ln REAL,REAL] [-p STR]"
}

# argument parsing using getopt - WORKS ONLY ON LINUX BY DEFAULT
parsedArguments=$(getopt -a -n extract-dataset -o i:v:o:s:e:t:l:n: --long dataset-dir:,variables:,output-dir:,start-date:,end-date:,time-scale:,lat-lims:,lon-lims:, -- "$@")
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
    -p | --prefix)	  prefix="$2"	       ; shift 2 ;; # optional

    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;

    # in case of invalid option
    *)
      echo "ERROR $(basename $0): invalid option '$1'";
      short_usage; exit 1 ;;
  esac
done


# ===================
# Necessary Functions
# ===================
# Modules below available on Compute Canada (CC) Graham Cluster Server
module load cdo/2.0.4
module load nco/5.0.6

########################################
# useful one-liners
#######################################
unix_epoch { date --date="$@" "+%s"; } # calculate Unix EPOCH time

ts_index { "$(( ($1-$2)/($3)+1  ))";  } # $1: ts in seconds
					# $2: initial ts
					# $3:steps in Seconds


######################################
# Implements the necessary netCDF
# operations using CDO and NCO
#
# Globals:
#   coordFile: coordinate variables .nc
#	       file
#   lonLims: longitute bounds
#   latLims: latitute bounds
#   tempDir: temporary directory for
#	     file manipulations
#   yr: year of selected forcing data
#   outputDir: output directory for
#	       final files
#
# Arguments:
#   1: -> fName: data file name
#   2: -> fDate: date of the forcing
#   3: -> fTime: time of the forcing
#######################################
generate_netcdf () {

  # defining local variables
  local fName="$1"		# raw file name string
  local fDate="$2"		# file string date (YYYY-MM-DD)
  local fTime="$3"		# file string time (HH:MM:SS)
  local fTempDir="$4"		# file directory path
  local fOutDir="$5"		# file output path
  local fTimeScale="$6"		# fime scale to check the file name
  
  cdo sellonlatbox,"$lonLims","$latLims" "${fTempDir}/${fName}_cat.nc" "${fOutDir}/${fName}.nc" # spatial subsetting
}


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
extract_filename_info () {
  
  # define local variable for input argument
  local fPath="$1" # format: "/path/to/file/ERA5_merged_YYYYMM.nc"
  
  # file name
  fileName="$(basename $fPath)" # file name
  
  # file date
  fileNameDate=$(echo "$fileName" | cut -d '_' -f 3) # file date (YYYYMM)
  
  # parts of the date
  fileNameYear=$(echo "$fileNameDate" | cut -c 1-4) # file year (YYYY)
  fileNameMonth=$(echo "$fileNameDate" | cut -c 5-6) # file month (MM)
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
date_range () {
  # assigning local variables to input arguments
  local start=$1    # start date
  local end=$2      # end date
  local fmt=$3      # format of the ouput dates
  local tstep=$4    # the time-step value parsable by bash `date`
  local curr=$start # current time-step

  # make Unix EPOCH time 
  local currUnix=$(date --date="$curr" "+%s")
  local endUnix=$(date --date="$end" "+%s")

  # a global array variable
  dateRangeArr=()

  while [[ "$currUnix" -le "$endUnix" ]]; do
    dateRangeArr+=($(date --date="${curr}" "+${fmt}"))
    curr=$(date --date="${curr} ${tstep}")
     
    # update $currUnix for the `while` loop
    currUnix=$(date --date="${curr}" "+%s")
  done
}

#######################################
# subsetting netCDF files based on the
# start and end dates separated by str-
# ides
#
# Globals:
#   None
#
# Arguments:
#   1. start date index
#   2. end date index (could be $1)
#   3. stride
#   4. time variable name
#   5. /path/to/source/files.nc
#   6. /destination/path/
#   7. output file prefix
#   8. delimiter in the file name
#   9. file name suffix, i.e., .nc
#   10. date string 
#
# Outputs:
#   produces the output NetCDF files
#   as follows: /path/to/output/ \
#               $prefix$dlm$format.$suffix
#######################################
temporal_subset () {
  # assign local variables
  local startIdx=$1	 # start index
  local endIdx=$2	 # end index
  local stride=$3	 # split stride
  local timeVar=$4	 # time variable
  local sourceFile=$5	 # source file
  local destDir=$6	 # destination directory
  local filePrefix=$7	 # file prefix
  local dlm=$8		 # nomenclatur delimiter
  local fileSuffix=$9	 # file suffix
  local dateStr=${10}	 # date string

  ncks -d $timeVar,$startIdx,$endIdx,$stride "$sourceFile" "${destDir}/${filePrefix}${dlm}${dateStr}.${fileSuffix}" 
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
timeFrameEnd () {
  local dateStr=$1	# date string
  local timeFrame=$2	# time-frame
  local timeStep=$3	# time-step
  local fmt=$4		# date format

  case "${timeFrame,,}" in
    year)
      local dateStrTrim=$(date --date="$dateStr" "+%Y-01-01 00:00:00")
      ;;
    month)
      local dateStrTrim=$(date --date="$dateStr" "+%Y-%m-01 00:00:00")
      ;;
    day)
      local dateStrTrim=$(date --date="$dateStr" "+%Y-%m-%d 00:00:00")
      ;;
    hour)
      local dateStrTrim=$(date --date="$dateStr" "+%Y-%m-%d 00:00:00")
      ;;
    minute)
      local dateStrTrim=$(date --date="$dateStr" "+%Y-%m-%d %H:00:00")
      ;;
    second)
      local dateStrTrim=$(date --date="$dateStr" "+%Y-%m-%d %H:%M:00")
      ;;
  esac

  local endDateStr="$(date --date="$dateStrTrim 1${timeFrame} -1${timeStep}" "+${fmt}")"
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
#   
  # assign local variables
  local iniDate=$1	 # initial date
  local start=$2	 # start date
  local end=$3		 # end date
  local stride=$4	 # split stride
  local timeVar=$5	 # time variable
  local sourceFile=$6	 # source file
  local destDir=$7	 # destination directory
  local filePrefix=$8	 # file prefix
  local dlm=$9		 # nomenclatur delimiter
  local fileSuffix=${10} # file suffix
  local dateFmt=${11}	 # date format
  local tsSeconds=${12}  # time-step length
  			 # in seconds
  
  # calculate Unix EPOCH values - using one-liner funcs
  local iniUnix="$(unix_epoch "$iniDate")"
  local startUnix="$(unix_epoch "$start")"
  local endUnix="$(unix_epoch "$end")"

  # calculate indices and range - using one-liner funcs
  local startIdx=$(ts_index "$startUnix" "$iniUnix" "$tsSeconds")
  local endIdx=$(ts_index "$endUnix" "$iniUnix" "$tsSeconds")
  local idxRange=$(seq 0 $(($startIdx-$endIdx+1)))

  # split based on the given tsSeconds
  # e.g., h=(1*60*60) s,
  # e.g., d=(1*24*60*60) s,
  # e.g., m=($monthDays*24*60*60) s,
  # e.g., y=(365*24*60*60) s.
  for idx in idxRange; do
    curTSStart=$(($startUnix + ($idx * tsSeconds))) # current time-step start
    curTSEnd=$(( )) # current time-step end

  done


# ===============
# Data Processing
# ===============
# display info
echo "$(basename $0): processing ECMWF ERA5..."

# make the output directory
mkdir -p "$outputDir" # create output directory

# the structure of file names is as follows: "ERA5_merged_YYYYMM.nc"
format="%Y%m"
cdoDateFormat="%Y-%m-%dT%H:%M:%S"
fileStruct="ERA5_merged"

# making Unix EPOCH times
startDateUnix=$(date --date="${startDate}" "+%s") # start date
endDateUnix=$(date --date="${endDate}" "+%s") # end date

# extract the dates using `date_range` function -> dateRangeArr
date_range "$startDate" "$endDate" "$format" "1hour" # tstep is hard-coded for ERA5

# extract unique values from $dateRangeArr
uniqueDatesArr=($(echo "${dateRangeArr[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '));

# creating a temporary directory for temporary files
echo "$(basename $0): creating cache files in $HOME/.temp_gwfdata"
tempDir="$HOME/.temp_gwfdata" # hard-coded, can change in the future
mkdir -p "$tempDir" # making the directory

# copy necessary files to the $tempDir
for ym in "${uniqueDatesArr[@]}"; do
  cp "${datasetDir}/${fileStruct}_${ym}.nc" "${tempDir}/${fileStruct}_${ym}.nc"
done

# make the output directory
mkdir -p "$outputDir"

# data files for the current year with extracted $variables
files=($tempDir/*)

# check the $timeScale variable
case "${timeScale,,}" in

  h)
   # select date using cdo seldate[,startDate[,endDate]] 
   # -> split into hourly -> change the format of the produced files
    # going through every monthly file
    for f in "${files[@]}"; do
      # extracting information
      extract_filenameinfo "$f"
      
      # check dates
      if [[ $fileNameDate -eq "$(date --date="${startDate}" "+${format}")"  ]]; then
        # startPoint
	startPointCDO="$(date --date="${startDate}" "+${cdoDateFormat}")"
	# endPoint
	endOfCurrentMonthUnix=$(date --date="${fileNameDate}01 +1month -1hour" "+%s") # end of month Unix EPOCH time
	if [[ $endOfCurrentMonthUnix -lt $endDateUnix ]]; then
	  endPointUnix=$endOfCurrentMonthUnix
	else
	  endPointUnix=$endDateUnix
	fi
	endPointCDO="$(date --date="${endPointUnix}" "+${cdoDateFormat}")"
	
	# spatial subsetting 
	cdo sellonlatbox,$latLims,$lonLims "$f" "${tempDir}/${fileStruct}-${fileNameDate}.nc"
	# temporal subsetting


      elif [[ ]]; then

      else;

      fi
      
    done
    ;;

  d)
    # construct the date arrays
    populate_date_arrays 

    # for each date (i.e., YYYY-MM-DD)
    for d in "${uniqueDatesArr[@]}"; do
      # find the index of the $timesArr corresponding to $d -> $idx
      date_match_idx "$d" "1-3" "-" "${datesArr[@]}" 

      # concatenate hourly netCDF files to daily file, i.e., already produces _cat.nc files
      dailyFiles=($tempDir/$yr/${fileStruct}_${d}*)
      concat_files "${fileStruct}_${d}" "$tempDir/$yr/" "${dailyFiles[@]}" 

      # implement CDO/NCO operations
      generate_netcdf "${fileStruct}_${d}" "$d" "${timesArr[$idx]}" "$tempDir/$yr/" "$outputDir/$yr/" "$timeScale"
    done
    ;;

  m)
    # construct the date arrays
    populate_date_arrays 

    # for each date (i.e., YYYY-MM-DD)
    for m in "${uniqueMonthsArr[@]}"; do
      # find the index of the $timesArr corresponding to $d -> $idx
      # $m is in 'YYYY-MM' format
      date_match_idx "$m" "1,2" "-" "${datesArr[@]}" 

      # concatenate hourly netCDF files to monthly files, i.e., already produced *_cat.nc files
      monthlyFiles=($tempDir/$yr/${fileStruct}_${m}*)
      concat_files "${fileStruct}_${m}" "$tempDir/$yr/" "${monthlyFiles[@]}" 

      # implement CDO/NCO operations
      generate_netcdf "${fileStruct}_${m}" "${datesArr[$idx]}" "${timesArr[$idx]}" "$tempDir/$yr/" "$outputDir/$yr/" "$timeScale"
    done
    ;;

  y)
    # construct the date arrays
    populate_date_arrays

    # find the index of the $timesArr and $datesArr corresponding to $d -> $idx
    date_match_idx "$yr" "1" "-" "${datesArr[@]}"

    # concatenate hourly to yearly files - produced _cat.nc files
    yearlyFiles=($tempDir/$yr/${fileStruct}_${yr}*)
    concat_files "${fileStruct}_${yr}" "$tempDir/$yr/" "${yearlyFiles[@]}"

    # implement CDO/NCO operations
    generate_netcdf "${fileStruct}_${yr}" "${datesArr[$idx]}" "${timesArr[$idx]}" "$tempDir/$yr/" "$outputDir/$yr/" "$timeScale"
    ;;
esac

rm -r $tempDir # removing the temporary directory
echo "$(basename $0): temporary files from $tempDir are removed."
echo "$(basename $0): results are produced under $outputDir."

