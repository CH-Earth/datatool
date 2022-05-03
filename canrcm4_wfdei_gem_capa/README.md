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
The time-steps are hourly covering from `January 1980` to `December 2018`.

## Short Description on `RDRS` v2.1 Variables
In most hydrological modelling applications, usually 7 variables are needed detailed as following: 1) specific humidity at 1.5 (or 2) meters, 2) surface pressure, 3) air temperature at 1.5 (or 2) meters, 4) wind speed at 10 meters, 5) precipitation, 6) downward short wave radiation, and 7) downward long wave radiation. These variables are available through `RDRS` v2.1 dataset and their details are described in the table below:
|Variable Name         |RDRSv2.1 Variable  |Unit |IPCC abbreviation|Comments              |
|----------------------|-------------------|-----|-----------------|----------------------|
|surface pressure      |RDRS_v2.1_P_P0_SFC |mb   |ps               |                      |
|specific humidity@1.5m|RDRS_v2.1_P_HU_1.5m|1    |huss             |                      |
|air tempreature @1.5m |RDRS_v2.1_P_TT_1.5m|C    |tas              |                      |
|wind speed @10m       |RDRS_v2.1_P_UVC_10m|m/s  |wspd             |WIND=SQRT(U102+V102)  |
|precipitation         |RDRS_v2.1_A_PR0_SFC|mm/hr|                 |CaPA outputs          |
|short wave radiation  |RDRS_v2.1_P_FB_SFC |W m-2|rsds             |Downward solar flux   |
|long wave radiation   |RDRS_v2.1_P_FI_SFC |W m-2|rlds             |Downward infrared flux|
