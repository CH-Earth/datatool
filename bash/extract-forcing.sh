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


#### CREDIT
# 1. Parts of the code are taken from https://www.shellscript.sh/tips/getopt/index.html
# 2. Dr. Zhenhua Li provided scripts to extract and process CONUS I & II datasets

# declaring variables
jobSubmission=unset
forcing=unset
outputDir=unset
startDate=unset
endDate=unset
timeScale=unset
latBox=unset
lonBox=unset

# help string
usage() {
   echo "Global Water Futures (GWF) Meteorological Forcing Data Processing Script

   Usage: 
       $0 [options...]

   Script options:
       -d, --dataset               Meteorological forcing dataset of interest
       -o, --output-dir=DIR        Writes processed files to DIR
       -s, --start-date=STRING     The start date of the forcing data
       -e, --end-date=STRING       The end date of the forcing data
       -t, --time-scale=CHAR       The time scale of interest, i.e., D (daily), M (Monthly), A (Annual)
       -l, --lat-box=NUM,NUM       Latitude's upper and lower bounds
       -n, --lon-box=NUM,NUM       Longitude's upper and lower bounds
       -j, --submit-job            Submit the data extraction process as a job on the SLURM system
       -h, --help                  Print this message 

Email bug reports, questions, discussions to <kasra.keshavarz AT usask DOT ca>
and/or open an issue at https://github.com/kasra-keshavarz/gwf-forcing-data/issues"
    
    echo 
    exit 0
}

# argument parsing
parsedArguments=$(getopt -a -n extract-dataset -o jhd:o:s:e:t:l:n: --long submit-job,help,dataset:,output-dir:,start-date:,end-date:,time-scale:,lat-box:,lon-box:, -- "$@")
validArguments=$?
if [ "$validArguments" != "0" ]; then
  exit 1
fi

eval set -- "$parsedArgument"
while :
do
  case "$1" in
    -h | --help)          usage                ; shift   ;;
    -j | --submit-job)    jobSubmission=true   ; shift   ;;
    -d | --dataset)       forcing="$2"         ; shift 2 ;;
    -o | --output-dir)    outputDir="$2"       ; shift 2 ;;
    -s | --start-date)    startDate="$2"       ; shift 2 ;;
    -e | --end-date)      endDate="$2"         ; shift 2 ;;
    -t | --time-scale)    timeScale="$2"       ; shift 2 ;;
    -l | --lat-box)       latBox="$2"          ; shift 2 ;;
    -n | --lon-box)       lonBox="$2"          ; shift 2 ;;

    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;

    # If invalid options were passed, then getopt should have reported an error,
    # which we checked as VALID_ARGUMENTS when getopt was called...
    *) usage; exit 0;;
  esac
done
