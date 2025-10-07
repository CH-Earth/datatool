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

# This is a simple example to extract ECCC CasrV3.1 data for the 
# South Saskatchewan River Basin (SSRB) approximate extents
# from Jan 2015 to Dec 2018.

# As is mentioned on the main webpage of the repository, it is
# recommended to submit annual jobs for this dataset.

# This example is meant to be called from the home directory, as is required by GC Science PBS job submission
cd datatool
echo "The current directory is: $(pwd)"

# chunking done on an 'annual' basis
./extract-dataset.sh  --dataset="casr" \
  --dataset-dir="/home/scar700/data/ppp6/CaSRv3.1/postproc_casr4caspar_20250416/link2out4pilot_netcdf/" \
  --output-dir="$HOME/scratch/casr31_output/" \
  --start-date="2015-01-01" \
  --end-date="2018-12-30" \
  --lat-lims=49,54  \
  --lon-lims=-120,-98 \
  --variable="CaSR_v3.1_P_TT_1.5m,CaSR_v3.1_A_PR0_SFC" \
  --prefix="casrv3.1_" \
  --cluster="./etc/clusters/eccc-science.json" \
  --email="joel.trubilowicz@ec.gc.ca" \
  -j;

