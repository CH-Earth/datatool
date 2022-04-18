# ECMWF `ERA5`
In this file, the details of the dataset is explained.

## Location of Dataset Files
The global `ERA5` dataset is located under the following directory accessible from Compute Canada (CC) Graham Cluster:
```
/project/6008034/CompHydCore/climateForcingData/ERA5/ERA5_for_SUMMA/2_merged_data
```
and the structure of the dataset hourly files is as following:
```console
/project/6008034/CompHydCore/climateForcingData/ERA5/ERA5_for_SUMMA/2_merged_data
├── ERA5_merged_195001.nc
├── ERA5_merged_%y%m.nc
├── .
├── .
├── .
└── ERA5_merged_202012.nc
```

## Coordinate Variables and Time-stamps

### Coordinate Variables
The coordinate variables of the `ERA5` simulations are `longitude` and `latitude` representing the longitude and latitude points, respectively.
### Time-stamps
The time-stamps are included in the original files.

## Dataset Variables
The NetCDF files of the dataset contain 7 variables needed to force hydrological models. You may see a list of variables by using the `ncdump -h`  command on one of the files:
```console
foo@bar:~$ module load cdo/2.0.4
foo@bar:~$ module load nco/5.0.6
foo@bar:~$ ncdump -h  /project/6008034/CompHydCore/climateForcingData/ERA5/ERA5_for_SUMMA/2_merged_data/ERA5_merged_195001.nc
```

## Spatial Extent
The spatial extent of the `ERA5` is on latitutes from `+90` to `-90` and longitudes from `-180` to `179.75`. The resolution is 0.25 degrees. 

## Temporal Extent
The time-steps are hourly covering from January 1950 to December 2020.
