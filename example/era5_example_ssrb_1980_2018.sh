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

# This is a simple example to extract ECMWF ERA5 data for the 
# South Saskatchewan River Basin (SSRB) approximate extents
# from Jan 1980 to Dec 2020.

# As is mentioned on the main webpage of the repository, it is
# recommended to submit annual jobs for this dataset.

# Always call the script in the root directory of the repository
cd ..
echo "The current directory is: $(pwd)"

# chunking done on a '6-month' basis
./extract-dataset.sh  --dataset=ERA5 \
  --dataset-dir="/project/rpp-kshook/CompHydCore/climateForcingData/ERA5/ERA5_for_SUMMA/2_merged_data" \
  --output-dir="$HOME/scratch/era5_output/" \
  --start-date="1980-01-01" \
  --end-date="2020-12-31" \
  --lat-lims=49,54 \
  --lon-lims=-120,-98 \
  --variable="airpres,pptrate,spechum,windspd,airtemp,SWRadAtm,LWRadAtm" \
  --prefix="era5_" \
  --email="youremail@company.ca" \
  -j;

