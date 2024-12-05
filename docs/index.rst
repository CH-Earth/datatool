.. datatool documentation master file, created by Kasra Keshavarz

Welcome to ``datatool``'s documentation!
========================================
``datatool`` is an HPC-indepenent workflow enabling end-users extracting
subsets from community meteorological datasets through a simple
command-line interface (CLI). The tool works at large with NetCDF files,
but is not limited to any file format, structure, or dataset.

Through crowsourcing, ``datatool`` aims to enable end-users extract subsets
from any dataset available to the community members.


User Interface
==============
This repository contains scripts to process meteorological datasets in NetCDF 
file format. The general usage of the script (i.e., ``./extract-dataset.sh``)
is as follows:

.. code-block:: console

   Usage:
     extract-dataset [options...]

   Script options:
     -d, --dataset                     Meteorological forcing dataset of interest
     -i, --dataset-dir=DIR             The source path of the dataset file(s)
     -v, --variable=var1[,var2[...]]   Variables to process
     -o, --output-dir=DIR              Writes processed files to DIR
     -s, --start-date=DATE             The start date of the data
     -e, --end-date=DATE               The end date of the data
     -l, --lat-lims=REAL,REAL          Latitude's upper and lower bounds
                                       optional; within the [-90, +90] limits
     -n, --lon-lims=REAL,REAL          Longitude's upper and lower bounds
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
     -p, --prefix=STR                  Prefix prepended to the output files
     -b, --parsable                    Parsable SLURM message mainly used
                                       for chained job submissions
     -c, --cache=DIR                   Path of the cache directory; optional
     -E, --email=user@example.com      E-mail user when job starts, ends, or
                                       fails; optional
     -C, --cluster=JSON                JSON file detailing cluster-specific details
     -L, --list-datasets               List all the available datasets and the
                                       corresponding keywords for '--dataset' option
     -V, --version                     Show version
     -h, --help                        Show this screen and exit


Use the navigation menu on the left to explore the documentations!

