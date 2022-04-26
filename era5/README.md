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

## Short Description on `ERA5` Variables
In most hydrological modelling applications, usually 7 variables are needed detailed as following:  1) specific humidity at 2 meters, 2) surface pressure, 3) air temperature at 2 meters, 4) wind speed at 10 meters, 5) precipitation, 6) downward short wave radiation, and 7) downward long wave radiation. These variables are available through the current `ERA5` dataset and their details are described in the table below:

|Variable Name        |ERA5 Variable      |Unit |IPCC abbreviation|Comments            |
|---------------------|-------------------|-----|-----------------|--------------------|
|surface pressure     |airpres            |Pa   |ps               |                    |
|specific humidity @2m|spechum            |1    |huss             |                    |
|air tempreature @2m  |airtemp            |k    |tas              |                    |
|wind speed @10m      |windspd            |m/s  |wspd             |WIND=SQRT(U+V)      |
|precipitation        |pptrate            |mm/hr|                 |accumulated precipitation over one hour|
|short wave radiation |SWRadAtm           |W m-2|rsds             |                    |
|long wave radiation  |LWRadAtm           |W m-2|rlds             |                    |
