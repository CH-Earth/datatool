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
# 2. Dr. Zhenhua Li provided scripts to extract and process CONUSI datasets
# 3. Dr. Shervan Gharari produced the netCDF file containing XLAT and XLONG
#    coordinate variables put under /assets/coord_XLAT_XLONG_conus_i.nc.
# 4. Kasra Keshavarz has written the following script to process WRF-CONUSI files.

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
  echo "usage: $(basename $0) [-io DIR] [-v VARS] [-se DATE] [-t CHAR] [-ln REAL,REAL]"
}

# argument parsing using getopt - WORKS ONLY ON LINUX BY DEFAULT
parsedArguments=$(getopt -a -n extract-dataset -o i:v:o:s:e:t:l:n:c:p: --long dataset-dir:,variables:,output-dir:,start-date:,end-date:,time-scale:,lat-lims:,lon-lims:,cache:,prefix: -- "$@")
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
    -c | --cache)         cacheDir="$2"           ; shift 2 ;; # required
    -p | --prefix)        prefix="$2"          ; shift 2 ;; # required

    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;

    # in case of invalid option
    *)
      echo "ERROR $(basename $0): invalid option '$1'";
      short_usage; exit 1 ;;
  esac
done

# hard-coding the address of the co-ordinate NetCDF files
coordFile="$(pwd)/assets/coord_XLAT_XLONG_conus_i.nc"

# The structure of file names is as follows: "wrf2d_d01_YYYY-MM-DD_HH:MM:SS" (no file extension)
format="%Y-%m-%d_%H:%M:%S"
fileStruct="wrf2d_d01"


# ===================
# Necessary Functions
# ===================
# Modules below available on Compute Canada (CC) Graham Cluster Server
module load cdo/2.0.4
module load nco/5.0.6


#######################################
# useful one-liners
#######################################
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
# Implements the necessary netCDF
# operations using CDO and NCO
#
# Globals:
#   coordFile: coordinate variables .nc
#	       file
#   lonLims: longitute bounds
#   latLims: latitute bounds
#   cacheDir: temporary directory for
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

  # add _cat if necessary
  if [[ "${fTimeScale,,}" != "h" ]]; then
    local fExt="_cat.nc"
  fi

  # necessary netCDF operations
  ## add coordinate variables: only XLAT & XLONG
  ncks -A -v XLONG,XLAT "$coordFile" "${fTempDir}/${fName}${fExt}" 
  ## set time axes
  cdo -f nc4c -z zip_1 -r settaxis,"$fDate","$fTime",1hour "${fTempDir}/${fName}${fExt}" "${fTempDir}/${fName}_taxis.nc"; 
  ## rename the `description` attribute
  ncrename -a .description,long_name "${fTempDir}/${fName}_taxis.nc"
  ## spatial extent
  cdo sellonlatbox,"$lonLims","$latLims" "${fTempDir}/${fName}_taxis.nc" "${fOutDir}/${fName}.nc"
}


#######################################
# extracts file name, date, and time 
# from CONUSI file name strings.
#
# Globals:
#   fileName: file name of the .nc data
#   fileNameDate: date (YYYY-MM-DD)
#   fileNameYear: year (YYYY)
#   fileNameMonth: month (MM)
#   fileNameDay: day (DD)
#   fileNametime: time (HH:MM:SS)
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
#    e) fileNameDay
#    f) fileNameTime
#######################################
extract_file_info () {
  
  # define local variable for input argument
  local fPath="$1" # format: "/path/to/file/wrf2d_d01_YYYY-MM-DD_HH:MM:SS"
  
  # file name
  fileName=$(basename "$fPath") # file name
  
  # file date
  fileNameDate=$(echo "$fileName" | cut -d '_' -f 3) # file date (YYYY-MM-DD)
  
  # parts of the date
  fileNameYear=$(echo "$fileNameDate" | cut -d '-' -f 1) # file year (YYYY)
  fileNameMonth=$(echo "$fileNameDate" | cut -d '-' -f 2) # file month (MM)
  fileNameDay=$(echo "$fileNameDate" | cut -d '-' -f 3) #file name day (DD)
  
  # file hour
  fileNameTime=$(echo "$fileName" | cut -d '_' -f 4) # file time (HH:MM:SS)
}


#######################################
# function for extracting the index of 
# first match between $str and that of
# the ordered array elements
#
# Globals:
#   idx: index of the first match
#
# Arguments:
#   1: the string to be matched with
#   2: the array containing strings to
#      be checked
#   3: the position within the matching
#      string split by '-'
#######################################
date_match_idx () {
  
  # defining local variables
  local str="$1"	# string to be matched 
  local matchPos="$2"	# the position of the matching string within the "YYYY-MM-DD",
  			# 1: year, 2: month, 3: day
			# 1,2: year and month, 2,3: month and day, 1,3: year and day
			# 1-3: complete date
  local delim="$3"	# delimiter
  shift	3		# shift argument positins by 3
  local strArr=("$@")	# arrays of string

  # index variable
  idx=0

  # looping through the $strArr
  for s in "${strArr[@]}"; do
    if [[ "$str" == $(echo "$s" | cut -d ${delim} -f "$matchPos") ]]; then
      break
    else
      idx=`expr $idx + 1`
    fi
  done
}


#######################################
# concatenating files based on a speci-
# temporal scale.
#
# Globals:
#   None
#
# Arguments:
#   1: name of the concatenated file
#   2: destination directory
#   3-: array of file paths
#
# Outputs:
#   produces $fName_cat.nc under $fDir
#   out of all elements of $filesArr
#######################################
concat_files () {
  # defining local variables
  local fName="$1"	    # output file name
  local fTempDir="$2"	# temporary directory
  shift 2               # shift arguments by 2 positions
  local filesArr=("$@") # array of file names
  
  # concatenating $files and producing a single $fName.nc
  ncrcat "${filesArr[@]}" "${fTempDir}/${fName}_cat.nc"
}


#######################################
# populating arrays with date and time
# values.
#
# Globals:
#   datesArr: array of date values
#   monthsArr: array of year-month va-
#              lues
#   timesArr: array of time values
#   files: array of file paths
#   fileNameDate: date of the current
#		  filename
#   fileNameYear: year of the current
#		  filename
#   fileNameMonth: month of the current
#		   filename
#   uniqueMonthsArr: array of unique
#		     months
#   uniqueDatesArr: array of unique
#		    dates
#
# Arguments:
#   None
#
# Outputs:
#   produces the following variables:
#    1) datesArr
#    2) monthsArr
#    3) timesArr
#    4) uniqueMonthsArr
#    5) unqiueDatesArr
#######################################
populate_date_arrays () {
  # defining empty arrays
  datesArr=();
  monthsArr=();
  timesArr=();
  
  for f in "${files[@]}"; do
    extract_file_info "$f" # extract necessary information

    # populate date arrays
    datesArr+=(${fileNameDate});
    monthsArr+=("${fileNameYear}-${fileNameMonth}");
    timesArr+=(${fileNameTime});
  done

  uniqueMonthsArr=($(echo "${monthsArr[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '));
  uniqueDatesArr=($(echo "${datesArr[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '));
}


# ===============
# Data Processing
# ===============
# display info
echo "$(basename $0): processing NCAR-GWF CONUSI..."

# make the output directory
mkdir -p "$outputDir" # create output directory

# constructing the range of years
startYear=$(date --date="$startDate" "+%Y") # start year (first folder)
endYear=$(date --date="$endDate" "+%Y") # end year (last folder)
yearsRange=$(seq $startYear $endYear)

# constructing $toDate and $endDate in unix time EPOCH
toDate=$startDate
toDateUnix=$(date --date="$startDate" "+%s") # first date in unix EPOCH time
endDateUnix=$(date --date="$endDate" "+%s") # end date in unix EPOCH time

# for each year (folder) do the following calculations
for yr in $yearsRange; do

  # creating a temporary directory for temporary files
  echo "$(basename $0): creating cache files for year $yr in $cacheDir"
  mkdir -p "$cacheDir/$yr" # making the directory

  # setting the end point, either the end of current year, or the $endDate
  endOfCurrentYearUnix=$(date --date="$yr-01-01 +1 year -1 hour" "+%s") # last time-step of the current year
  if [[ $endOfCurrentYearUnix -le $endDateUnix ]]; then
    endPointUnix=$endOfCurrentYearUnix
  else
    endPointUnix=$endDateUnix
  fi

  # extract variables from the forcing data files
  while [[ "$toDateUnix" -le "$endPointUnix" ]]; do
    # date manipulations
    toDateFormatted=$(date --date "$toDate" "+$format") # current timestamp formatted to conform to CONUSI naming convention
    
    # creating file name
    file="${fileStruct}_${toDateFormatted}" # current file name
    
    # extracting variables from the files
    ncks -O -v "$variables" "$datasetDir/$yr/$file" "$cacheDir/$yr/${file}" # extracting $variables
    
    # increment time-step by one unit
    toDate=$(date --date "$toDate 1hour") # current time-step
    toDateUnix=$(date --date="$toDate" "+%s") # current timestamp in unix EPOCH time
  done

  # go to the next year if necessary
  if [[ "$toDateUnix" == "$endOfCurrentYearUnix" ]]; then 
    toDate=$(date --date "$toDate 1hour")
  fi

  # make the output directory
  mkdir -p "$outputDir/$yr/"

  # data files for the current year with extracted $variables
  files=($cacheDir/$yr/*)

  # check the $timeScale variable
  case "${timeScale,,}" in

    h)
      # going through every hourly file
      for f in "${files[@]}"; do
        # extracting information
        extract_file_info "$f"
        # necessary NetCDF operations
        generate_netcdf "${fileName}" "$fileNameDate" "$fileNameTime" "$cacheDir/$yr/" "$outputDir/$yr/" "$timeScale"
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
	    dailyFiles=($cacheDir/$yr/${fileStruct}_${d}*)
	    concat_files "${fileStruct}_${d}" "$cacheDir/$yr/" "${dailyFiles[@]}" 

	    # implement CDO/NCO operations
	    generate_netcdf "${fileStruct}_${d}" "$d" "${timesArr[$idx]}" "$cacheDir/$yr/" "$outputDir/$yr/" "$timeScale"
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
        monthlyFiles=($cacheDir/$yr/${fileStruct}_${m}*)
        concat_files "${fileStruct}_${m}" "$cacheDir/$yr/" "${monthlyFiles[@]}" 

        # implement CDO/NCO operations
        generate_netcdf "${fileStruct}_${m}" "${datesArr[$idx]}" "${timesArr[$idx]}" "$cacheDir/$yr/" "$outputDir/$yr/" "$timeScale"
      done
      ;;

    y)
      # construct the date arrays
      populate_date_arrays

      # find the index of the $timesArr and $datesArr corresponding to $d -> $idx
      date_match_idx "$yr" "1" "-" "${datesArr[@]}"

      # concatenate hourly to yearly files - produced _cat.nc files
      yearlyFiles=($cacheDir/$yr/${fileStruct}_${yr}*)
      concat_files "${fileStruct}_${yr}" "$cacheDir/$yr/" "${yearlyFiles[@]}"

      # implement CDO/NCO operations
      generate_netcdf "${fileStruct}_${yr}" "${datesArr[$idx]}" "${timesArr[$idx]}" "$cacheDir/$yr/" "$outputDir/$yr/" "$timeScale"
      ;;

  esac
done

rm -r $cacheDir # removing the temporary directory
echo "$(basename $0): temporary files from $cacheDir are removed."
echo "$(basename $0): results are produced under $outputDir."

