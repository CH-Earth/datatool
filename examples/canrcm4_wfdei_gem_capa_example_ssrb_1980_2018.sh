#!/bin/bash

# Meteorological Data Processing Workflow
# Copyright (C) 2022, University of Saskatchewan
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

# This is a simple example to extract CanRCM4 data for the 
# South Saskatchewan River Basin (SSRB) approximate extents
# from Jan 1980 to Dec 2020.

# As is mentioned on the main webpage of the repository, it is
# recommended to submit annual jobs for this dataset.

# Always call the script in the root directory of the repository
cd ..
echo "The current directory is: $(pwd)"

# First, submitting wihtout disaggregation
./extract-dataset.sh  --dataset="canrcm4_wfdei_gem_capa" \
  --dataset-dir="/project/rpp-kshook/Model_Output/280_CanRCM4_Cor_WFDEI-GEM-CaPA" \
  --output-dir="$HOME/scratch/canrcm4_output/" \
  --start-date="1980-01-01 00:00:00" \
  --end-date="2020-12-31 21:00:00" \
  --lat-lims=49,54 \
  --lon-lims=-120,-98 \
  --variable="pr,hus,wind" \
  --prefix="canrcm4_" \
  --ensemble="r8i2p1r1,r8i2p1r3" \
  --email="youremail@company.ca" \
  -j;

