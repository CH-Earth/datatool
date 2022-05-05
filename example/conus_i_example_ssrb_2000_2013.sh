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

# First, submitting for the Oct 2000 to Dec 2000
./extract-dataset.sh  --dataset=CONUS1 \
  --dataset-dir="/project/rpp-kshook/Model_Output/WRF/CONUS/CTRL" \
  --output-dir="$HOME/scratch/conus_i_output/" \
  --start-date="2000-10-01 00:00:00" \
  --end-date="2000-12-31 23:00:00" \
  --lat-lims=49,54  \
  --lon-lims=-120,-98 \
  --variable="T2,PREC_ACC_NC,Q2,ACSWDNB,ACLWDNB,U10,V10,PSFC" \
  --prefix="conus_i" \
  -j;

# Second, submitting for years 2001 to 2013,
# due to the nature of the dataset, it would be
# better to submit jobs on a 3-month basis
for year in {2001..2013}; do
  for qrtr in {1,4,7,10}; do
    begin_qrtr="$(date --date="$year-$qrtr-01" +"%Y-%m-%d %H:%M:%S")";
    end_qrtr="$(date --date="$year-$qrtr-01 +3month -1hour" +"%Y-%m-%d %H:%M:%S")";

    ./extract-dataset.sh  --dataset=CONUS1 \
      --dataset-dir="/project/rpp-kshook/Model_Output/WRF/CONUS/CTRL" \
      --output-dir="$HOME/scratch/conus_i_output/" \
      --start-date="$begin_qrtr" \
      --end-date="$end_qrtr" \
      --lat-lims=49,54 \
      --lon-lims=-120,-98 \
      --variable="T2,PREC_ACC_NC,Q2,ACSWDNB,ACLWDNB,U10,V10,PSFC" \
      --prefix="conus_i" \
      -j;
  done
done

