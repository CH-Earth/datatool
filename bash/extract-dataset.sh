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
				   'CONUSI';
       -i, --dataset-dir=DIR       The source path of the dataset file(s)
       -o, --output-dir=DIR        Writes processed files to DIR
       -s, --start-date=STRING     The start date of the forcing data
       -e, --end-date=STRING       The end date of the forcing data
       -t, --time-scale=CHAR       The time scale of interest, i.e., H (hourly), D (Daily), M (Monthly), Y (Yearly)
       -l, --lat-box=INT,INT       Latitude's upper and lower bounds
       -n, --lon-box=INT,INT       Longitude's upper and lower bounds
       -j, --submit-job            Submit the data extraction process as a job on the SLURM system
       -h, --help                  Print this message

Email bug reports, questions, discussions to <kasra.keshavarz AT usask DOT ca>
and/or open an issue at https://github.com/kasra-keshavarz/gwf-forcing-data/issues" >&1;

}

short_usage() {
  echo "usage: $0 [-jh] [-i DIR] [-d DATASET] [-o DIR] [-se DATE] [-ln INT,INT]" >&1;
}


# =======================
# Parsing input arguments
# =======================

# argument parsing using getopt - WORKS ONLY ON LINUX BY DEFAULT
parsedArguments=$(getopt -a -n extract-dataset -o jhi:d:o:s:e:t:l:n: --long submit-job,help,dataset-dir:,dataset:,output-dir:,start-date:,end-date:,time-scale:,lat-box:,lon-box:, -- "$@")
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
    *) echo "$0: invalid option '$1'" >$2;
       short_usage;
       exit 1;;
  esac
done

# put necessary arguments in an array - just to make things more legible
# these variables are global anyways...
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

call_processing_func () {

  # extract the script name
  local script="$1"

  # prepare a script running string
  # all processing script files must follow same input argument standard
  local scriptRun
  read -rd '' scriptRun <<- EOF
	bash ./${script} -i ${funcArgs[datasetDir]} -o ${funcArgs[outputDir]} -s ${funcArgs[startDate]} -e ${funcArgs[endDate]} -t ${funcArgs[timeScale]} -l ${funcArgs[latBox]} -n ${funcArgs[lonBox]};
	EOF

  # evaluate the script file using the arguments provided
  if [[ "${funcArgs[jobSubmission]}" == true ]]; then
    # SLURM batch file
    sbatch <<- EOF
	#!/bin/bash

	#SBATCH --account=rpp-kshook
	#SBATCH --time=8:00:00
	#SBATCH --cpus-per-task=1
	#SBATCH --mem=4GB
	#SBATCH --job-name=GWF_${script}
	#SBATCH --error=$HOME/GWF_job_id_%j_err.txt
	#SBATCH --output=$HOME/GWF_job_id_%j.txt

	srun ${scriptRun}
	EOF
  else
    eval "$scriptRun"
  fi
}


# ======================
# Checking input dataset
# ======================

case "${forcingData,,}" in
  # NCAR-GWF CONUSI
  conus1 | conusi | conus_1 | conus_i | "conus 1" | "conus i" | "conus-1" | "conus-ii")
    call_processing_func "conus_i.sh";;

  # NCAR-GWF CONUSII
  conus2 | conusii | conus_2 | conus_ii | "conus 2" | "conus ii" | "conus-2" | "conus-ii")
    call_processing_func "conus_ii.sh";;

  # ECMWF ERA5
  era_5 | era5)
    call_processing_func "era_5.sh";;

  # dataset not included above
  *)
    echo "$0: missing/unknown dataset";
    exit 1;;
esac
