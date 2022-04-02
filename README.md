# Description
This repository contains scripts to process necessary forcing data from various datasets. The general usage of the script (i.e., `bash/extract-dataset.sh`) is as follows:

```console
Usage:
   extract-dataset [options...]

Script options:
  -d, --dataset				Meteorological forcing dataset of interest
					currently available options are:
					'CONUSI';'ERA5';
  -i, --dataset-dir=DIR			The source path of the dataset file(s)
  -v, --variable=var1[,var2[...]]	Variables to process
  -o, --output-dir=DIR			Writes processed files to DIR
  -s, --start-date=DATE			The start date of the forcing data
  -e, --end-date=DATE			The end date of the forcing data
  -t, --time-scale=CHAR			The time scale of interest:
					'H' (hourly), 'D' (Daily), 'M' (Monthly), 
					or 'Y' (Yearly) [default: 'M']
  -l, --lat-lims=REAL,REAL		Latitude's upper and lower bounds
  -n, --lon-lims=REAL,REAL		Longitude's upper and lower bounds
  -j, --submit-job			Submit the data extraction process as a job
					on the SLURM system
  -p, --prefix=STR			Prefix  prepended to the output files
  -c, --cache=DIR			Path of the cache directory
  -V, --version				Show version
  -h, --help				Show this screen

```

# Prerequisites

# Installation 

# Usage
 
As an example, follow the code block below. Please remember that you MUST have access to GRAHAM cluster with Compute Canada (CC) and have access to `CONUS I` model outputs. Also, remember to generate a [Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with GitHub in advance. Enter the following codes in your GRAHAM Bash terminal:

```console
foo@bar:~$ git clone https://github.com/kasra-keshavarz/gwf-forcing-data 
foo@bar:~$ cd ./gwf-focring-data/bash/
foo@bar:~$ ./extract-dataset.sh -h # to view the usage message
foo@bar:~$ ./extract-dataset.sh  --dataset=CONUS1 --dataset-dir="$HOME/projects/rpp-kshook/Model_Output/WRF/CONUS/CTRL" --output-dir="$HOME/scratch/conus_test" --start-date="2001-12-25 22:00:00" --end-date="2002-01-3 05:00:00" --time-scale=h  --lat-lims=49,51  --lon-lims=-117,-115 --variable=T2,Q2,PSFC,U,V,GLW
```

# Contributing

# Authors

# License

# Acknowledgements
