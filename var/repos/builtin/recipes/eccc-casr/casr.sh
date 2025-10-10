#!/bin/bash
# Meteorological Data Processing Workflow
# Copyright (C) 2022-2023, University of Saskatchewan
# Copyright (C) 2023-2025, University of Calgary
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
# Usage functions
# ===============
short_usage() {
  echo "usage: $(basename $0) [-cio DIR] [-v VARS] [-se DATE] [-t CHAR] [-ln REAL,REAL] [-p STR]"
}


# argument parsing using getopt - WORKS ONLY ON LINUX BY DEFAULT
parsedArguments=$( \
  getopt --alternative \
  --name "casr" \
  -o i:v:o:s:e:t:l:n:p:c:m:S:M: \
  --long dataset-dir:,variable:, \
  --long output-dir:,start-date:, \
  --long end-date:,time-scale:, \
  --long lat-lims:,lon-lims:,prefix:, \
  --long cache:,ensemble:,scenario:, \
  --long model: -- "$@" \
)
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
    -v | --variable)      variables="$2"       ; shift 2 ;; # required
    -o | --output-dir)    outputDir="$2"       ; shift 2 ;; # required
    -s | --start-date)    startDate="$2"       ; shift 2 ;; # required
    -e | --end-date)      endDate="$2"         ; shift 2 ;; # required
    -t | --time-scale)    timeScale="$2"       ; shift 2 ;; # redundant - added for compatibility
    -l | --lat-lims)      latLims="$2"         ; shift 2 ;; # required
    -n | --lon-lims)      lonLims="$2"         ; shift 2 ;; # required
    -p | --prefix)	      prefix="$2"          ; shift 2 ;; # optional
    -c | --cache)         cache="$2"           ; shift 2 ;; # required
    -m | --ensemble)      ensemble="$2"        ; shift 2 ;; # redundant - added for compatibility
    -S | --scenario)      scenario="$2"        ; shift 2 ;; # redundant - added for compatibility
    -M | --model)         model="$2"           ; shift 2 ;; # redundant - added for compatibility

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

# check if $ensemble is provided
if [[ -n "$ensemble" ]] || \
   [[ -n "$scenario" ]] || \
   [[ -n "$model" ]]; then
  echo "$(logDate)$(basename $0): ERROR! redundant argument(s) provided";
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

# paths
datatoolPath="$(dirname $0)/../../../../../" # datatool's path
# daymet index scripts works on CaSR3.1 grids as well
coordIdxScript="$datatoolPath/etc/scripts/coord_daymet_idx.ncl"
coordClosestIdxScript="$datatoolPath/etc/scripts/coord_closest_daymet_idx.ncl"


# ==========================
# Necessary global variables
# ==========================
# the structure of file names is as follows: "YYYYMMDD12.nc"
latDim="rlat"
lonDim="rlon"


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


# ===============
# Data processing
# ===============
# display info
echo "$(logDate)$(basename $0): processing ECCC CaSRv3.1..."

# make the output directory
echo "$(logDate)$(basename $0): creating output directory under $outputDir"
mkdir -p "$outputDir"
echo "$(logDate)$(basename $0): creating cache directory under $cache"
mkdir -p "$cache"


# ======================
# Extract domain extents
# ======================
# choose a sample file as all files share the same grid
domainFile="$(find "${datasetDir}/" -type f -name "*.nc" | head -n 1)"

# parse the upper and lower bounds of a given spatial limit
minLat="$(echo $latLims | cut -d ',' -f 1)"
maxLat="$(echo $latLims | cut -d ',' -f 2)"
minLon="$(echo $lonLims | cut -d ',' -f 1)"
maxLon="$(echo $lonLims | cut -d ',' -f 2)"

# adding/subtracting 0.1 degree to/from max/min values
minLat="$(bc <<< "$minLat - 0.1")"
maxLat="$(bc <<< "$maxLat + 0.1")"
minLon="$(bc <<< "$minLon - 0.1")"
maxLon="$(bc <<< "$maxLon + 0.1")"

# updating $latLims and $lonLims based on new values
latLims="${minLat},${maxLat}"
lonLims="${minLon},${maxLon}"

# extract the associated indices corresponding to $latLims and $lonLims
coordIdx="$(ncl -nQ 'coord_file='\"$domainFile\" 'minlat='"$minLat" 'maxlat='"$maxLat" 'minlon='"$minLon" 'maxlon='"$maxLon" "$coordIdxScript")"

# if spatial index out-of-bound, i.e., 'ERROR' is return
if [[ "${coordIdx}" == "ERROR" ]]; then
  # extract the closest index values
  coordIdx="$(ncl -nQ 'coord_file='\"$domainFile\" 'minlat='"$minLat" 'maxlat='"$maxLat" 'minlon='"$minLon" 'maxlon='"$maxLon" "$coordClosestIdxScript")"
fi

# parse the output index for latitude and longitude
lonLimsIdx+="$(echo $coordIdx | cut -d ' ' -f 1)"
latLimsIdx+="$(echo $coordIdx | cut -d ' ' -f 2)"


# =====================
# Extract dataset files
# =====================
#######################################
# Calculate and format a date by applying
# a time shift to a Unix EPOCH timestamp
#
# Globals:
#   None
#
# Arguments:
#   1: Time shift specification (e.g., "+1days", "-2weeks")
#   2: Unix EPOCH timestamp
#   3: (Optional) Date format string (default: "%Y-%m-%dT%H:%M:%S")
#
# Outputs:
#   The resulting date in specified format after applying the time shift
#   to the input timestamp. Defaults to ISO 8601 format if no format given.
#
# Examples:
#   get_shifted_date "+1days" "1748626663"
#   # Output: 2025-06-01T00:37:43
#
#   get_shifted_date "-2weeks" "1748626663" "%Y-%m-%d"
#   # Output: 2025-05-18
#
#   get_shifted_date "+3hours" "1748626663" "%H:%M:%S"
#   # Output: 03:37:43
#######################################
get_shifted_date() {
    local time_shift="$1"
    local epoch_time="$2"
    local date_format="${3:-"%Y-%m-%dT%H:%M:%S"}"
    
    if [[ -z "$time_shift" || -z "$epoch_time" ]]; then
        echo "Usage: get_shifted_date <time_shift> <unix_epoch> [date_format]"
        return 1
    fi
    
    date --date="$(date -d "@$epoch_time") $time_shift" +"$date_format"
}

# define necessary dates
# Assure the start-date is not before 1980-01-01
startDateInt=$(date --date="$startDate" +"%Y%m%d%H")
if [[ $startDateInt -lt "1979123113" ]]; then
  echo "$(logDate)$(basename $0): WARNING! The date range of the dataset is between 1979-12-31T13:00:00 and 2024-12-31T12:00:00"
  echo "$(logDate)$(basename $0): WARNING! \`start-date\` is set to 1979-12-31 13:00:00"
  startDate="1979-12-31T13:00:00"
fi

# Assure the end-date is not beyond 2024-12-31
endDateInt=$(date --date="$endDate" +"%Y%m%d%H")
if [[ $endDateInt -gt "2024123112" ]]; then
  echo "$(logDate)$(basename $0): WARNING! The date range of the dataset is between 1979-12-31T13:00:00 and 2024-12-31T12:00:00"
  echo "$(logDate)$(basename $0): WARNING! \`end-date\` is set to 2024-12-31 12:00:00"
  endDate="2024-12-31T12:00:00"
fi

# Date values for iterations over dataset files
toDate="${startDate}"
toDateUnix="$(unix_epoch "$startDate")"

endDateIter="$(date --date="$endDate +1days" +"%Y-%m-%dT%H:00:00")"
endDateIterUnix="$(unix_epoch "$endDateIter")"
endDateUnix="$(unix_epoch "$endDate")"

# Creating output and cache directories
mkdir -p "$outputDir" # output directory
mkdir -p "$cache" # cache directory

# First file counter
firstFile=1

# Extract variables from the forcing data files
while [[ "$toDateUnix" -le "$endDateIterUnix" ]]; do
  # Calculate the two boundary timestamps to determine the NetCDF to
  # manipulate
  yesterday_13="$(get_shifted_date "-1days" "${toDateUnix}" "%Y-%m-%dT13:00:00")"
  today_12="$(get_shifted_date "+0days" "${toDateUnix}" "%Y-%m-%dT12:00:00")"
  today_13="$(get_shifted_date "+0days" "${toDateUnix}" "%Y-%m-%dT13:00:00")"
  tomorrow_12="$(get_shifted_date "+1days" "${toDateUnix}" "%Y-%m-%dT12:00:00")"

  # UNIX EPOCH equivalents
  yesterday_13_Unix="$(unix_epoch "${yesterday_13}")"
  today_12_Unix="$(unix_epoch "${today_12}")"
  today_13_Unix="$(unix_epoch "${today_13}")"
  tomorrow_12_Unix="$(unix_epoch "${tomorrow_12}")"

  # change the range
  if [[ "${toDateUnix}" -ge "${today_13_Unix}" ]] && \
     [[ "${toDateUnix}" -le "${tomorrow_12_Unix}" ]]; then
    shiftDate="+0days"
  elif [[ "${toDateUnix}" -ge "${yesterday_13_Unix}" ]] && \
       [[ "${toDateUnix}" -le "${today_12_Unix}" ]]; then
    shiftDate="-1days"
  fi

  # fileDate in the CaSR file format
  fileDate="$(get_shifted_date "$shiftDate" "$toDateUnix")"
  fileDateFormatted="$(date --date="$fileDate" +"%Y%m%d12")"

  # # file name
  file="${fileDateFormatted}.nc"

  # Specify file's start and end dates
  if [[ "$shiftDate" == "+0days" ]]; then
    fileStartDate="$(date --date="@${today_13_Unix}" +"%Y-%m-%dT%H:00:00")"
  elif [[ "$shiftDate" == "-1days" ]]; then
    fileStartDate="$(date --date="@${yesterday_13_Unix}" +"%Y-%m-%dT%H:00:00")"
  fi

  # If $endDateUnix is greater than $toDate at 12 o'clock, assign 
  # $endDateUnix as $fileEndDate, otherwise, $toDateUnix at 12 o'clock
  if [[ "$shiftDate" == "+0days" ]]; then
    fileEndDate="$(date --date="@${tomorrow_12_Unix}" +"%Y-%m-%dT%H:00:00")"
  elif [[ "$shiftDate" == "-1days" ]]; then
    fileEndDate="$(date --date="@${today_12_Unix}" +"%Y-%m-%dT%H:00:00")"
  fi

  # If $fileStartDate is earlier than the input $startDate, assign that
  # instead
  fileStartDateUnix="$(unix_epoch "$fileStartDate")"
  if [[ "$firstFile" == 1 ]]; then
    firstFile=0
    startDateUnix="$(unix_epoch "$startDate")"
    if [[ "$fileStartDateUnix" -lt "$startDateUnix" ]]; then
      fileStartDate="$(date --date="@${startDateUnix}" +"%Y-%m-%dT%H:00:00")"
      fileStartDateUnix="$(unix_epoch "$fileStartDate")"
    fi
  fi

  # If $fileEndDate is beyond the input $endDate, assign that instead
  fileEndDateUnix="$(unix_epoch "$fileEndDate")"
  if [[ "$fileEndDateUnix" -gt "$endDateUnix" ]]; then
    fileEndDate="$(date --date="@${endDateUnix}" +"%Y-%m-%dT%H:00:00")"
    fileEndDateUnix="$(unix_epoch "$fileEndDate")"
  fi

  # If fileEndDate goes beyond fileStartDate; continue
  if [[ "$fileEndDateUnix" -lt "$fileStartDateUnix" ]]; then
    break 1
  fi

  # If the filestartDate equals startDate, or if fileEndDate equals
  # endDate then subset time as well, otherwise, no need for time
  # subsetting (to save computational time)
  if [[ ${fileStartDateUnix} == ${startDateUnix} ]] ||
     [[ ${fileEndDateUnix} == ${endDateUnix} ]]; then
    until cdo -z zip \
        -s -L \
        -sellonlatbox,"$lonLims","$latLims" \
        -selvar,"$variables" \
        -seldate,"${fileStartDate}","${fileEndDate}" \
        "${datasetDir}/${file}" \
        "${cache}/${file}"; do
      echo "$(logDate)$(basename $0): Process killed: restarting process in 10 sec" >&2
      echo "CDO [...] failed" >&2
      sleep 10;
    done # until ncks
  else
    until cdo -z zip \
        -s -L \
        -sellonlatbox,"$lonLims","$latLims" \
        -selvar,"$variables" \
        "${datasetDir}/${file}" \
        "${cache}/${file}"; do
      echo "$(logDate)$(basename $0): Process killed: restarting process in 10 sec" >&2
      echo "CDO [...] failed" >&2
      sleep 10;
    done # until ncks
  fi

  # Remove any left-over .tmp file
  if [[ -e ${cache}/*${file}*.tmp ]]; then
    rm -r "${cache}/*${file}*.tmp"
  fi

  # Wait for any left-over processes to finish
  wait

  # Change lon values so the extents are from ~-180 to 0
  # assuring the process finished using an `until` loop
  until ncap2 -O -s 'where(lon>0) lon=lon-360' \
          "${cache}/${file}" \
          "${cache}/lon_${file}"; do
    rm "${cache}/lon_${file}*"
    echo "$(logDate)$(basename $0): Process killed: restarting process in 10 sec" >&2
    echo "$(logDate)$(basename $0): NCAP2 -s [...] failed" >&2
    sleep 10;
  done

  # Check to see if the final file exists in the $outputDir
  if [[ -f "${outputDir}/${prefix}${file}" ]]; then
    # If it already has 24 time-steps (complete file), skip it
    tSteps="$(cdo ntime "${outputDir}/${prefix}${file}" | head -n 1)"

    if [[ $tSteps != 24 ]]; then
      # Copying the existing file to cache for further merging
      cp "${outputDir}/${prefix}${file}" "${cache}/temp_${file}"

      # Enable skipping duplicate time-steps
      export SKIP_SAME_TIME=1

      # Merging existing time-steps (temp_) with the extracted ones (lon_)
      echo "$(logDate)$(basename $0): WARNING! File ${prefix}${file} already exists in ${outputDir}" >&2;
      echo "$(logDate)$(basename $0): Merging missing time-steps" >&2;
      cdo -O mergetime "${cache}/lon_${file}" "${cache}/temp_${file}" \
        "${cache}/merged_${file}" >&2;

      # Copy the merged_ file to the $outputDir
      cp "${cache}/merged_${file}" "${outputDir}/${prefix}${file}"

    else
      echo "$(logDate)$(basename $0): ${prefix}${file} and all time-steps already exist, skipping" >&2;
    fi

  else
    # Otherwise, copy whatever has been extracted
    cp "${cache}/lon_${file}" "${outputDir}/${prefix}${file}"
  fi

  # Remove any left-over .tmp file
  if [[ -e ${cache}/*${file}*.tmp ]]; then
    rm -r "${cache}/*${file}*.tmp"
  fi

  # Wait for any left-over processes to finish
  wait

  # Increment time-step by one unit
  toDate="$(date --date "$toDate +1days" +"%Y-%m-%dT%H:00:00")"
  toDateUnix="$(unix_epoch "$toDate")" # current timestamp in unix EPOCH time
done

# Take care of intermediary files, etc.
mkdir -p "$HOME/empty_dir"
echo "$(logDate)$(basename $0): deleting temporary files from $cache"
rsync -aP --delete "$HOME/empty_dir/" "$cache"
rm -r "$cache"

# End notices
echo "$(logDate)$(basename $0): temporary files from $cache are removed"
echo "$(logDate)$(basename $0): results are extracted under $outputDir"

