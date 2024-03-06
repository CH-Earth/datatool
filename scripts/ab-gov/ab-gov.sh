#!/bin/bash
# Meteorological Data Processing Workflow
# Copyright (C) 2022-2023, University of Saskatchewan
# Copyright (C) 2023-2024, University of Calgary
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
# 1. Parts of the code are taken from 
#    https://www.shellscript.sh/tips/getopt/index.html


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
  echo "usage: $(basename $0) [-cio DIR] [-v VARS] [-se DATE] [-t CHAR] [-ln REAL,REAL] [-p STR] [-MmS STR[,...]]"
}


# argument parsing using getopt - WORKS ONLY ON LINUX BY DEFAULT
parsedArguments=$(getopt -a -n ab-gov -o i:v:o:s:e:t:l:n:p:c:m:S:M: --long dataset-dir:,variables:,output-dir:,start-date:,end-date:,time-scale:,lat-lims:,lon-lims:,prefix:,cache:,ensemble:,scenario:,model: -- "$@")
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
    -t | --time-scale)    timeScale="$2"       ; shift 2 ;; # redundant - added for compatibility
    -l | --lat-lims)      latLims="$2"         ; shift 2 ;; # required
    -n | --lon-lims)      lonLims="$2"         ; shift 2 ;; # required
    -p | --prefix)        prefix="$2"	         ; shift 2 ;; # optional
    -c | --cache)         cache="$2"	         ; shift 2 ;; # required
    -m | --ensemble)      ensemble="$2"        ; shift 2 ;; # redundant - added for compatibility
    -S | --scenario)      scenario="$2"        ; shift 2 ;; # required
    -M | --model)         model="$2"           ; shift 2 ;; # required

    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;

    # in case of invalid option
    *)
      echo "ERROR $(basename $0): invalid option '$1'";
      short_usage; exit 1 ;;
  esac
done

# useful log date format function
logDate () { echo "($(date +"%Y-%m-%d %H:%M:%S")) "; }

# check if $model is given
if [[ -z $model ]]; then
  echo "$(logDate)$(basename $0): ERROR! \`--model\` value(s) required"
  exit 1;
fi

# check if $scenario is not given
if [[ ! "${model,,}" == *"hybrid"* ]] && \
   [[ -z $scenario ]]; then
  echo "$(logDate)$(basename $0): ERROR! \`--scenario\` value(s) required"
  echo "$(logDate)$(basename $0): WARNING! \`--scenario\` not required for \`Hybrid-observation\` model"
  exit 1;
fi

# check the prefix of not set
if [[ -z $prefix ]]; then
  prefix="data_"
fi


# =====================
# Necessary assumptions
# =====================
# TZ to be set to UTC to avoid invalid dates due to Daylight Saving
alias date='TZ=UTC date'

# expand aliases for the one stated above
shopt -s expand_aliases


# ==========================
# Necessary global variables
# ==========================
latDim="lat"
lonDim="lon"
timeDim="time"


# ===================
# Necessary functions
# ===================
# Modules below available on Digital Research Alliance of Canada's Graham HPC
## core modules
function load_core_modules () {
  module -q load cdo/2.0.4
  module -q load nco/5.0.6
}
function unload_core_modules () {
  # WARNING: DO NOT USE IF YOU ARE NOT SURE HOW TO URE IT
  module -q unload cdo/2.0.4
  module -q unload nco/5.0.6
}
## ncl modules
function load_ncl_module () {
  module -q load ncl/6.6.2
}
function unload_ncl_module () {
  module -q unload ncl/6.6.2
}

# loading core modules for the script
load_core_modules


# =================
# Useful one-liners
# =================
#calcualte Unix EPOCH time in seconds from 1970-01-01 00:00:00
unix_epoch () { date --date="$@" +"%s"; }

#check whether the input is float or real
check_real () { if [[ "$1" == *'.'* ]]; then echo 'float'; else echo 'int'; fi; }

#convert to float if the number is 'int'
to_float () { if [[ $(check_real $1) == 'int' ]]; then printf "%.1f" "$1"; echo; else printf "%.5f" "$1"; echo; fi; }

#join array element by the specified delimiter
join_by () { local IFS="$1"; shift; echo "$*"; }

#to_float the latLims and lonLims, real numbers delimited by ','
lims_to_float () { IFS=',' read -ra l <<< $@; f_arr=(); for i in "${l[@]}"; do f_arr+=($(to_float $i)); done; echo $(join_by , "${f_arr[@]}"); }

# log date format
log_date () { echo "($(date +"%Y-%m-%d %H:%M:%S")) "; }

#offset lims
offset () { float="$1"; offset="$2"; printf "%.1f," $(echo "$float + $offset" | bc) | sed 's/,$//'; }


# ===============
# Data processing
# ===============
# display info
echo "$(log_date)$(basename $0): processing Alberta Government Climate dataset..."

# array of scenarios
IFS=',' read -ra scenarioArr <<< "$scenario"
# array of models
IFS=',' read -ra modelArr <<< "$model"
# array of variables
IFS=',' read -ra variableArr <<< "$variables"
# there is no "esemble" members defined for this dataset

# since, the dataset's grid cell system is gaussian, assure to to_float()
# the $latLims and $lonLims values
latLims="$(lims_to_float "$latLims")"
lonLims="$(lims_to_float "$lonLims")"

# since longitudes are within the [-180, +180] range, no change is
# necessary

# since Hybrid-observation has no scenario, add a hidden scenario for
# later usage down the file
if [[ "${model,,}" == *"hybrid"* ]]; then
  scenarioArr+=('HiddenScenario')
fi


# ================
# Necessary checks
# ================

# check if the dates are within datasets date range
# define $startYear and $endYear
startYear=$(date --date "$startDate" +"%Y")
endYear=$(date --date "$endDate" +"%Y")

# taking care of various possible scenarios for $startDate and $endDate
# $scenario and $model
## #1 if startYear is before 2015, and historical is NOT selected as a
##    scenario, issue a WARNING and add historical to $scenarioArr
if [[ "$startYear" -lt 2015 ]] && \
   [[ "${scenarioArr[*]}" == "historical" ]]; then
  # issue a warning and add historical to the scenarios
  echo "$(logDate)$(basename $0): WARNING! Dates preceeding 2015 belongs to \`hisotrical\` scenario"
  echo "$(logDate)$(basename $0): WARNING! \`historical\` is added to \`--scenario\` list"
  scenarioArr+=("historical")
fi

## #2 if endYear is beyond 2014, and SSP scenarios are NOT
##    selected, issue an ERROR and terminate with exitcode 1
if [[ "$endYear" -gt 2014 ]] && \
   [[ "${scenarioArr[*]}" == "ssp" ]]; then # `ssp` is treated as *ssp*
   echo "$(logDate)$(basename $0): ERROR! Dates past 2015 belong to \`ssp\` scenarios"
   echo "$(logDate)$(basename $0): ERROR! Choose the appropriate date range and try again"
   exit 1;
fi

## #3 if "Hybrid-observations" is needed, SSP scenarios are not applicable
##    and $startYear and $endYear must be between 1950-2019
if [[ "${model,,}" == *"hybrid"* ]] && \
   [[ "${scenario,,}" == *"ssp"* ]]; then
  echo "$(logDate)$(basename $0): WARNING! \`Hybrid-observations\` does not have SSP scenarios"
fi
if [[ "${model,,}" == *"hybrid"* ]]; then
  if [[ "$startYear" -lt "1950" ]] || \
     [[ "$endYear" -gt "2019" ]]; then
    echo "$(logDate)$(basename $0): WARNING! \`Hybrid-observations\` date range is only from 1950 until 2019"
  fi
fi

## #4 if "historical" scenario's date range is from 1950 until 2014
if [[ "${scenarios,,}" == *"historical"* ]]; then
  if [[ "$startYear" -lt "1950" ]] || \
     [[ "$endYear" -gt "2014" ]]; then
     echo "$(logDate)$(basename $0): WARNING! \`historical\` scenario's date range is only from 1950 until 2014"
  fi
fi

## #5 if "ssp*" scenario's date range is before 2014 or beyond 2100
if [[ "${scenarios,,}" == *"ssp"* ]]; then
  if [[ "$startYear" -lt "2015" ]]; then
    echo "$(logDate)$(basename $0): WARNING! \`ssp*\` scenario's start date is 2014-01-01"
  elif [[ "$endYear" -gt "2100" ]]; then
	echo "$(logDate)$(basename $0): WARNING! \`ssp*\` scenario's end date is 2100-12-31"
	echo "$(logDate)$(basename $0): WARNING! \`--end-date\` is set to 2100-12-31"
  fi
fi


# ============================================
# Build date arrays for time-series extraction
# ============================================
# file date intervals in years - dataset's default
interval=1

fileDateFormat="%Y"
actualDateFormat="%Y-%m-%d"

# define needed variables
let "difference = $endYear - $startYear"
let "steps = $difference / $interval"

# build $startDateFileArr, $endDateFileArr
startDateFileArr=()
endDateFileArr=()
actualStartDateArr=()
actualEndDateArr=()

# range of jumps
range=$(seq 0 $steps)

# filling the arrays
for iter in $range; do
  # jumps every $interval years
  let "jumps = $iter * $interval"

  # current date after necessary jumps
  let "toDate = $jumps + $startYear"

  # extract start and end values for files
  startValue="$(date --date "${toDate}0101" +"${fileDateFormat}")"
  endValue="$(date --date "${toDate}0101 +${interval}years -1days" +"${fileDateFormat}")"

  # double-check end-date
  if [[ "$endValue" -gt 2100 ]]; then
    endValue="2100" # irregular last date for dataset files
  fi
 
  # extract start and end values for actual dates
  actualStartValue="$(date --date "${toDate}0102" +"${actualDateFormat}")"
  actualEndValue="$(date --date "${toDate}0101 +${interval}years" +"${actualDateFormat}")"

  # fill up relevant arrays
  startDateFileArr+=("${startValue}")
  endDateFileArr+=("${endValue}")

  actualStartDateArr+=("${actualStartValue}")
  actualEndDateArr+=("${actualEndValue}")
done

# build actualStartArr array for temporal subsetting
actualStartDateArr[0]="$(date --date "${startDate}" +"${actualDateFormat}")"

# and similarly, the actualEndArr array
lastIndex=$(( "${#actualEndDateArr[@]}" - 1 ))
actualEndDateArr[${lastIndex}]="$(date --date "${endDate}" +"${actualDateFormat}")"


# =====================
# Extract dataset files
# =====================
# Typical directory structure of the dataset is:
#   ${datasetDir}/${model}/
# and each ${model} directory contains files in the following nomenclature:
#   Downscaled_${model}_MBCDS_${scenario}_pr_tmn_tmx_%Y.nc
# with the %Y year value indicating the starting year of data inside the
# file
#
# The nomenclature for the "hybrid-observations" $model is different:
#   Hybrid_Daily_BCABSK_US_${var}_%Y.nc 
#
# The date range of each $model and scenario is as follows:
#   * all models except "Hybrid-observations":
#     * historical: 1950-2014
#     * ssp126:     2015-2100
#     * ssp285:     2015-2100
#     * ssp370:     2015-2100
#     * ssp585:     2015-2100
#   * "Hybrid-observations" model: 1950-2019 (no scenarios)

# create dataset directories in $cache and $outputDir
echo "$(logDate)$(basename $0): creating output directory under $outputDir"
mkdir -p "$outputDir"
echo "$(logDate)$(basename $0): creating cache directory under $cache"
mkdir -p "$cache"

# iterate over models/submodels
for model in "${modelArr[@]}"; do
  # extract model and submodel names
  modelName=$(echo $model | cut -d '/' -f 1)

  # $modelVerboseFlag is set to 1
  modelVerboseFlag=1

  # iterate over scenarios, e.g., ssp126, ssp245, ssp370, ssp585 
  for scenario in "${scenarioArr[@]}"; do

    # $scenarioVerboseFlag set to 1
    scenarioVerboseFlag=1

    # FIXME: the check needs to consider various names of the
    # "hybrid-observations", as it is a long name and users will make typo
    # mistakes.
    pathTemplate="${modelName}/"
    if [[ -e "${datasetDir}/${pathTemplate}" ]]; then
      mkdir -p "${cache}/${pathTemplate}"
      mkdir -p "${outputDir}/${pathTemplate}"
    else
      echo "$(logDate)$(basename $0): ERROR! '${model}' model does not exist."
      break;
    fi

    # iterate over date range of interest using index
    for idx in "${!startDateFileArr[@]}"; do

      # dates for files
      fileStartDate="${startDateFileArr[$idx]}"
      fileEndDate="${endDateFileArr[$idx]}"
      # dates for subsetting
      actualStartDate="${actualStartDateArr[$idx]}"
      actualEndDate="${actualEndDateArr[$idx]}"
      # dates for ncks slabs
      actualStartDateFormatted="$(date --date "${actualStartDate}" +'%Y-%m-%d')"
      actualEndDateFormatted="$(date --date "${actualEndDate}" +'%Y-%m-%d')"

      # variable list for output file print
      variableNames=$(echo $variables | tr ',' '_')

      # if 'Hybrid_observation' is selected, it will be treated
      # differently
      case "${modelName,,}" in
        "hybrid_observation" | "hybrid-observation" | "hybrid" | "hybrid-obs" | "hybrid_obs" )
          # if 'HiddenScenario' is not selected, then break
          if [[ ${scenario} == "HiddenScenario" ]]; then

            # if $fileStartDate is beyond 2019, break the loop
            if [[ $fileStartDate -gt "2019" ]]; then
              break # break $scenario for loop
            fi
            pathTemplate="Hybrid-observation/"
            for var in ${variableArr[@]}; do
              # source and destination file names
              src="Hybrid_Daily_BCABSK_US_${var}_${fileStartDate}.nc"
              dst="Hybrid_Daily_BCABSK_US_${variableNames}_${fileStartDate}.nc"
  
              # verbose message
              if [[ -n $modelVerboseFlag ]]; then
                echo "$(logDate)$(basename $0): processing '${model}' files"
                unset modelVerboseFlag
              fi
  
              # spatial subsetting
              until ncks -A -v ${var} \
                        -d "$latDim","${latLims}" \
                        -d "$lonDim","${lonLims}" \
                        -d "$timeDim","${actualStartDateFormatted}","${actualEndDateFormatted}" \
                        ${datasetDir}/${pathTemplate}/${src} \
                        ${cache}/${pathTemplate}/${dst}; do
                    echo "$(logDate)$(basename $0): Process killed: restarting process" >&2
                    sleep 10;
              done # until ncks
    	  
              # copy the results
              cp -r ${cache}/${pathTemplate}/${dst} \
                    ${outputDir}/${pathTemplate}/${prefix}${dst};
  
            done # for $variableArr
          else
            # see if SSP scenario exists for the $model
            sspFile=$(find ${datasetDir}/${pathTemplate} -type f -name "*${scenario}*.nc" | head -n 1)
            if [[ -z $sspFile ]] &&
               [[ -n $scenarioVerboseFlag ]]; then
              echo "$(logDate)$(basename $0): ERROR! '${model}.${scenario}' does not exist"
              unset scenarioVerboseFlag
            fi
          fi
        ;;

        # all other models  
        *)
          if [[ "${scenario}" == *"HiddenScenario"* ]]; then
            break 2;
          fi
          # define file for further operation
          src="Downscaled_${modelName}_MBCDS_${scenario}_pr_tmn_tmx_${fileStartDate}.nc"
          dst="Downscaled_${modelName}_MBCDS_${scenario}_${variableNames}_${fileStartDate}.nc"

          # if historical is set as a scenario, and $fileStartDate is beyond 2014, break
          # the loop
          if [[ ${model,,} == *"historical"* ]] && \
             [[ ${fileStartDate} -gt "2014" ]]; then
             break
          fi

          # see if SSP scenario exists for the $model
          sspFile=$(find ${datasetDir}/${pathTemplate} -type f -name "*${scenario}*.nc" | head -n 1)
          if [[ -z $sspFile ]]; then
            echo "$(logDate)$(basename $0): ERROR! '${model}.${scenario}' does not exist"
            break
          fi

          # verbose message
          if [[ -n $scenarioVerboseFlag ]]; then
            echo "$(logDate)$(basename $0): processing '${model}.${scenario}' files"
            unset scenarioVerboseFlag
          fi

          # spatial subsetting
          until ncks -A -v "${variables}" \
                  -d "$latDim","${latLims}" \
                  -d "$lonDim","${lonLims}" \
                  -d "$timeDim","${actualStartDateFormatted}","${actualEndDateFormatted}" \
                  ${datasetDir}/${pathTemplate}/${src} \
                  ${cache}/${pathTemplate}/${dst}; do
                echo "$(logDate)$(basename $0): Process killed: restarting process" >&2
                sleep 10;
          done # until ncks
  	  
          # copy the results
          cp -r ${cache}/${pathTemplate}/${dst} \
                ${outputDir}/${pathTemplate}/${prefix}${dst};

        ;;
      esac

    done # for $startDateArr
  done # for $scenarioArr
done # for $modelArr

# wait for everything to finish - just in case
sleep 10

mkdir "$HOME/empty_dir"
echo "$(logDate)$(basename $0): deleting temporary files from $cache"
rsync -aP --delete "$HOME/empty_dir/" "$cache"
rm -r "$cache"
echo "$(logDate)$(basename $0): temporary files from $cache are removed"
echo "$(logDate)$(basename $0): results are produced under $outputDir"


