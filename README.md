# Introduction

This repository contains scripts to process necessary forcing data from various datasets. The general usage of the script (i.e., `bash/extract-dataset.sh`) is as follows:

```
   Usage:
       ./extract-dataset.sh [options...]

   Script options:
       -d, --dataset               Meteorological forcing dataset of interest
       				   currently available options are:
				   'CONUSI'; 'CONUSII';
       -i, --dataset-dir=DIR       The source path of the dataset file(s)
       -o, --output-dir=DIR        Writes processed files to DIR
       -s, --start-date=STRING     The start date of the forcing data
       -e, --end-date=STRING       The end date of the forcing data
       -t, --time-scale=CHAR       The time scale of interest, i.e., H (hourly), D (Daily), M (Monthly), Y (Yearly)
       -l, --lat-box=INT,INT       Latitude's upper and lower bounds
       -n, --lon-box=INT,INT       Longitude's upper and lower bounds
       -j, --submit-job            Submit the data extraction process as a job on the SLURM system
       -h, --help                  Print this message

```

# Example

As an example, follow the code block below. Please remember that you MUST have access to GRAHAM cluster with Compute Canada (CC) and have access to `CONUS I` model outputs. Remeber to generate a "Personal Access Token" with GitHub beforehands. Enter the codes on your Graham Bash shell:

```console
foo@bar:~$ git clone https://github.com/kasra-keshavarz/gwf-forcing-data 
foo@bar:~$ cd ./gwf-focring-data/bash/
foo@bar:~$ ./extract-dataset.sh -h # to view the usage message
foo@bar:~$ ./extract-dataset.sh  --dataset=CONUS1 --dataset-dir="/project/6008034/Model_Output/WRF/CONUS/CTRL/" --output-dir="$HOME/scratch/conus_test" --start-date="2000-11-1" --end-date="2000-11-3" --time-scale=M  --lat-box=49,51  --lon-box=-117,-116 # an example!

```

The code might be having some bugs for sure! Please report one if you see any.
