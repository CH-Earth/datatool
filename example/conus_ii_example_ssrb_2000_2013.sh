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

# This is a simple example to extract WRF-CONUSI data for the 
# South Saskatchewan River Basin (SSRB) approximate extents
# from Oct 2010 to Dec 2013.

# As is mentioned on the main webpage of the repository, it is
# recommended to submit annual jobs for this dataset.

# Always run call the script in the root directory of this repository
cd ..
echo "The current directory is: $(pwd)"

# due to the nature of the dataset, it would be
# better to submit jobs on a monthly basis
for year in {1995..2015}; do
  for month in {1..12}; do
    begin_month="$(date --date="$year-$month-01" +"%Y-%m-%d")";
    end_month="$(date --date="$year-$month-01 1month -1day" +"%Y-%m-%d")";

    ./extract-dataset.sh  --dataset=CONUS2 \
      --dataset-dir="/project/rpp-kshook/Model_Output/wrf-conus/CONUSII/hist" \
      --output-dir="$HOME/scratch/conus_ii_output/" \
      --start-date="$begin_month" \
      --end-date="$end_month" \
      --lat-lims=49,54 \
      --lon-lims=-120,-98 \
      --variable="T2,PREC_ACC_NC,Q2,ACSWDNB,ACLWDNB,U10,V10,PSFC" \
      --prefix="conus_ii" \
      -j;
  done
done

