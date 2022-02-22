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


# CREDIT
# ======
# 1. Parts of the code are taken from https://www.shellscript.sh/tips/getopt/index.html
# 2. Dr. Zhenhua Li provided scripts to extract and process CONUS I & II datasets


# GENERAL COMMENTS
# ================
# * All variables are camelCased;

# help string
usage() {
  echo "Global Water Futures (GWF) Meteorological Forcing Data Processing Script

   Usage: 
       $0 [options...]

   Script options:
       -d, --dataset               Meteorological forcing dataset of interest
       				   currently available options are:
				   'CONUSI'; 'CONUSII';
       -o, --output-dir=DIR        Writes processed files to DIR
       -s, --start-date=STRING     The start date of the forcing data
       -e, --end-date=STRING       The end date of the forcing data
       -t, --time-scale=CHAR       The time scale of interest, i.e., H (hourly), D (Daily), M (Monthly), A (Annual)
       -l, --lat-box=NUM,NUM       Latitude's upper and lower bounds
       -n, --lon-box=NUM,NUM       Longitude's upper and lower bounds
       -j, --submit-job            Submit the data extraction process as a job on the SLURM system
       -h, --help                  Print this message 

Email bug reports, questions, discussions to <kasra.keshavarz AT usask DOT ca>
and/or open an issue at https://github.com/kasra-keshavarz/gwf-forcing-data/issues"
  
  exit 1
}

short_usage() {
  echo "usage: $0 [-jh] [-d DATASET] [-o DIR] [-se DATESTRING] [-ln NUM,NUM]"
}


# argument parsing using getopt - WORKS ONLY ON LINUX BY DEFAULT
parsedArguments=$(getopt -a -n extract-dataset -o jhd:o:s:e:t:l:n: --long submit-job,help,dataset:,output-dir:,start-date:,end-date:,time-scale:,lat-box:,lon-box:, -- "$@")
validArguments=$?
if [ "$validArguments" != "0" ]; then
  short_usage;
  exit 2;
fi

# check if no options were passed
if [ $# -eq 0 ]; then
  short_usage
  exit 1
fi

# check long and short options passed
eval set -- "$parsedArguments"
while :
do
  case "$1" in
    -h | --help)          usage                ; shift   ;; # optional
    -j | --submit-job)    jobSubmission=true   ; shift   ;; # optional
    -d | --dataset)       forcingData="$2"     ; shift 2 ;; # required
    -o | --output-dir)    outputDir="$2"       ; shift 2 ;; # required
    -s | --start-date)    startDate="$2"       ; shift 2 ;; # required
    -e | --end-date)      endDate="$2"         ; shift 2 ;; # required
    -t | --time-scale)    timeScale="$2"       ; shift 2 ;; # required
    -l | --lat-box)       latBox="$2"          ; shift 2 ;; # required
    -n | --lon-box)       lonBox="$2"          ; shift 2 ;; # required

    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;

    # in case of invalid option
    *) short_usage ;;
  esac
done

# an example of using CONUSI data on a monthly time-scale:
if [ "${forcingData,,}" = "conusi" ] || [ "${forcingData,,}" = "conus1" ]
  then

    # display info 
    echo "$0: chosen dataset: $forcingData"
    echo "$0: processing $forcingData using CDO..."
    
    # display job submission info placeholder, WILL BE ADDED LATER
    if [[ -n "$jubSubmission" ]]
      then
        echo "$0: SLRUM job submitted with ID: $jobID"
    fi

    # hard-coded for now, can be passed as an argument of "-d" in future 
    # versions, if needed
    datasetAddress="~/projects/rpp-kshook/Model_Output/WRF/CONUS/CTRL/"

    ## since data is structured into folders (by year)
    ## we need to iterate in each year and produce files accordingly
    startYear=$(date --date=startDate "+%Y") # start year (first folder)
    endYear=$(date --date=endDate "+%Y") # end year (last folder)
    yearsRange=$(seq startYear endYear) # inclusive start and end values

    ## extract the start and end months, days, and hours as well
    startMonth=$(date --date=startDate "+%m")
    endMonth=$(date --date=endDate "+%m")
    monthsRange=$(seq startMonth endMonth)

    startDay=$(date --date=startDate "+%d")
    endDay=$(date --date=endDate "+%d")
    startHour=$(date --date=startDate "+%H")
    endHour=$(date --date=endDate "+%H")

    ## GOING WITH MONTHLY TIMESCALE JUST TO TRY
    ## for each year (folder) do the following calculations and print
    ## the outputs to $outputDir depending on the $timeScale value
    if [ "${timeScale,,}" = "m" ]; then
      for yr in $yearsRange; do
        # understanding what the file naming convention is
	# based on knowledge that the delimiter is '_' and
	# first two pieces are common in all files
	fileStruct=$(ls | head -n 1 | cut -d '_' -f 1,2)
	for mn in $monthsRange; do
	  mkdir -p "${outputDir}" # create output directory
	    subFiles=("${datasetAddress}/${fileStruct}_${yr}-${mn}*")
	    for f in $(subFiles); do # hourly files
	      hourlyOutputFile="h2d_$(echo "$f" | rev | cut -d/ -f 1 | cut -d '_' -f 1- | rev).nc"
	      ncks -v T2,Q2,PSFC,U,V,GLW,LH,SWDOWN,QFX,HFX "$f" "${outputDir}/${hourlyOutputFile}" # selecting variables
	    done
	    # concatenating hourly files to monthly
	    ncrcat "${outputDir}/h2d_${yr}-${mn}*.nc" "${outputDir}/h2d_${yr}_${mn}.nc"
	    cdo -f nc4c -z zip_1 -r settaxis,"${yr}-${mn}-01",00:00:00,1hour "${outputDir}/h2d_${yr}_${mn}.nc" "${outputDir}/wrf_${yr}_${mn}.nc"
	    ncrename -a .description,long_name "${outputDir}/wrf_${yr}_${mn}.nc"
	    ncatted -O -a coordinates,PREC,c,c,lon lat "${outputDir}/wrf_${yr}_${mn}.nc"
	    cdo sellonlatbox,"${lonBox},${latBox}" "${outputDir}/wrf_${yr}_${mn}.nc" "${outputDir}/wrf_${yr}_${mn}_boxed.nc"
	done
      # Dr. Zhenhua Li's contribution
      done
    fi
fi

# there could be bugs -  will review & prepare for final assessment
