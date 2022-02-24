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
# 3. Parts of the code are taken from https://stackoverflow.com/a/17557904/5188208


# GENERAL COMMENTS:
# * All variables are camelCased;


# ==============
# Help functions
# ==============

#help string
usage () {
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


# =======================
# Parsing input arguments
# =======================

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
    -i | --dataset-dir)   datasetDir="$2"      ; shift 2 ;; # required
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

# put necessary arguments in an array
declare -A funcArgs=([jobSubmission]="$jobSubmission" \
		     [datasetDir]="$datasetDir" \
                     [forcingData]="$forcingData" \
		     [outputDir]="$outputDir" \
		     [startDate]="$startDate" \
		     [endDate]="$endDate" \
		     [timeScale]="$timeScale" \
		     [latBox]="$latBox" \
		     [lonBox]="$lonBox" \
		    );


# =================================
# Template data processing function
# =================================

# all processing script files follow same input argument standard
call_processing_func() {

  # contents of $args are passed as the first argument
  eval "declare -A args="{1#*=}

  # script name is passed as the second argument
  script="$2"
  
  # evaluate the script file using the arguments provided
  if [[ "${jobSubmission}" == true ]]; then
    echo "not implemented yet"
  else
    # decompose array values
    bash "./${script}" -i "${funcArgs[datasetDir]}" \
    		       -o "${funcArgs[outputDir]}" \
		       -s "${funcArgs[startDate]}" \
      		       -e "${funcArgs[endDate]}" \
   		       -t "${funcArgs[timeScale]}" \
   		       -l "${funcArgs[latBox]}" \
   		       -n "${funcArgs[lonBox]}" \
  fi
}


# ======================
# Checking input dataset
# ======================
case "${forcingData,,}" in
  conus1 | conusi | conus_1 | conus_i)
    if [[ "${jobSubmission}" == true ]]; then
      call_processing_func "$(declare -p sio)" ./conus_i.sh;
    fi
    ;;
  conus2 | conusii | conus_2 | conus_ii)
    ;;
