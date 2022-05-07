# Extraction of ERA5 variables

## log in node

For quick subsetting of a domain and perhaps few days, a user can use the log in node example as follow:

```
./extract-dataset.sh  --dataset=ERA5 \
  --dataset-dir="/project/rpp-kshook/CompHydCore/climateForcingData/ERA5/ERA5_for_SUMMA/2_merged_data" \
  --output-dir="$HOME/scratch/era5_output/" \
  --start-date="1980-01-01" \
  --end-date="1980-02-29" \
  --lat-lims=49,54 \
  --lon-lims=-120,-98 \
  --variable="airpres,pptrate,spechum,windspd,airtemp,SWRadAtm,LWRadAtm" \
  --prefix="era5_"
```

## job submission

For longer and larger domain we recommned the user to submit the subsetting via jobs by speficiying the `-j` argument; For example and for domain of Mckenzie River Basin between 1980 to 2020 a user can adjust the parameters here and copy past this example in the command line.


```
./extract-dataset.sh  --dataset=ERA5 \
  --dataset-dir="/project/rpp-kshook/CompHydCore/climateForcingData/ERA5/ERA5_for_SUMMA/2_merged_data" \
  --output-dir="$HOME/scratch/era5_output/" \
  --start-date="1980-01-01" \
  --end-date="2019-12-31" \
  --lat-lims=49,54 \
  --lon-lims=-120,-98 \
  --variable="airpres,pptrate,spechum,windspd,airtemp,SWRadAtm,LWRadAtm" \
  --prefix="era5_" \
  -j;
```

Alternatively to speed up the process we can submit each year with a separate job as follow:

```
for year in {1980..2019}; do
  ./extract-dataset.sh  --dataset=ERA5 \
    --dataset-dir="/project/rpp-kshook/CompHydCore/climateForcingData/ERA5/ERA5_for_SUMMA/2_merged_data" \
    --output-dir="$HOME/scratch/era5_output/" \
    --start-date="${year}-01-01" \
    --end-date="${year}-12-31" \
    --lat-lims=49,54 \
    --lon-lims=-120,-98 \
    --variable="airpres,pptrate,spechum,windspd,airtemp,SWRadAtm,LWRadAtm" \
    --prefix="era5_" \
    -j;
done
```

**⚠ WARNING**: It is the user duty to make sure that all the job are sucessfully finished and the files are created.

A user can check the status of completed or failed job. For example it can be checked if the job IDs related to subsetting are completed. For example we can search for FAILED jobs from yesterday to now while checking job id or job name:
```
sacct --starttime $(date --date="1 days ago" '+%Y-%m-%d') --format=User,JobID,Jobname%50,partition,state,time,start,end,elapsed,MaxRss,MaxVMSize,nnodes,ncpus,nodelist%50 | grep FAILED > jobs.txt
```
date --date="1 days ago"

