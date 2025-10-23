# ECCC `CaSR-Rivers` v2.1
In this file, the details of the dataset is explained.

## Location of Dataset Files
The `CaSR-Rivers` v2.1 dataset is located under the following directory accessible from GC Science
```console
 /home/shyd500/data/ppp6/casr_rivers_v2p1_postproc/full_domain
```
and the structure of the single-day hourly timestep data files is as follows:
```console
 /home/shyd500/data/ppp6/casr_rivers_v2p1_postproc/full_domain

├── 198001
│   ├── 19800101_MSC_CaSR-Rivers-Analysis_RiverDischarge_Sfc_LatLon0.00833_PT0H.nc
│   ├── 19800102_MSC_CaSR-Rivers-Analysis_RiverDischarge_Sfc_LatLon0.00833_PT0H.nc
│   ├── 19800103_MSC_CaSR-Rivers-Analysis_RiverDischarge_Sfc_LatLon0.00833_PT0H.nc
│   ├── .
│   ├── .
│   ├── .
│   └── 19800131_MSC_CaSR-Rivers-Analysis_RiverDischarge_Sfc_LatLon0.00833_PT0H.nc
.
.
.
├── %Y%m
│   ├── %Y0101_MSC_CaSR-Rivers-Analysis_RiverDischarge_Sfc_LatLon0.00833_PT0H.nc
│   ├── .
│   ├── .
│   ├── %Y%m%d_MSC_CaSR-Rivers-Analysis_RiverDischarge_Sfc_LatLon0.00833_PT0H.nc
│   ├── .
│   ├── .
│   └── %Y1231_MSC_CaSR-Rivers-Analysis_RiverDischarge_Sfc_LatLon0.00833_PT0H.nc
.
.
.
└── 201712
    ├── 20171201_MSC_CaSR-Rivers-Analysis_RiverDischarge_Sfc_LatLon0.00833_PT0H.nc
    ├── .
    ├── .
    ├── .
    └── 20171231_MSC_CaSR-Rivers-Analysis_RiverDischarge_Sfc_LatLon0.00833_PT0H.nc
```

## Coordinate Variables and Time-stamps

### Coordinate Variables
The coordinate variables of the `CaSR-Rivers` simulations are `lon` and `lat` representing the longitude and latitude points, respectively.
### Time-stamps
The time-stamps are included in the original files.

## Dataset Variables
The NetCDF files of the dataset contain only 1 variables (`disc`). You may see a list of variables by using the `ncdump -h`  command on one of the files:
```console
foo@bar:~$ ncdump -h /home/shyd500/data/ppp6/casr_rivers_v2p1_postproc/full_domain/201712/20171231_MSC_CaSR-Rivers-Analysis_RiverDischarge_Sfc_LatLon0.00833_PT0H.nc
```

## Spatial Extent
The spatial extent of the `CaSR-Rivers` v2.1 is ~1km

## Temporal Extent
The time-steps are hourly covering from `January 1980` to `December 2017`.

## Short Description on `CaSR-Rivers` v2.1 Variables
In most hydrological modelling applications, usually 7 variables are needed detailed as following: 1) specific humidity (@1.5-2.0m or @40m), 2) surface pressure, 3) air temperature (@1.5m-2.0m or 40m), 4) wind speed (@10m or @40m), 5) precipitation (surface level), 6) downward short wave radiation (surface level), and 7) downward long wave radiation (surface level). These variables are available through `RDRS` v2.1 dataset and their details are described in the table below:
|Variable Name         |CaSR-Rivers Varname  |Unit   |Long Name                                                                                   |
|----------------------|---------------------|-------|--------------------------------------------------------------------------------------------|
|Streamflow Discharge  |disc                 |$m^3/s$|Mean discharge value exiting the river channel over the hour ending at the indicated time   |


Please visit the [official website](https://goc-dx.science.gc.ca/~arg000/casr-webpages/casr_subpage_index.html) for the dataset for the most up-to-date information.
