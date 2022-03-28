#!/bin/bash

#######################################
# populating an array of dates based
# on the input format and time-step
# ranged between the start and end
# points
#
# Globals:
#   dateRangeArr: array of dates
#
# Arguments:
#   1: start date
#   2: end date
#   3: format string parsable by `date`
#   4: time-step, e.g., "1hour"
#
# Outputs:
#   produces the following variables:
#    5) dateRangeArr
#######################################
date_range () {
  # assigning local variables to input arguments
  local start=$1    # start date
  local end=$2      # end date
  local fmt=$3      # format of the ouput dates
  local tstep=$4    # the time-step value parsable by bash `date`
  local curr=$start # current time-step

  # make Unix EPOCH time 
  local currUnix=$(date --date="$curr" "+%s")
  local endUnix=$(date --date="$end" "+%s")

  # a global array variable
  dateRangeArr=()

  while [[ "$currUnix" -le "$endUnix" ]]; do
    dateRangeArr+=($(date --date="${curr}" "+${fmt}"))
    curr=$(date --date="${curr} ${tstep}")
     
    # update $currUnix for the `while` loop
    currUnix=$(date --date="${curr}" "+%s")
  done
}

date_range "2012-12-12 12:00:00" "2012-12-31 13:00:00" "1hour" "%Y-%m-%dT%H:%M:%S"

echo "${dateRangeArr[@]}"
