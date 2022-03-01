#!/bin/bash

# Global Water Futures (GWF) Meteorological Forcing Data Processing Script
# Copyright (C) 2022, Kasra Keshavarz, Global Water Futures (GWF)

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# ======
# CREDIT
# ======
# 1. Parts of the code are taken from https://www.shellscript.sh/tips/getopt/index.html
# 2. Dr. Zhenhua Li provided scripts to extract and process CONUS I & II datasets


# ================
# GENERAL COMMENTS
# ================
# * All variables are camelCased;

short_usage() {
  echo "usage: $0 [-io DIR] [-se DATE] [-t CHAR] [-ln NUM,NUM]"
}

# argument parsing using getopt - WORKS ONLY ON LINUX BY DEFAULT
parsedArguments=$(getopt -a -n extract-dataset -o i:o:s:e:t:l:n: --long dataset-dir:,output-dir:,start-date:,end-date:,time-scale:,lat-box:,lon-box:, -- "$@")
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
    -l | --lat-box)       latBox="$2"          ; shift 2 ;; # required
    -n | --lon-box)       lonBox="$2"          ; shift 2 ;; # required

    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;

    # in case of invalid option
    *)
      echo "$0: invalid option '$1'";
      short_usage; exit 1 ;;
  esac
done


# =========================
# CONUS I NetCDF processing
# =========================

# Modules below available on Compute Canada Graham Cluster Server
module load cdo/2.0.4
module load nco/5.0.6

# display info
echo "$0: processing NCAR-GWF CONUSI..."

# make the output directory
mkdir -p "$outputDir" # create output directory

## since data is structured into folders (by year)
## we need to iterate in each year and produce files accordingly
startYear=$(date --date="$startDate" "+%Y") # start year (first folder)
endYear=$(date --date="$endDate" "+%Y") # end year (last folder)
yearsRange=$(seq $startYear $endYear)

# assigning the startDate to $toDate for counting
toDate=$startDate
unixToDate=$(date --date="$startDate" "+%s") # first date to read proper files
unixStartDate=$(date --date="$startDate" "+%s") # starting point in unix timestamp
unixEndDate=$(date --date="$endDate" "+%s") # end point in unix timestamp

## for each year (folder) do the following calculations
for yr in $yearsRange; do
  # creating a temporary directory for temporary files
  echo "$0: creating temporary files for year $yr in $HOME/.temp_gwfdata"
  tempDir="$HOME/.temp_gwfdata"
  mkdir -p "$tempDir/$yr" # making the directory

  # setting the end point for the current year
  unixEndOfCurrentYear=$(date --date="$yr-01-01 +1 year -1 hour" "+%s") # hourly files
  if [[ $unixEndOfCurrentYear -lt $unixEndDate ]]; then
    unixEndPoint=$unixEndOfCurrentYear
  else
    unixEndPoint=$unixEndDate
  fi

  # The structure of file names is as follows:
  # wrf2d_d01_YYYY-MM-DD_HH:MM:SS (no file extension)
  format="%Y-%m-%d_%H:%M:%S"
  fileStruct="wrf2d_d01"

  while [[ "${unixToDate}" -le "${unixEndPoint}" ]]; do
    toDate=$(date --date "$toDate +1 hour") # current timestamp
    unixToDate=$(date --date="$toDate" "+%s") # current timestamp in unix EPOCH
    toDateFormatted=$(date --date "$toDate" "+$format") # current filename timestamp
    file="wrf2d_d01_${toDateFormatted}" # current file name
    ncks -v T2,Q2,PSFC,U,V,GLW,LH,SWDOWN,QFX,HFX "$datasetDir/$yr/$file" "${tempDir}/${yr}/${file}" # selecting variables of interest - hard-coded
  done

  # go to the next year
  toDate=$(date --date "$toDate +1 hour") # current timestamp

  # make the output directory
  mkdir -p "$outputDir/$yr/"

  # check the $timeScale variable

  case "${timeScale,,}" in

    h)
       files=($tempDir/$yr/*) # listing temporary files

       # going through every hourly file
       for f in "${files[@]}"; do
         
	 # extracting information
         fileName=$(echo "$f" | rev | cut -d '/' -f 1 | rev) # file name
         fileNameDate=$(echo "$fileName" | cut -d '_' -f 3) # file date (YYYY-MM-DD)
         fileNameTime=$(echo "$fileName" | cut -d '_' -f 4) # file time (HH:MM:SS)
	 
	 # necessary operations
	 cdo -f nc4c -z zip_1 -r settaxis,$fileNameDate,$fileNameTime,1hour "$f" "$tempDir/$yr/$fileName.nc"; # setting time axis
         ncrename -a .description,long_name "$tempDir/$yr/$fileName.nc"; # changing some attributes
         cdo sellonlatbox,$lonBox,$latBox "$tempDir/$yr/$fileName.nc" "$outputDir/$yr/$fileName.nc" # selecting a box of data
       done
       ;;

    d)
       files=($tempDir/$yr/*) # listing temporary files
       datesArr=() # empty array of dates
       hoursArr=() # empty array of hours

       for f in "${files[@]}"; do

	 # extract information
         fileName=$(echo "$f" | rev | cut -d '/' -f 1 | rev); # file name
         fileNameHour=$(echo "$fileName" | cut -d '_' -f 4) # file hour
	 fileNameDate=$(echo "$fileName" | cut -d '_' -f 3); # file date

	 # populate dates
	 datesArr+=(${fileNameDate});
	 hoursArr+=(${fileNameHour});
       done

       uniqueDaysArr=($(echo "${datesArr[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '));
       
       # for each day (i.e., YYYY-MM-DD)
       for d in "${uniqueDaysArr[@]}"; do

         # start date and time of first occurence of the $d
         idx=1
         for k in "${datesArr[@]}"; do
           if [[ "$k" == "$d"  ]]; then
             break;
           else
             idx=`expr $idx + 1`
           fi
         done

	 # concatenate hourly to daily files
         dailyFiles="$tempDir/$yr/${fileStruct}_${d}*";
	 ncrcat $dailyFiles "$tempDir/$yr/${fileStruct}_${d}_cat.nc";
	 cdo -f nc4c -z zip_1 -r settaxis,"$d","${hoursArr[$idx]}",1hour "$tempDir/$yr/${fileStruct}_${d}_cat.nc" "$tempDir/$yr/${fileStruct}_${d}_taxis.nc"; # setting time axis
         ncrename -a .description,long_name "$tempDir/$yr/${fileStruct}_${d}_taxis.nc" # rename some attributes (CF-1.6)
         cdo sellonlatbox,$lonBox,$latBox "$tempDir/$yr/${fileStruct}_${d}_taxis.nc" "$outputDir/$yr/${fileStruct}_${d}.nc"; # subsetting the lats & lons
       done
       ;;

    m)
       files=($tempDir/$yr/*); # listing temporary files
       monthsArr=();
       datesArr=();
       hoursArr=();

       for f in "${files[@]}"; do
	 # extract information
         fileName=$(echo "$f" | rev | cut -d '/' -f 1 | rev); # file name
         fileNameHour=$(echo "$fileName" | cut -d '_' -f 4) # file hour
	 fileNameDate=$(echo "$fileName" | cut -d '_' -f 3); # file date
	 fileNameMonth=$(echo "$fileNameDate" | cut -d '-' -f 1,2); # file year and month

	 # populate dates
	 monthsArr+=(${fileNameMonth});
	 datesArr+=(${fileNameDate});
	 hoursArr+=(${fileNameHour});
       done

       uniqueMonthsArr=($(echo "${monthsArr[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '));

       # for each month
       for m in "${uniqueMonthsArr[@]}"; do

         # start date and time of first occurrence of the $m
	 idx=0
	 for k in "${datesArr[@]}"; do
	   if [[ $(echo "$m" | cut -d '-' -f 2) == $(echo $k | cut -d '-' -f 2) ]]; then
	     break;
	   else
	     idx=`expr $idx + 1`
	   fi
	 done

         # concatenate hourly to monthly files
	 monthlyFiles="$tempDir/$yr/${fileStruct}_${m}*";
	 ncrcat $monthlyFiles "$tempDir/$yr/${fileStruct}_${m}_cat.nc";
	 cdo -f nc4c -z zip_1 -r settaxis,"${datesArr[$idx]}","${hoursArr[$idx]}",1hour "$tempDir/$yr/${fileStruct}_${m}_cat.nc" "$tempDir/$yr/${fileStruct}_${m}_taxis.nc"; # setting time axis
	 ncrename -a .description,long_name "$tempDir/$yr/${fileStruct}_${m}_taxis.nc" # renaming some attributes (CF-1.6)
	 cdo sellonlatbox,$lonBox,$latBox "$tempDir/$yr/${fileStruct}_${m}_taxis.nc" "$outputDir/$yr/${fileStruct}_${m}.nc"; # subsetting the lats & lons
       done
       ;;

    y) 
       files=($tempDir/$yr/*); # listing temporary files
       monthsArr=();
       datesArr=();
       hoursArr=();

       for f in "${files[@]}"; do
         # extract information
         fileName=$(echo "$f" | rev | cut -d '/' -f 1 | rev); # file name
         fileNameHour=$(echo "$fileName" | cut -d '_' -f 4) # file hour
         fileNameDate=$(echo "$fileName" | cut -d '_' -f 3); # file date
         fileNameMonth=$(echo "$fileNameDate" | cut -d '-' -f 1,2); # file year and month

         # populate dates
         monthsArr+=(${fileNameMonth});
         datesArr+=(${fileNameDate});
         hoursArr+=(${fiileNameHour});
       done

       idx=1
       for k in "${datesArr[@]}"; do
	 if [[ "$k" == "$yr*"  ]]; then
	   break;
	 else
	   idx=`expr $idx + 1`
	 fi
       done


       # concatenate hourly to yearly files
       yearlyFiles="$tempDir/$yr/${fileStruct}_${yr}*"
       ncrcat $yearlyFiles "$tempDir/$yr/${fileStruct}_${yr}_cat.nc";
       cdo -f nc4c -z zip_1 -r settaxis,"${datesArr[$idx]}","${hoursArr[$idx]}",1hour "$tempDir/$yr/${fileStruct}_${yr}_cat.nc" "$tempDir/$yr/${fileStruct}_${yr}_taxis.nc"; # setting time axis
       ncrename -a .description,long_name "$tempDir/$yr/${fileStruct}_${yr}_taxis.nc"; # renaming some attributes (CF-1.6)
       cdo sellonlatbox,$lonBox,$latBox "$tempDir/$yr/${fileStruct}_${yr}_taxis.nc" "$outputDir/$yr/${fileStruct}_${yr}.nc"; # subsetting the lats & lons
       ;;
  
  esac

done

rm -r $tempDir # removing the temporary directory
echo "$0: temporary files from $tempDir are removed."
echo "$0: results are produced under $outputDir."
