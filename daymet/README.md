# `Daymet` dataset 
In this file, the details of the dataset is explained.

:warning: the dataset files are divided between three different spatial domains: 1) North America (`na`), 2) Peurto Rico (`pr`), and 3) Hawaii (`hi`). For the moment, only the `na` domain is considered in `datatool`. 

## Location of Dataset Files
The global `Daymet` dataset is located under the following directory accessible from Digital Research Alliance of Canada (DRA) Graham cluster:
```
/project/rpp-kshook/Model_Output/Daymet_Daily_V4R1/data/
```
and the structure of the dataset hourly files is as following:
```console
/project/rpp-kshook/Model_Output/Daymet_Daily_V4R1/data/
├── daymet_v4_daily_hi_dayl_1980.nc
├── daymet_v4_daily_hi_dayl_1981.nc
├── .
├── .
├── .
├── daymet_v4_daily_hi_dayl_2022.nc
├── .
├── .
├── .
├── daymet_v4_daily_hi_vp_1980.nc
├── .
├── .
├── .
├── daymet_v4_daily_hi_vp_2022.nc
├── .
├── .
├── .
├── daymet_v4_daily_{%domain}_{%variable}_{%year}.nc
├── .
├── .
├── .
├── daymet_v4_daily_na_dayl_1980.nc
├── .
├── .
├── .
├── daymet_v4_daily_na_vp_2022.nc
├── daymet_v4_daily_pr_dayl_1950.nc
├── .
├── .
├── .
└── daymet_v4_daily_pr_vp_2022.n
```

## Coordinate Variables and Time-stamps

### Coordinate Variables
The coordinate variables of the `Daymet` simulations are `lon` and `lat` representing the longitude and latitude points, respectively. The coordinate system is 2-dimensional and follows a Lambert Conformal Conic coordinate system.
### Time-stamps
The time-stamps are included in the original files.

## Dataset Variables
The NetCDF files of the dataset contain 7 variables. You may see a list of variables by browsing the dataset directory and listing the files.

## Spatial Extent
The spatial resolutaion of `Daymet` gridded data is 1 $km$. The model files are divided between three different domains: 1) North American (na), 2) Peurto Rico (pr), and 3) Hawaii (hi). Each domains spatial extents are printed in the following table:
|Number		|Domain		|Latitude extents		|Longitude extents		|
|:-------------:|:-------------:|:-----------------------------:|:-----------------------------:|
|1		|`na`		| `+6.08`° to `+83.79`°		| `-180`° to `+180`°		|
|2		|`pr`		| `+16.85`° to `+19.93`°	| `-67.97`° to `-64.13`°	|
|3		|`hi`		| `+17.96`° to `+23.51`°	| `-160.30`° to `-154.78`°	|

:warning: As mentioned previously, only the `na` domain is considered in the subsetting process of `datatool`.

## Temporal Extent
The time-steps are daily and the temporal extent for each domain is listed in the following table:
|Number		|Domain		|Time-step interval	|Start date	|End date	|
|:-------------:|:-------------:|:---------------------:|:-------------:|:-------------:|
|1		|`na`		|daily			|1980-01-01	|2022-12-31	|
|2		|`pr`		|daily			|1950-01-01	|2022-12-31	|
|3		|`hi`		|daily			|1980-01-01	|2022-12-31	|

Also, "[t]he Daymet calendar is based on a standard calendar year. All Daymet years have 1 - 365 days, including leap years. For leap years, the Daymet database includes leap day. Values for December 31 are discarded from leap years to maintain a 365-day year."

:warning: As mentioned previously, only the `na` domain is considered in the subsetting process of `datatool`.

## Short Description on `Daymet` Variables
The variables currently available through the `Daymet` dataset and their details are described in the table below, taken from the [source](https://daymet.ornl.gov/overview):

|Variable Name		|`daymet` Variable	|Unit	|Comments								|
|-----------------------|-----------------------|-------|-----------------------------------------------------------------------|
|day length		|dayl			|s/day	|Duration of the daylight period in seconds per day. This calculation is based on the period of the day during which the sun is above a hypothetical flat horizon|
|precipitation		|prcp			|mm/day	|Daily total precipitation in millimeters per day, sum of all forms converted to water-equivalent. Precipitation occurrence on any given day may be ascertained.|
|shortwave rdiation	|srad			|W/m2	|Incident shortwave radiation flux density in watts per square meter, taken as an average over the daylight period of the day. NOTE: Daily total radiation (MJ/m2/day) can be calculated as follows: ((srad (W/m2) * dayl (s/day)) / l,000,000)|
|snow water equivalent	|swe			|kg/m2	|Snow water equivalent in kilograms per square meter. The amount of water contained within the snowpack.|
|maximum air temperature|tmax			|deg C	|Daily maximum 2-meter air temperature in degrees Celsius.|
|minimum air temperature|tmin			|deg C	|Daily minimum 2-meter air temperature in degrees Celsius.|
|water vapor pressure	|vp			|Pa	|Water vapor pressure in pascals. Daily average partial pressure of water vapor.|

For a complete catalog of the dataset, see [here](https://daymet.ornl.gov/overview).

