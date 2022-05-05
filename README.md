# Description
This repository contains scripts to process necessary forcing data from various datasets. The general usage of the script (i.e., `./extract-dataset.sh`) is as follows:

```console
Usage:
  ./extract-dataset.sh [options...]

Script options:
  -d, --dataset				Meteorological forcing dataset of interest
                                        currently available options are:
                                        'CONUSI';'ERA5';'CONUSII';'RDRS';
                                        'canrcm4-wfdei-gem-capa';
  -i, --dataset-dir=DIR			The source path of the dataset file(s)
  -v, --variable=var1[,var2[...]]	Variables to process
  -o, --output-dir=DIR			Writes processed files to DIR
  -s, --start-date=DATE			The start date of the forcing data
  -e, --end-date=DATE			The end date of the forcing data
  -l, --lat-lims=REAL,REAL		Latitude's upper and lower bounds
  -n, --lon-lims=REAL,REAL		Longitude's upper and lower bounds
  -m, --ensemble=STR                    The comma separated ensemble members values
                                        Leave empty to extract all ensemble members;
                                        [optional]
  -j, --submit-job			Submit the data extraction process as a job;
					on the SLURM system; [optional]
  -p, --prefix=STR			Prefix  prepended to the output files
  -c, --cache=DIR			Path of the cache directory; [optional]
  -V, --version				Show version
  -h, --help				Show this screen and exitcript options:
```
# Available Datasets
|#|Dataset                   |Time Scale                      |DOI                      |Description          |
|-|--------------------------|--------------------------------|-------------------------|---------------------|
|1|WRF-CONUS I (control)     |Hourly (Oct 2000 - Dec 2013)    |10.1007/s00382-016-3327-9|[link](conus_i)      |
|2|WRF-CONUS II (control)[^1]|Hourly (Jan 1995 - Dec 2015)    |10.5065/49SN-8E08        |[link](conus_ii)     |
|3|ERA5[^2]                  |Hourly (Jan 1950 - Dec 2020)    |10.24381/cds.adbb2d47 and [link](https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels-preliminary-back-extension?tab=overview)|[link](era5)|
|4|RDRS v2.1                 |Hourly (Jan 1980 - Dec 2018)    |10.5194/hess-25-4917-2021|[link](rdrs)         |
|5|CanRCM4-WFDEI-GEM-CaPA    |3-Hourly (Jan 1951 - Dec 2100)  |10.5194/essd-12-629-2020 |[link](canrcm4_wfdei_gem_capa)|


[^1]: For access to the files on Graham, please contact [Stephen O'Hearn](mailto:sdo124@mail.usask.ca).
[^2]: ERA5 data from 1950-1979 are based on [ERA5 preliminary extenion](https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels-preliminary-back-extension?tab=overview) and 1979 onwards are based on [ERA5 1979-present](https://doi.org/10.24381/cds.adbb2d47). 

# General Example 
As an example, follow the code block below. Please remember that you MUST have access to Graham cluster with Compute Canada (CC) and have access to `CONUS I` model outputs. Also, remember to generate a [Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with GitHub in advance. Enter the following codes in your Graham shell as a test case:

```console
foo@bar:~$ git clone https://github.com/kasra-keshavarz/gwfdatatool # clone the repository
foo@bar:~$ cd ./gwf-focring-data/bash/ # always move to the repository's directory
foo@bar:~$ ./extract-dataset.sh -h # to view the usage message
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

:warning: For time scales longer than a year, it is recommened to submit separate annual jobs. For example:

```console
foo@bar:~$ for year in {2001..2012}; \
            do ./extract-dataset.sh  --dataset=CONUS1 \
                                     --dataset-dir="/project/rpp-kshook/Model_Output/WRF/CONUS/CTRL" \
                                     --output-dir="$HOME/scratch/conus_i_output/" \
                                     --start-date="$year" \
                                     --end-date="$(($year+1))" \
                                     --lat-lims=49,51  \
                                     --lon-lims=-117,-115 \
                                     --variable=T2,PREC_ACC_NC,Q2,ACSWDNB,ACLWDNB,U10,V10,PSFC \
                                     --prefix="conus_i" \
                                     -j; done;
```
The details of each job is printed under the `$HOME` directory of your CC Graham account.

# New Datasets
If you are considering any new dataset to be added to the GWF repository, and subsequently the associated scripts added here, you can contact [Kasra Keshavarz](mailto:kasra.keshavarz@usask.ca). Or, you can make a [Pull Request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) on this repository with your own script.

# License
Global Water Futures (GWF) Meteorological Data Processing Workflow<br>
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

