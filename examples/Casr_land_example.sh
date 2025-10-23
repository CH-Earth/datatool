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

# This is a simple example to extract ECCC Casr Land (2.1) data for the 
# South Saskatchewan River Basin (SSRB) approximate extents
# from Jan 2015 to Dec 2017.

# As is mentioned on the main webpage of the repository, it is
# recommended to submit annual jobs for this dataset.

# This example is meant to be called from the home directory, as is required by GC Science PBS job submission
cd datatool
echo "The current directory is: $(pwd)"

# chunking done on an 'annual' basis
./extract-dataset.sh  --dataset="casr" \
  --dataset-dir="/home/gol000/store6/reanalysis/post_processing/casr_land_v2p1_masking/outdir/outnetcdf_all" \
  --output-dir="$HOME/scratch/casr_land/" \
  --start-date="2015-01-01" \
  --end-date="2017-12-30" \
  --lat-lims=49,54  \
  --lon-lims=-120,-98 \
  --variable="CaSR_Land_v2.1_TRAF_Aggregated,CaSR_Land_v2.1_SWE_Land" \
  --prefix="casrland_21_" \
  --cluster="./etc/clusters/eccc-science.json" \
  --email="joel.trubilowicz@ec.gc.ca" \
  -j;

