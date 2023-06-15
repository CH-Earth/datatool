# ECMWF `ERA5`
In this file, the details of the dataset is explained.

## Location of Dataset Files
The global `ERA5` dataset is located under the following directory accessible from Compute Canada (CC) Graham Cluster:
```
/project/rpp-kshook/CompHydCore/climateForcingData/ERA5/ERA5_for_SUMMA/2_merged_data
```
and the structure of the dataset hourly files is as following:
```console
/project/rpp-kshook/CompHydCore/climateForcingData/ERA5/ERA5_for_SUMMA/2_merged_data
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
foo@bar:~$ ncdump -h  /project/rpp-kshook/CompHydCore/climateForcingData/ERA5/ERA5_for_SUMMA/2_merged_data/ERA5_merged_195001.nc
```

## Spatial Extent
The spatial extent of the `ERA5` is on latitutes from `+90` to `-90` and longitudes from `-180` to `179.75`. The resolution is 0.25 degrees. 

## Temporal Extent
The time-steps are hourly covering from January 1950 to December 2020.

## Short Description on `ERA5` Variables
In most hydrological modelling applications, usually 7 variables are needed detailed as following:  1) specific humidity at 2 meters, 2) surface pressure, 3) air temperature at 2 meters, 4) wind speed at 10 meters, 5) precipitation, 6) downward short wave radiation, and 7) downward long wave radiation. These variables are available through the current `ERA5` dataset and their details are described in the table below:

|Variable Name        |ERA5 Variable      |Original Shortname|Parameter ID|Unit |IPCC abbreviation|Comments            |
|---------------------|-------------------|------------------|------------|-----|-----------------|--------------------|
|surface pressure     |airpres            |sp                |134         |Pa   |ps               |                    |
|specific humidity @2m|spechum            |q                 |133         |kg/kg|huss             |                    |
|air temperature      |airtemp            |t                 |130         |k    |tas              |                    |
|wind speed @10m      |windspd            |u,v               |131,132     |m/s  |wspd             |WIND=SQRT(u<sup>2</sup>+v<sup>2</sup>)|
|precipitation        |pptrate            |mtpr              |235055      |mm/hr|                 |mean total precipitation rate|
|short wave radiation |SWRadAtm           |msdwswrf          |235035      |W m-2|rsds             |                    |
|long wave radiation  |LWRadAtm           |msdwlwrd          |235036      |W m-2|rlds             |                    |

For a complete catalog of the dataset, see [here](https://confluence.ecmwf.int/display/CKB/ERA5%3A+data+documentation).

## Downloading Original ERA5 Data
The scripts to download the original ERA5 data are contained in the [`ERA5_downloads.zip`](./ERA5_downloads.zip) file located in the current directory of the repository. The scripts are written by [Quoqiang Tang](quoqiang.tang@usask.ca) and [Wouter Knoben](wouter.knoben@usask.ca) as part of the [Community Workflows to Advance Reproducibility in Hydrological Modelling (CWARHM)](https://github.com/CH-Earth/CWARHM). "ERA5 data preparation includes interactions between an atmospheric model and a land surface model. ... [Original] ERA5 data is available at 137 different pressure levels (i.e. some height above the surface), as well as at the surface. The lowest atmospheric level is L137, at geopotential and geometric altitude 10m and data here relies only on the atmospheric model. Any variables at a height lower than L137 (i.e., at the surface) are the result of interpolation between atmospheric model and land model. We want to use only the outcomes from the ECMWF atmospheric model [...]. Therefore, we obtain (1) air temperature, (2) wind speed and (3) specific humidity at the lowest pressure level (L137), (4) Precipitation, (5) downward shortwave radiation, (6) downward longwave radiation and (7) air pressure are unaffected by the land model coupling and can be downloaded at the surface level. This is beneficial because surface-level downloads are substantially faster than pressure-level downloads. [^1]"
[^1]: from: https://github.com/CH-Earth/CWARHM/tree/main/3a_forcing#forcing-needed-to-run-summa

