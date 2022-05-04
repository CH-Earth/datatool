# CCRN `CanRCM4-WFDEI-GEM-CaPA`
In this file, the details of the dataset is explained.

## Location of Dataset Files
The `CanRCM4-WFDEI-GEM-CaPA` dataset is located under the following directory accessible from Compute Canada (CC) Graham Cluster:
```
/project/rpp-kshook/Model_Output/280_CanRCM4_Cor_WFDEI-GEM-CaPA
```
and the structure of the dataset hourly files is as following:
```console
/project/rpp-kshook/Model_Output/280_CanRCM4_Cor_WFDEI-GEM-CaPA
├── r8i2p1r1
│   ├── hus_r8i2p1r1_z1_1951-2100.Feb29.nc4
│   ├── pr_r8i2p1r1_z1_1951-2100.Feb29.nc4
│   ├── ps_r8i2p1r1_z1_1951-2100.Feb29.nc4
│   ├── rlds_r8i2p1r1_z1_1951-2100.Feb29.nc4
│   ├── rsds_r8i2p1r1_z1_1951-2100.Feb29.nc4
│   ├── ta_r8i2p1r1_z1_1951-2100.Feb29.nc4
│   └── wind_r8i2p1r1_z1_1951-2100.Feb29.nc4
.
.
.
├── %ensembleMember 
│   ├── hus_%ensembleMember_z1_1951-2100.Feb29.nc4 
│   ├── pr_%ensembleMember_z1_1951-2100.Feb29.nc4  
│   ├── ps_%ensembleMember_z1_1951-2100.Feb29.nc4  
│   ├── rlds_%ensembleMember_z1_1951-2100.Feb29.nc4
│   ├── rsds_%ensembleMember_z1_1951-2100.Feb29.nc4
│   ├── ta_%ensembleMember_z1_1951-2100.Feb29.nc4  
│   └── wind_%ensembleMembe_z1_1951-2100.Feb29.nc4
.
.
.
└── r10i2p1r5
    ├── hus_%ensembleMember_z1_1951-2100.Feb29.nc4 
    ├── pr_%ensembleMember_z1_1951-2100.Feb29.nc4  
    ├── ps_%ensembleMember_z1_1951-2100.Feb29.nc4  
    ├── rlds_%ensembleMember_z1_1951-2100.Feb29.nc4
    ├── rsds_%ensembleMember_z1_1951-2100.Feb29.nc4
    ├── ta_%ensembleMember_z1_1951-2100.Feb29.nc4  
    └── wind_%ensembleMembe_z1_1951-2100.Feb29.nc4
```

Below is a list of ensemble members for this datase:
```
/project/rpp-kshook/Model_Output/280_CanRCM4_Cor_WFDEI-GEM-CaPA
├──  r10i2p1r1
├──  r10i2p1r2
├──  r10i2p1r3
├──  r10i2p1r4
├──  r10i2p1r5
├──  r8i2p1r1
├──  r8i2p1r2
├──  r8i2p1r3
├──  r8i2p1r4
├──  r8i2p1r5
├──  r9i2p1r1
├──  r9i2p1r2
├──  r9i2p1r3
├──  r9i2p1r4
└──  r9i2p1r5
```

## Coordinate Variables and Time-stamps

### Coordinate Variables
The coordinate variables of the `CanRCM4-WFDEI-GEM-CaPA` simulations are `lon` and `lat` representing the longitude and latitude points, respectively.
### Time-stamps
The time-stamps are included in the original files.

## Dataset Variables
Each NetCDF file belongs to a single variable. The list of variables included in the dataset is descriped in [Short Description on Dataset Variables](##short-description-on-dataset-variables)
## Spatial Extent
The spatial extent of the dataset is on latitutes from `31.0625` to `71.9375` and longitudes from `-149.9375` to `-50.0625` covering North America. The resolution is 0.09 degrees (~10km). 

## Temporal Extent
The time-steps are hourly covering from `January 1951` to `December 2100`.

## Short Description on Dataset Variables
In most hydrological modelling applications, usually 7 variables are needed detailed as following: 1) specific humidity at 1.5 (or 2) meters, 2) surface pressure, 3) air temperature at 1.5 (or 2) meters, 4) wind speed at 10 meters, 5) precipitation, 6) downward short wave radiation, and 7) downward long wave radiation. These variables are available through `RDRS` v2.1 dataset and their details are described in the table below:
|Variable Name         |Dataset Variable   |Unit |IPCC abbreviation|Comments              |
|----------------------|-------------------|-----|-----------------|----------------------|
|surface pressure      |ps                 |Pa   |ps               |                      |
|specific humidity@1.5m|hus                |1    |huss             |                      |
|air tempreature @1.5m |ta                 |K    |tas              |                      |
|wind speed @10m       |wind               |m/s  |wspd             |Wind Modulus at Lowest Model Level (sigma=0.995)|
|precipitation         |pr                 |mm/hr|                 |                      |
|short wave radiation  |rsds               |W m-2|rsds             |Surface Downwelling Shortwave Flux|
|long wave radiation   |lsds               |W m-2|rlds             |Surface Downwelling Longwave Flux|
