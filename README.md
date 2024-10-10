# Description
This repository contains scripts to process meteorological datasets in NetCDF file format. The general usage of the script (i.e., `./extract-dataset.sh`) is as follows:

```console
Usage:
  extract-dataset [options...]

Script options:
  -d, --dataset                     Meteorological forcing dataset of interest
  -i, --dataset-dir=DIR             The source path of the dataset file(s)
  -v, --variable=var1[,var2[...]]   Variables to process
  -o, --output-dir=DIR              Writes processed files to DIR
  -s, --start-date=DATE             The start date of the data
  -e, --end-date=DATE               The end date of the data
  -l, --lat-lims=REAL,REAL          Latitude's upper and lower bounds;
                                    optional; within the [-90, +90] limits
  -n, --lon-lims=REAL,REAL          Longitude's upper and lower bounds;
                                    optional; within the [-180, +180] limits
  -a, --shape-file=PATH             Path to the ESRI shapefile; optional
  -m, --ensemble=ens1,[ens2,[...]]  Ensemble members to process; optional
                                    Leave empty to extract all ensemble members
  -M, --model=model1,[model2,[...]] Models that are part of a dataset,
                                    only applicable to climate datasets, optional
  -S, --scenario=scn1,[scn2,[...]]  Climate scenarios to process, only applicable
                                    to climate datasets, optional
  -j, --submit-job                  Submit the data extraction process as a job
                                    on the SLURM system; optional
  -k, --no-chunk                    No parallelization, recommended for small domains
  -p, --prefix=STR                  Prefix  prepended to the output files
  -b, --parsable                    Parsable SLURM message mainly used
                                    for chained job submissions
  -c, --cache=DIR                   Path of the cache directory; optional
  -E, --email=user@example.com      E-mail user when job starts, ends, or               
                                    fails; optional
  -u, --account                     Digital Research Alliance of Canada's sponsor's
                                    account name; optional, defaults to 'rpp-kshook' 
  -L, --list-datasets               List all the available datasets and the
                                    corresponding keywords for '--dataset' option
  -V, --version                     Show version 
  -h, --help                        Show this screen and exit

```
# Available Datasets
|# |Dataset                    |Time Period                     |DOI                       |Description                          |
|--|---------------------------|--------------------------------|--------------------------|-------------------------------------|
|1 |GWF-NCAR WRF-CONUS I       |Hourly (Oct 2000 - Dec 2013)    |10.1007/s00382-016-3327-9 |[link](./scripts/gwf-ncar-conus_i)   |
|2 |GWF-NCAR WRF-CONUS II[^1]  |Hourly (Jan 1995 - Dec 2015)    |10.5065/49SN-8E08         |[link](./scripts/gwf-ncar-conus_ii)  |
|3 |ECMWF ERA5[^2]             |Hourly (Jan 1950 - Dec 2020)    |10.24381/cds.adbb2d47 and [link](https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels-preliminary-back-extension?tab=overview)|[link](./scripts/ecmwf-era5)|
|4 |ECCC RDRSv2.1              |Hourly (Jan 1980 - Dec 2018)    |10.5194/hess-25-4917-2021 |[link](./scripts/eccc-rdrs)          |
|5 |CCRN CanRCM4-WFDEI-GEM-CaPA|3-Hourly (Jan 1951 - Dec 2100)  |10.5194/essd-12-629-2020  |[link](./scripts/ccrn-canrcm4_wfdei_gem_capa)|
|6 |CCRN WFDEI-GEM-CaPA        |3-Hourly (Jan 1979 - Dec 2016)  |10.20383/101.0111         |[link](./scripts/ccrn-wfdei_gem_capa)|
|7 |ORNL Daymet                |Daily (Jan 1980 - Dec 2022)[^3] |10.3334/ORNLDAAC/2129     |[link](./scripts/ornl-daymet)        |
|8 |Alberta Gov Climate Dataset|Daily (Jan 1950 - Dec 2100)     |10.5194/hess-23-5151-201  |[link](./scripts/ab-gov)             |
|9 |Ouranos ESPO-G6-R2         |Daily (Jan 1950 - Dec 2100)     |10.1038/s41597-023-02855-z|[link](./scripts/ouranos-espo-g6-r2) |
|10|Ouranos MRCC5-CMIP6        |hourly (Jan 1950 - Dec 2100)    |TBD                       |[link](./scripts/ouranos-mrcc5-cmip6)|
|11|NASA NEX-GDDP-CMIP6        |Daily (Jan 1950 - Dec 2100)     |10.1038/s41597-022-01393-4|[link](./scripts/nasa-nex-gddp-cmip6)|

[^1]: For access to the files on Graham cluster, please contact [Stephen O'Hearn](mailto:sdo124@mail.usask.ca).
[^2]: ERA5 data from 1950-1979 are based on [ERA5 preliminary extenion](https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels-preliminary-back-extension?tab=overview) and 1979 onwards are based on [ERA5 1979-present](https://doi.org/10.24381/cds.adbb2d47).
[^3]: For the Peurto Rico domain of the dataset, data are available from January 1950 until December 2022.
[^4]: Data is not publicly available yet. DOI is to be determined once the relevant paper is published.

# General Example 
As an example, follow the code block below. Please remember that you MUST have access to Digital Research Alliance of Canada (DRA) clusters (specifically `Graham`) and have access to `RDRSv2.1` model outputs. Also, remember to generate a [Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with GitHub in advance. Enter the following codes in your Graham shell as a test case:

```console
foo@bar:~$ git clone https://github.com/kasra-keshavarz/datatool # clone the repository
foo@bar:~$ cd ./datatool/ # move to the repository's directory
foo@bar:~$ ./extract-dataset.sh -h # view the usage message
foo@bar:~$ ./extract-dataset.sh  \
  --dataset="rdrs" \
  --dataset-dir="/project/rpp-kshook/Climate_Forcing_Data/meteorological-data/rdrsv2.1" \
  --output-dir="$HOME/scratch/rdrs_outputs/" \
  --start-date="2001-01-01 00:00:00" \
  --end-date="2001-12-31 23:00:00" \
  --lat-lims=49,51  \
  --lon-lims=-117,-115 \
  --variable="RDRS_v2.1_A_PR0_SFC,RDRS_v2.1_P_HU_09944" \
  --cache='$SLURM_TMPDIR' \
  --prefix="testing_";
```
See the [examples](./examples) directory for real-world scripts for each meteorological dataset included in this repository.

# Logs
The datasets logs are generated under the `$HOME/.datatool` directory,
only in cases where jobs are submitted to clusters' schedulers. If
processing is not submitted as a job, then the logs are printed on screen.

# New Datasets
If you are considering any new dataset to be added to the data
repository, and subsequently the associated scripts added here,
you can open a new ticket on the **Issues** tab of the current
repository. Or, you can make a 
[Pull Request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request)
on this repository with your own script.

# Support
Please open a new ticket on the **Issues** tab of this repository for
support.

# License
Meteorological Data Processing Workflow - datatool <br>
Copyright (C) 2022-2023, University of Saskatchewan<br>
Copyright (C) 2023-2024, University of Calgary<br>

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

