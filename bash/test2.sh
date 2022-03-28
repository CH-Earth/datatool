#!/bin/bash

#######################################
# end of a chosen time-frame minus
# the value of the time-step, e.g.,
#   1. end of the year date based on
#      hourly time-steps
#   2. end of the month based on daily
#      time-steps
#
# Globals:
#   None
#
# Arguments:
#   1. dateStr
#   2. time-frame, i.e., year, mmonth, 
#			 day, hour
#      (parsable by GNU date)
#   3. time-step, i.e., year, month, 
#			day, hour
#      (parsable by GNU date)
#
# Outputs:
#   prints the end of the time-frame
#   at the last time-step to the stdout
#######################################
timeFrameEnd () {
  local dateStr=$1	# date string
  local timeFrame=$2	# time-frame
  local timeStep=$3	# time-step
  local fmt=$4		# date format

  case "${timeFrame,,}" in
    year)
      local dateStrTrim=$(date --date="$dateStr" "+%Y-01-01 00:00:00")
      ;;
    month)
      local dateStrTrim=$(date --date="$dateStr" "+%Y-%m-01 00:00:00")
      ;;
    day)
      local dateStrTrim=$(date --date="$dateStr" "+%Y-%m-%d 00:00:00")
      ;;
    hour)
      local dateStrTrim=$(date --date="$dateStr" "+%Y-%m-%d 00:00:00")
      ;;
    minute)
      local dateStrTrim=$(date --date="$dateStr" "+%Y-%m-%d %H:00:00")
      ;;
    second)
      local dateStrTrim=$(date --date="$dateStr" "+%Y-%m-%d %H:%M:00")
      ;;
  esac

  local endDateStr="$(date --date="$dateStrTrim +1${timeFrame} -1${timeStep}")"
  echo "$endDateStr"
}

a=$(timeFrameEnd "2012-05-30" "year" "hour")
echo "$a"
