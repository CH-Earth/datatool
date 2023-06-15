# CCRN `WFDEI-GEM-CaPA`
In this file, the details of the dataset is explained.

## Location of Dataset Files
The `WFDEI-GEM-CaPA` dataset is located under the following directory accessible from Digital Alliance of Canada (formerly Compute Canada) Graham cluster:

```
/project/rpp-kshook/Model_Output/181_WFDEI-GEM-CaPA_1979-2016
```
and the structure of the dataset hourly files is as following:

```console
/project/rpp-kshook/Model_Output/181_WFDEI-GEM-CaPA_1979-2016
├── hus_WFDEI_GEM_1979_2016.Feb29.nc
├── pr_WFDEI_GEM_1979_2016.Feb29.nc
├── ps_WFDEI_GEM_1979_2016.Feb29.nc
├── rlds_WFDEI_GEM_1979_2016.Feb29.nc
├── rsds_WFDEI_GEM_1979_2016.Feb29.nc
├── ta_WFDEI_GEM_1979_2016.Feb29.nc
└── wind_WFDEI_GEM_1979_2016.Feb29.nc
```

## Coordinate Variables and Time-stamps

### Coordinate Variables
The coordinate variables of the `WFDEI-GEM-CaPA` simulations are `lon` and `lat` representing the longitude and latitude points, respectively.

### Time-stamps
The time-stamps are included in the original files.

## Dataset Variables
The list of variables included in the dataset is descriped in [Short Description on Dataset Variables](##short-description-on-dataset-variables)

## Spatial Extent
The spatial extent of the dataset is on latitutes from `31.0625` to `71.9375` and longitudes from `-149.9375` to `-50.0625` covering North America. The resolution is 0.125 degrees. 

## Temporal Extent
The time-steps are 3-hourly covering from `January 1951` to `December 2100`.

## Short Description on Dataset Variables
In most hydrological modelling applications, usually 7 variables are needed detailed as following: 1) specific humidity at 40 meters, 2) surface pressure, 3) air temperature at 40 meters, 4) wind speed at 40 meters, 5) precipitation, 6) downward short wave radiation, and 7) downward long wave radiation. These variables are available through `WFDEI-GEM-CaPA` dataset and their details are described in the table below:
|Variable Name         |Dataset Variable   |Unit |IPCC abbreviation|Comments              |
|----------------------|-------------------|-----|-----------------|----------------------|
|surface pressure      |ps                 |Pa   |ps               |surface pressure at time stamp|
|specific humidity@40m |hus                |kg/kg|huss             |specific humidity elevated to 40m at time stamp|
|air tempreature @40m  |ta                 |K    |tas              |air temperature elevated to 40m at time stamp|
|wind speed @40m       |wind               |m/s  |wspd             |wind speed elevated to 40m at time stamp|
|precipitation         |pr                 |kg m-2 s-1|            |Mean rainfall rate over the previous 3 hours|
|short wave radiation  |rsds               |W m-2|rsds             |Mean surface incident shortwave radiation over the previous 3 hours|
|long wave radiation   |lsds               |W m-2|rlds             |Mean surface incident shortwave radiation over the previous 3 hour|

