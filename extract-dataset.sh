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
# 1) Parts of the code are taken from https://www.shellscript.sh/tips/getopt/index.html
# 2) Dr. Zhenhua Li provided scripts to extract and process CONUS I & II datasets
# 3) Parts of the code are taken from https://stackoverflow.com/a/17557904/5188208


# ================
# General comments
# ================
# 1) All variables are camelCased;


# ================
# Global variables
# ================
VER="0.1.0-alpha"


# ==============
# Help functions
# ==============
usage () {
  echo "Global Water Futures (GWF) Forcing Data Processing Script

Usage:
  $(basename $0) [options...]

Script options:
  -d, --dataset				Meteorological forcing dataset of interest
                                        currently available options are:
                                        'CONUSI';'ERA5';'CONUSII';'RDRS';
  -i, --dataset-dir=DIR			The source path of the dataset file(s)
  -v, --variable=var1[,var2[...]]	Variables to process
  -o, --output-dir=DIR			Writes processed files to DIR
  -s, --start-date=DATE			The start date of the forcing data
  -e, --end-date=DATE			The end date of the forcing data
  -t, --time-scale=CHAR			The time scale of interest:
					'H' (hourly), 'D' (Daily), 'M' (Monthly), 
					or 'Y' (Yearly) [default: 'M']
  -l, --lat-lims=REAL,REAL		Latitude's upper and lower bounds
  -n, --lon-lims=REAL,REAL		Longitude's upper and lower bounds
  -j, --submit-job			Submit the data extraction process as a job
					on the SLURM system
  -p, --prefix=STR			Prefix  prepended to the output files
  -c, --cache=DIR			Path of the cache directory
  -V, --version				Show version
  -h, --help				Show this screen

Email bug reports, questions, discussions to <kasra.keshavarz AT usask DOT ca>
and/or open an issue at https://github.com/kasra-keshavarz/gwf-forcing-data/issues" >&1;

  exit 0;
}

short_usage () {
  echo "usage: $(basename $0) [-jh] [-i DIR] [-d DATASET] [-co DIR] [-se DATE] [-ln REAL,REAL] [-p STR]" >&1;
}

version () {
  echo "$(basename $0): version $VER";
  exit 0;
}


# =======================
# Parsing input arguments
# =======================
# argument parsing using getopt - WORKS ONLY ON LINUX BY DEFAULT
parsedArguments=$(getopt -a -n extract-dataset -o jhVd:i:v:o:s:e:t:l:n:p:c: --long submit-job,help,version,dataset:,dataset-dir:,variable:,output-dir:,start-date:,end-date:,time-scale:,lat-lims:,lon-lims:,prefix:,cache:, -- "$@")
validArguments=$?
# check if there is no valid options
if [ "$validArguments" != "0" ]; then
  short_usage;
  exit 1;
fi

# check if no options were passed
if [ $# -eq 0 ]; then
  short_usage;
  exit 1;
fi

# check long and short options passed
eval set -- "$parsedArguments"
while :
do
  case "$1" in
    -h | --help)          usage                ; shift   ;; # optional
    -V | --version)	      version	           ; shift   ;; # optional
    -j | --submit-job)    jobSubmission=true   ; shift   ;; # optional
    -i | --dataset-dir)   datasetDir="$2"      ; shift 2 ;; # required
    -d | --dataset)       dataset="$2"         ; shift 2 ;; # required
    -v | --variable)	  variables="$2"       ; shift 2 ;; # required
    -o | --output-dir)    outputDir="$2"       ; shift 2 ;; # required
    -s | --start-date)    startDate="$2"       ; shift 2 ;; # required
    -e | --end-date)      endDate="$2"         ; shift 2 ;; # required
    -t | --time-scale)    timeScale="$2"       ; shift 2 ;; # required
    -l | --lat-lims)      latLims="$2"         ; shift 2 ;; # required
    -n | --lon-lims)      lonLims="$2"         ; shift 2 ;; # required
    -p | --prefix)	      prefixStr="$2"       ; shift 2 ;; # required
    -c | --cache)	      cache="$2"	       ; shift 2 ;; # optional

    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;

    # in case of invalid option
    *) echo "$(basename $0): invalid option '$1'" >$2;
       short_usage;
       exit 1;;
  esac
done

# check mandatory arguments whether provided
if [[ -z "${datasetDir}" ]] || \
   [[ -z "${dataset}"    ]] || \
   [[ -z "${variables}"  ]] || \
   [[ -z "${outputDir}"  ]] || \
   [[ -z "${startDate}"  ]] || \
   [[ -z "${endDate}"    ]] || \
   [[ -z "${latLims}"    ]] || \
   [[ -z "${lonLims}"    ]] || \
   [[ -z "${prefixStr}"  ]]; then

   echo "$(basename $0): mandatory option(s) missing.";
   short_usage;
   exit 1;
fi

# default value for timeScale if not provided as an argument
if [[ -z $timeScale ]]; then
  timeScale="M"
fi
# default value for cache path if not provided as an argument
if [[ -z $cache ]]; then
  cache="$HOME/.temp_gwfdata"
fi

# put necessary arguments in an array - just to make things more legible
# these variables are global anyways...
declare -A funcArgs=([jobSubmission]="$jobSubmission" \
		     [datasetDir]="$datasetDir" \
             [variables]="$variables" \
		     [outputDir]="$outputDir" \
		     [startDate]="$startDate" \
		     [endDate]="$endDate" \
		     [timeScale]="$timeScale" \
		     [latLims]="$latLims" \
		     [lonLims]="$lonLims" \
		     [prefixStr]="$prefixStr" \
		     [cache]="$cache" \
		    );

# =================================
# Template data processing function
# =================================
call_processing_func () {

  # extract the script name
  local script="$1"

  # prepare a script in string format
  # all processing script files must follow same input argument standard
  local scriptRun
  read -rd '' scriptRun <<- EOF
	bash ./${script} -i "${funcArgs[datasetDir]}" -v "${funcArgs[variables]}" -o "${funcArgs[outputDir]}" -s "${funcArgs[startDate]}" -e "${funcArgs[endDate]}" -t "${funcArgs[timeScale]}" -l "${funcArgs[latLims]}" -n "${funcArgs[lonLims]}" -p "${funcArgs[prefixStr]}" -c "${funcArgs[cache]}";
	EOF

  # evaluate the script file using the arguments provided
  if [[ "${funcArgs[jobSubmission]}" == true ]]; then
    # SLURM batch file
    sbatch <<- EOF
	#!/bin/bash

	#SBATCH --account=rpp-kshook
	#SBATCH --time=4:00:00
	#SBATCH --cpus-per-task=1
	#SBATCH --mem=16GB
	#SBATCH --job-name=GWF_${script}
	#SBATCH --error=$HOME/GWF_job_id_%j_err.txt
	#SBATCH --output=$HOME/GWF_job_id_%j.txt

	srun ${scriptRun}
	EOF
    echo "$(basename $0): job submission details are printed under ${HOME}"
  else
    eval "$scriptRun"
  fi
}


# ======================
# Checking input dataset
# ======================

case "${dataset,,}" in
  # NCAR-GWF CONUSI
  "conus1" | "conusi" | "conus_1" | "conus_i" | "conus 1" | "conus i" | "conus-1" | "conus-i")
    call_processing_func "./conus_i/conus_i.sh"
    ;;

  # NCAR-GWF CONUSII
  "conus2" | "conusii" | "conus_2" | "conus_ii" | "conus 2" | "conus ii" | "conus-2" | "conus-ii")
    call_processing_func "./conus_ii/conus_ii.sh"
    ;;

  # ECMWF ERA5
  "era_5" | "era5" | "era-5" | "era 5")
    call_processing_func "./era5/era5.sh"
    ;;
  
  # ECCC RDRS 
  "rdrs" | "rdrsv2.1")
    call_processing_func "./rdrs/rdrs.sh"
    ;;

  # dataset not included above
  *)
    echo "$(basename $0): missing/unknown dataset";
    exit 1;;
esac

