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

# This is a simple example to extract ECCC RDRSv2.1 data for the 
# South Saskatchewan River Basin (SSRB) approximate extents
# from Jan 1980 to Dec 2018.

# As is mentioned on the main webpage of the repository, it is
# recommended to submit annual jobs for this dataset.

# Always call the script in the root directory of the repository
cd ..
echo "The current directory is: $(pwd)"

# chunking done on an 'annual' basis
./extract-dataset.sh  --dataset=RDRS \
  --dataset-dir="/project/rpp-kshook/Model_Output/RDRSv2.1" \
  --output-dir="$HOME/scratch/rdrs_output/" \
  --start-date="1980-01-01" \
  --end-date="2018-12-30" \
  --lat-lims=49,54  \
  --lon-lims=-120,-98 \
  --variable="RDRS_v2.1_P_P0_SFC,RDRS_v2.1_P_HU_1.5m,RDRS_v2.1_P_TT_1.5m,RDRS_v2.1_P_UVC_10m,RDRS_v2.1_A_PR0_SFC,RDRS_v2.1_P_FB_SFC,RDRS_v2.1_P_FI_SFC" \
  --prefix="rdrsv2.1_" \
  --email="youremail@company.ca" \
  -j;

