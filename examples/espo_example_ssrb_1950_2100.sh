#!/bin/bash

# Meteorological Data Processing Workflow
# Copyright (C) 2022, University of Saskatchewan
# Copyright (C) 2023-2024, University of Calgary
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

# This is a simple example to extract Daymet data for the 
# South Saskatchewan River Basin (SSRB) approximate extents
# from Jan 1950 to Dec 2100.

# As is mentioned on the main webpage of the repository, it is
# recommended to submit annual jobs for this dataset.

# Always call the script in the root directory of the repository
cd ..
echo "The current directory is: $(pwd)"

./extract-dataset.sh \
  --dataset="espo-g6-r2" \
  --dataset-dir="/project/rrg-mclark/data/meteorological-data/espo-g6-r2/ESPO-G6-R2v1.0.0"
  --variable="pr,tasmax,tasmin" \
  --output-dir="/project/rrg-mclark/AON/share/ESPO-G6-R2-SMM" \
  --start-date="1950-01-01" \
  --end-date="2100-12-31" \
  --model="AS-RCEC,BCC,CAS,CCCma,CMCC,CNRM-CERFACS,CSIRO,CSIRO-ARCCSS,DKRZ,EC-Earth-Consortium,INM,IPSL,MIROC,MOHC,MPI-M,MRI,NCC,NIMS-KMA,NOAA-GFDL,NUIST"
  --lat-lims=49,54 \
  --lon-lims=-120,-98 \
  --ensemble="r1i1p1f1,r1i1p1f2" \
  --scenario="ssp245,ssp370,ssp585" \
  --prefix="SRB_" \
  --cache='$SLURM_TMPDIR' \
  --email="example@company.ca" \
  --submit-job;

