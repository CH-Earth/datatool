# ECCC `RDRS` v2.1
In this file, the details of the dataset is explained.

## Location of Dataset Files
The `RDRS` v2.1 dataset is located under the following directory accessible from Compute Canada (CC) Graham Cluster:
```
/project/rpp-kshook/Model_Output/RDRSv2.1
```
and the structure of the dataset hourly files is as following:
```console
/project/rpp-kshook/Model_Output/RDRSv2.1
├── 1980
│   ├── 1980010112.nc
│   ├── 1980010212.nc
│   ├── 1980010312.nc
│   ├── .
│   ├── .
│   ├── .
│   └── 1980123112.nc
.
.
.
├── %Y
│   ├── %Y010112.nc
│   ├── .
│   ├── .
│   ├── %Y%m%d12.nc
│   ├── .
│   ├── .
│   └── %Y123112.nc
.
.
.
└── 2018
    ├── 2018010112.nc
    ├── .
    ├── .
    ├── .
    └── 2018123112.nc
```

## Coordinate Variables and Time-stamps

### Coordinate Variables
The coordinate variables of the `ERA5` simulations are `lon` and `lat` representing the longitude and latitude points, respectively.
### Time-stamps
The time-stamps are included in the original files.

## Dataset Variables
The NetCDF files of the dataset contain 28 variables. You may see a list of variables by using the `ncdump -h`  command on one of the files:
```console
foo@bar:~$ module load cdo/2.0.4
foo@bar:~$ module load nco/5.0.6
foo@bar:~$ ncdump -h /project/rpp-kshook/Model_Output/RDRSv2.1/1980/1980010112.nc
```

## Spatial Extent
The spatial extent of the `RDRS` v2.1 is on latitutes from `+5.75` to `+64.75` and longitudes from `-179.9925` to `179.9728` covering North America. The resolution is 0.09 degrees (~10km). 

## Temporal Extent
The time-steps are hourly covering from January 1980 to December 2018.
