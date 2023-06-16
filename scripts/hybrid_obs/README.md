# Alberta Government `Hybrid Observation` Dataset 
In this file, the details of the dataset is explained.

## Location of Dataset Files
The downscaled `Hybrid observation` dataset is located under the following directory accessible from Digital Research Alliance of Canada (DRA) Graham Cluster:
```
/project/rpp-kshook/Climate_Forcing_Data/meteorological-data/hybrid_obs
```
and the structure of the dataset hourly files is as following:
```console
/project/rpp-kshook/CompHydCore/climateForcingData/ERA5/ERA5_for_SUMMA/2_merged_data
├── Hybrid_Daily_BCABSK_US_pr_1950.nc
├── .
├── .
├── .
├── Hybrid_Daily_BCABSK_US_pr_2019.nc
├── Hybrid_Daily_BCABSK_US_tmax_1950.nc
├── .
├── .
├── .
├── Hybrid_Daily_BCABSK_US_%var_%yr.nc
├── .
├── .
├── .
├── Hybrid_Daily_BCABSK_US_tmax_2019.nc
├── Hybrid_Daily_BCABSK_US_tmin_1950.nc
├── .
├── .
├── .
└── Hybrid_Daily_BCABSK_US_tmin_2019.nc
```

## Coordinate Variables and Time-stamps

### Coordinate Variables
The coordinate variables of the `Hybrid Observation` datasets are `lon` and `lat` representing the longitude and latitude points, respectively.
### Time-stamps
The time-stamps are included in the original files. The data is avilable on a daily time-scale.

## Dataset Variables
The NetCDF files of the dataset contain 1 variable. You may see a list of variables by browsing the files.

## Spatial Extent
The spatial extent of the `Hybrid Observation` is on latitutes from `+45.95` to `60.25` and longitudes from `-128.05` to `-106.05`. The resolution is 0.1 degrees. 

## Temporal Extent
The time-steps are daily covering from January 1950 to December 2019.

## Short Description on `ERA5` Variables
|Variable Name        |ERA5 Variable      |Unit   |Comments            |
|---------------------|-------------------|-------|--------------------|
|precipitation        |pr                 |mm/day |                    |
|maximum temperature  |tmax               |degC   |                    |
|minimum temperature  |tmin               |degC   |                    |

For a complete description of the dataset, see [here](https://doi.org/10.5194/hess-23-5151-2019).

## Downloading Original `Hybrid Observation` Data
The data can be requested to download from 'hyung.eum AT gov.ab.ca'.
