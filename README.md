# Description
This repository contains scripts to process meteorological datasets in NetCDF file format. The general usage of the script (i.e., `./extract-dataset.sh`) is as follows:

```console
Usage:
  extract-dataset [options...]
Script options:
  -d, --dataset                         Meteorological forcing dataset of interest
  -i, --dataset-dir=DIR                 The source path of the dataset file(s)
  -v, --variable=var1[,var2[...]]       Variables to process
  -o, --output-dir=DIR                  Writes processed files to DIR
  -s, --start-date=DATE                 The start date of the data
  -e, --end-date=DATE                   The end date of the data
  -l, --lat-lims=REAL,REAL              Latitude's upper and lower bounds
  -n, --lon-lims=REAL,REAL              Longitude's upper and lower bounds 
  -a, --shape-file=PATH                 Path to the ESRI shapefile; optional
  -m, --ensemble=ens1,[ens2[...]]       Ensemble members to process; optional
                                        Leave empty to extract all ensemble members
  -j, --submit-job                      Submit the data extraction process as a job
                                        on the SLURM system; optional
  -k, --no-chunk                        No parallelization, recommended for small domains
  -p, --prefix=STR                      Prefix  prepended to the output files
  -b, --parsable                        Parsable SLURM message mainly used
                                        for chained job submissions
  -c, --cache=DIR                       Path of the cache directory; optional
  -E, --email=user@example.com          E-mail user when job starts, ends, or               
                                        fails; optional
  -u, --account                         Digital Research Alliance of Canada's sponsor's
                                        account name; optional, defaults to \'rpp-kshook`'  
  -V, --version                         Show version 
  -h, --help                            Show this screen and exit

```
# Available Datasets
|# |Dataset                   |Time Scale                      |DOI                      |Description				|
|--|--------------------------|--------------------------------|-------------------------|--------------------------------------|
|1 |WRF-CONUS I (control)     |Hourly (Oct 2000 - Dec 2013)    |10.1007/s00382-016-3327-9|[link](./scripts/conus_i)		|
|2 |WRF-CONUS II (control)[^1]|Hourly (Jan 1995 - Dec 2015)    |10.5065/49SN-8E08        |[link](./scripts/conus_ii)		|
|3 |ERA5[^2]                  |Hourly (Jan 1950 - Dec 2020)    |10.24381/cds.adbb2d47 and [link](https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels-preliminary-back-extension?tab=overview)|[link](./scripts/era5)|
|4 |RDRS v2.1                 |Hourly (Jan 1980 - Dec 2018)    |10.5194/hess-25-4917-2021|[link](./scripts/rdrs)		|
|5 |CanRCM4-WFDEI-GEM-CaPA    |3-Hourly (Jan 1951 - Dec 2100)  |10.5194/essd-12-629-2020 |[link](./scripts/canrcm4_wfdei_gem_capa)|
|6 |WFDEI-GEM-CaPA	      |3-Hoursly (Jan 1979 - Dec 2016) |10.20383/101.0111	 |[link](./scripts/wfdei_gem_capa)	|
|7 |Daymet		      |Daily (Jan 1980 - Dec 2022)[^3] |10.3334/ORNLDAAC/2129	 |[link](./scripts/daymet)       	|
|8 |BCC-CSM2-MR		      |Daily (Jan 1950 - Dec 2100)[^4] |*TBD*			 |[link](./scripts/bcc-csm2-mr)  	|
|9 |CNRM-CM6-1		      |Daily (Jan 1950 - Dec 2100)[^4] |*TBD*			 |[link](./scripts/cnrm-cm6-1)   	|
|10|EC-Earth3-Veg	      |Daily (Jan 1950 - Dec 2100)[^4] |*TBD*			 |[link](./scripts/ec-earth3-veg)	|
|11|GDFL-CM4		      |Daily (Jan 1950 - Dec 2100)[^4] |*TBD*			 |[link](./scripts/gdfl-cm4)     	|
|12|GDFL-ESM4		      |Daily (Jan 1950 - Dec 2100)[^4] |*TBD*			 |[link](./scripts/gdfl-esm4)    	|
|13|IPSL-CM6A-LR	      |Daily (Jan 1950 - Dec 2100)[^4] |*TBD*			 |[link](./scripts/ipsl-cm6a-lr) 	|
|14|MRI-ESM2-0		      |Daily (Jan 1950 - Dec 2100)[^4] |*TBD*			 |[link](./scripts/mri-esm2-0)   	|
|15|Hybrid Observation(AB Gov)|Daily (Jan 1950 - Dec 2019)[^4] |10.5194/hess-23-5151-2019|[link](./scripts/hybrid_obs)		|

[^1]: For access to the files on Graham cluster, please contact [Stephen O'Hearn](mailto:sdo124@mail.usask.ca).
[^2]: ERA5 data from 1950-1979 are based on [ERA5 preliminary extenion](https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels-preliminary-back-extension?tab=overview) and 1979 onwards are based on [ERA5 1979-present](https://doi.org/10.24381/cds.adbb2d47).
[^3]: For the Peurto Rico domain of the dataset, data are available from January 1950 until December 2022.
[^4]: Data is not publicly available yet. DOI is to be determined once the relevant paper is published.

# General Example 
As an example, follow the code block below. Please remember that you MUST have access to Graham cluster with Digital Research Alliance of Canada (DRA) and have access to `CONUS I` model outputs. Also, remember to generate a [Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with GitHub in advance. Enter the following codes in your Graham shell as a test case:

```console
foo@bar:~$ git clone https://github.com/kasra-keshavarz/datatool # clone the repository
foo@bar:~$ cd ./datatool/ # move to the repository's directory
foo@bar:~$ ./extract-dataset.sh -h # view the usage message
foo@bar:~$ ./extract-dataset.sh  --dataset=CONUS1 \
                                 --dataset-dir="/project/rpp-kshook/Model_Output/WRF/CONUS/CTRL" \
                                 --output-dir="$HOME/scratch/conus_i_output/" \
                                 --start-date="2001-01-01 00:00:00" \
                                 --end-date="2001-12-31 23:00:00" \
                                 --lat-lims=49,51  \
                                 --lon-lims=-117,-115 \
                                 --variable=T2,PREC_ACC_NC,Q2,ACSWDNB,ACLWDNB,U10,V10,PSFC \
                                 --prefix="conus_i";
```
See the [examples](./examples) directory for real-world scripts for each meteorological dataset included in this repository.


# New Datasets
If you are considering any new dataset to be added to the data repository, and subsequently the associated scripts added here, you can open a new ticket on the **Issues** tab of the current repository. Or, you can make a [Pull Request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) on this repository with your own script.

# Support
Please open a new ticket on the **Issues** tab of the current repository in case of any issues.

# License
Meteorological Data Processing Workflow - datatool <br>
Copyright (C) 2022-2023, University of Saskatchewan<br>
Copyright (C) 2023, University of Calgary<br>

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

