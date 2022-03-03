#!/bin/bash

# ======
# Credit
# ======
# 1. Parts of the code are taken from https://www.shellscript.sh/tips/getopt/index.html
# 2. Dr. Zhenhua Li provided scripts to extract and process CONUS I datasets


# ================
# General Comments
# ================
# * All variables are camelCased for distinguishing from function names;
# * function names are all in lower_case with words seperated by underscore for legibility;
# * shell style is based on Google Open Source Projects'
#   Style Guide: https://google.github.io/styleguide/shellguide.html


# ===============
# Usage Functions
# ===============

short_usage() {
  echo "usage: $0 [-io DIR] [-se DATE] [-t CHAR] [-ln INT,INT]"
}

# argument parsing using getopt - WORKS ONLY ON LINUX BY DEFAULT
parsedArguments=$(getopt -a -n extract-dataset -o i:o:s:e:t:l:n:f: --long dataset-dir:,output-dir:,start-date:,end-date:,time-scale:,lat-box:,lon-box:,forcing-vars:, -- "$@")
validArguments=$?
if [ "$validArguments" != "0" ]; then
  short_usage;
  exit 1;
fi

# check if no options were passed
if [ $# -eq 0 ]; then
  echo "ERROR $0: arguments missing";
  exit 1;
fi

# check long and short options passed
eval set -- "$parsedArguments"
while :
do
  case "$1" in
    -i | --dataset-dir)   datasetDir="$2"      ; shift 2 ;; # required
    -o | --output-dir)    outputDir="$2"       ; shift 2 ;; # required
    -s | --start-date)    startDate="$2"       ; shift 2 ;; # required
    -e | --end-date)      endDate="$2"         ; shift 2 ;; # required
    -t | --time-scale)    timeScale="$2"       ; shift 2 ;; # required
    -l | --lat-box)       latLims="$2"         ; shift 2 ;; # required
    -n | --lon-box)       lonLims="$2"         ; shift 2 ;; # required
    -f | --forcing-vars)  forcingVars="$2"     ; shift 2 ;; # required

    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;

    # in case of invalid option
    *)
      echo "ERROR $0: invalid option '$1'";
      short_usage; exit 1 ;;
  esac
done


# ===================
# Necessary Functions
# ===================

# Modules below available on Compute Canada (CC) Graham Cluster Server
module load cdo/2.0.4
module load nco/5.0.6

#######################################
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
#   1: -> fName: file name of the forc-
#		 ing file
#   2: -> fDate: date of the forcing
#   3: -> fTime: time of the forcing
#######################################
generate_netcdf () {

  # defining local variables
  local fName="$1"		# raw file name string
  local fDate="$2"		# file string date (YYYY-MM-DD)
  local fTime="$3"		# file string time (HH:MM:SS)

  # necessary netCDF operations
  cdo -f nc4c -z zip_1 -r settaxis,"$fDate","$fTime",1hour "${tempDir}/${yr}/${fName}_cat.nc" "${tempDir}/${yr}/${fName}_taxis.nc"; # setting time axis
  ncrename -a .description,long_name "${tempDir}/${yr}/${fName}_taxis.nc"; # conforming to CF-1.6 standards
  #ncks -A -v XLONG,XLAT $coordFile "${fTempDir}/${fName}_taxis.nc" # coordination variables
  cdo sellonlatbox,"$lonLims","$latLims" "${tempDir}/${yr}/${fName}_taxis.nc" "${outputDir}/${yr}/${fName}.nc" # spatial subsetting 
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
#   produces the following variables:
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
  fileName=$(echo "$fPath" | rev | cut -d '/' -f 1 | rev) # file name
  
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
  local strArr="$2"	# array of strings (dates)
  local matchPos="$3"	# the position of the matching string within the "YYYY-MM-DD",
  			# 1: year, 2: month, 3: day
			# 1,2: year and month, 2,3: month and day, 1,3: year and day
			# 1-3: complete date
  
  # index variable
  idx=0

  # looping through the $strArr
  for s in "${strArr[@]}"; do
    if [[ "$str" == $(echo "$s" | cut -d '-' -f "$matchPos") ]]; then
      break;
    else
      idx=`expr $idx + 1`
    fi
  done
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
#
# Outputs:
#   produces $fName.nc under $fTempDir
#   out of all $filesArr
#######################################
concat_files () {
  # defining local variables
  local filesArr="$1"
  local fName="$2"
  local fTempDir="$3"

  # concatenating $files and producing a single $fName.nc
  ncrcat "$filesArr" "${fTempDir}/${fName}.nc"
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
#
# Outputs:
#   produces $fName.nc under $fTempDir
#   out of all $filesArr
#######################################

populate_date_arrays () {
  # defining empty arrays
  datesArr=();
  monthsArr=();
  timesArr=();
  
  for f in "${files[@]}"; do
    extract_file_info "$f" # extract necessary information

    # populate date arrays
    monthsArr+=(${fileNameMonth});
    datesArr+=(${fileNameDate});
    timesArr+=(${fileNameTime});
  done

  uniqueMonthsArr=($(echo "${monthsArr[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '));
  uniqueDatesArr=($(echo "${datesArr[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '));
}


# ===============
# Data Processing
# ===============

# display info
echo "$0: processing NCAR-GWF CONUSI..."

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

# hard-coding the address of the co-ordinate NetCDF files
coordFile="/project/6008034/Model_Output/WRF/CONUS/coord.nc"

# for each year (folder) do the following calculations
for yr in $yearsRange; do

  # creating a temporary directory for temporary files
  echo "$0: creating temporary files for year $yr in $HOME/.temp_gwfdata"
  tempDir="$HOME/.temp_gwfdata"
  mkdir -p "$tempDir/$yr" # making the directory

  # setting the end point, either the end of current year, or the $endDate
  endOfCurrentYearUnix=$(date --date="$yr-01-01 +1 year -1 hour" "+%s") # last time-step of the current year
  if [[ $endOfCurrentYearUnix -le $endDateUnix ]]; then
    endPointUnix=$endOfCurrentYearUnix
  else
    endPointUnix=$endDateUnix
  fi

  # The structure of file names is as follows: "wrf2d_d01_YYYY-MM-DD_HH:MM:SS" (no file extension)
  format="%Y-%m-%d_%H:%M:%S"
  fileStruct="wrf2d_d01"

  # extract variables from the forcing data files
  while [[ "$toDateUnix" -le "$endPointUnix" ]]; do
    toDate=$(date --date "$toDate +1 hour") # current time-step
    toDateUnix=$(date --date="$toDate" "+%s") # current timestamp in unix EPOCH time
    toDateFormatted=$(date --date "$toDate" "+$format") # current timestamp formatted to conform to CONUSI naming convention
    file="wrf2d_d01_$toDateFormatted" # current file name
    ncks -v "$forcingVars" "$datasetDir/$yr/$file" "$tempDir/$yr/$file" # extracting $forcingVars
  done

  # go to the next year if necessary
  if [[ "$toDateUnix" == "$endOfCurrentYearUnix" ]]; then 
    toDate=$(date --date "$toDate +1 hour")
  fi

  # make the output directory
  mkdir -p "$outputDir/$yr/"

  # forcing files for the current year with extracted $forcingVars
  files=($tempDir/$yr/*)

  # check the $timeScale variable
  case "${timeScale,,}" in

    h)
      # going through every hourly file
      for f in "${files[@]}"; do
	# extracting information
	extract_file_info "$f"
	# necessary NetCDF operations
	generate_netcdf "$fileName" "$fileNameDate" "$fileNameTime"
      done
      ;;

    d)
      populate_date_arrays 

      # for each date (i.e., YYYY-MM-DD)
      for d in "${uniqueDatesArr[@]}"; do
        # find the index of the $timeArr corresponding to $d -> $idx
	date_match_idx "$d" "${datesArr[@]}" "1-3"

	# concatenate hourly netCDF files to daily files
	concat_files "$tempDir/$yr/${fileStruct}_${d}*" "$tempDir/$yr/" "${fileStruct}_${d}_cat.nc"

	# implement CDO/NCO operations
	generate_netcdf "${fileStruct}_${d}" "$d" "${timeArr[$idx]}" "$tempDir/$yr/" "$outputDir/$yr/"
      done
      ;;

    m)
      # construct the date arrays
      populate_date_arrays 

      # for each date (i.e., YYYY-MM-DD)
      for m in "${uniqueMonthsArr[@]}"; do
        # find the index of the $timeArr corresponding to $d -> $idx
	date_match_idx "$m" "${datesArr[@]}" "1,2"

	# concatenate hourly netCDF files to daily files
	concat_files "$tempDir/$yr/${fileStruct}_${yr}-${m}*" "$tempDir/$yr/" "${fileStruct}_${yr}-${m}_cat.nc"

	# implement CDO/NCO operations
	generate_netcdf "${fileStruct}_${yr}-${d}" "${datesArr[idx]}" "${timeArr[$idx]}" "$tempDir/$yr/" "$outputDir/$yr/"
      done
     ;;

    y)
      # construct the date arrays
      populate_date_arrays

      date_match_idx "$yr" "${datesArr[@]}" "1"

      # concatenate hourly to yearly files
      yearlyFiles="$tempDir/$yr/${fileStruct}_${yr}*"
      ncrcat $yearlyFiles "$tempDir/$yr/${fileStruct}_${yr}_cat.nc";
      cdo -f nc4c -z zip_1 -r settaxis,"${datesArr[$idx]}","${timeArr[$idx]}",1hour "$tempDir/$yr/${fileStruct}_${yr}_cat.nc" "$tempDir/$yr/${fileStruct}_${yr}_taxis.nc"; # setting time axis
      ncrename -a .description,long_name "$tempDir/$yr/${fileStruct}_${yr}_taxis.nc"; # renaming some attributes (CF-1.6)
      #ncks -A -v XLONG,XLAT "$coordFile" "$tempDir/$yr/${fileStruct}_${yr}_taxis.nc"
      cdo sellonlatbox,$lonBox,$latBox "$tempDir/$yr/${fileStruct}_${yr}_taxis.nc" "$outputDir/$yr/${fileStruct}_${yr}.nc"; # subsetting the lats & lons
      ;;

  esac
done

rm -r $tempDir # removing the temporary directory
echo "$0: temporary files from $tempDir are removed."
echo "$0: results are produced under $outputDir."

