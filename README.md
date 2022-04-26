# Description
This repository contains scripts to process necessary forcing data from various datasets. The general usage of the script (i.e., `./extract-dataset.sh`) is as follows:

```console
Usage:
   extract-dataset [options...]

Script options:
  -d, --dataset				Meteorological forcing dataset of interest
					currently available options are:
					'CONUSI';'ERA5';'CONUS2';'RDRS';
  -i, --dataset-dir=DIR			The source path of the dataset file(s)
  -v, --variable=var1[,var2[...]]	Variables to process
  -o, --output-dir=DIR			Writes processed files to DIR
  -s, --start-date=DATE			The start date of the forcing data
  -e, --end-date=DATE			The end date of the forcing data
  -l, --lat-lims=REAL,REAL		Latitude's upper and lower bounds
  -n, --lon-lims=REAL,REAL		Longitude's upper and lower bounds
  -j, --submit-job			Submit the data extraction process as a job
					on the SLURM system
  -p, --prefix=STR			Prefix  prepended to the output files
  -c, --cache=DIR			Path of the cache directory
  -V, --version				Show version
  -h, --help				Show this screen

```

# Usage
 
As an example, follow the code block below. Please remember that you MUST have access to GRAHAM cluster with Compute Canada (CC) and have access to `CONUS I` model outputs. Also, remember to generate a [Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with GitHub in advance. Enter the following codes in your Graham shell as a test case:

> :warning: The code is not efficient for time periods more than one month. Consider submitting several jobs in cases where longer
time periods are desired from the dataset. Please note that each job submission should not take more than 4 hours.

```console
foo@bar:~$ git clone https://github.com/kasra-keshavarz/gwfdatatool 
foo@bar:~$ cd ./gwf-focring-data/bash/
foo@bar:~$ ./extract-dataset.sh -h # to view the usage message
foo@bar:~$ ./extract-dataset.sh  --dataset=CONUS1 --dataset-dir="$HOME/projects/rpp-kshook/Model_Output/WRF/CONUS/CTRL" --output-dir="$HOME/scratch/CONUSI/" --start-date="2001-01-01 00:00:00" --end-date="2001-01-31 23:00:00" --lat-lims=49,51  --lon-lims=-117,-115 --variable=T2,PREC_ACC_NC,Q2,ACSWDNB,ACLWDNB,U10,V10,PSFC --cache="$HOME/scratch/.temp_gwfdata2" --prefix="conus_i"
```

# Contributions
Zhenhua Li (zhenhua.li@usask.ca): processing scripts and datasets files of `WRF-CONUSI`.<br>
Quoqiang Tang (quoqiang.tang@usask.ca): download scripts and datasets files of `ERA5`.<br>
Julie Mai (julie.mai@uwaterloo.ca): providing RDRS dataset through CaSPAr data portal.<br>
# Authors
Kasra Keshavarz (kasra.keshavarz@usask.ca): main scripts structure and development.<br>
Shervan Gharari (shervan.gharari@usask.ca): supervision.<br>
# License
Global Water Futures (GWF) Meteorological Data Processing Workflow
Copyright (C) 2022, Global Water Futures (GWF), University of Saskatchewan

For more information see: https://gwf.usask.ca/

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Acknowledgements
