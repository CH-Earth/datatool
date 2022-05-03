# NCAR-GWF `WRF-CONUSI` Simulation Outputs

In this file, the details of the dataset is explained.

## Location of Dataset Files
The `WRF-CONUSI` simulation outputs are located under the following directory accessible from Compute Canada (CC) Graham Cluster:
```
/project/6008034/Model_Output/WRF/CONUS/CTRL/
```
and the structure of the dataset hourly files is as following:
```console
/project/6008034/Model_Output/WRF/CONUS/CTRL/
├── 2000
│   ├── wrf2d_d01_2000-10-01_00:00:00
│   ├── wrf2d_d01_2000-10-01_01:00:00
│   ├── .
│   ├── .
│   ├── .
│   └── wrf2d_d01-2000-12-31_23:00:00
.
.
.
├── %Y 
│   ├── wrf2d_d01_%Y-%m-%d_%H:00:00
│   ├── .
│   ├── .
│   ├── .
│   .
│   .
│   .
.
.
.
└── 2013
    ├── .
    ├── .
    ├── .
    └── wrf2d_d01-2013-12-31_23:00:00

```

## Coordinate Variables and Time-stamps

### Coordinate Variables
The coordinate variables of the `WRF-CONUSI` simulations are located outside of the main dataset files. The NetCDF file containing the coordinate varibles could be found at the following:
```console
/project/6008034/Model_Output/WRF/CONUS/CTRL/coord.nc
```
However, upon many trials by the author, the variables were not concatenated with the main NetCDF files easily. A workaround has been provided to add at least two necessary coordinate variables, i.e., `XLAT` and `XLONG`, to the WRF simulation files. These two coordinates are enough to work with almost all of the meteorological variables included in the dataset. The following scripts are used on Compute Canada (CC) Graham Cluster to produce the substitute NetCDF file containing coordinate variables:
```console
# make a copy of coordinate variable netCDF file first
foo@bar:~$ module load cdo/2.0.4; module load nco/5.0.6;
foo@bar:~$ coordFile="/project/6008034/Model_Output/WRF/CONUS/CTRL/coord.nc"
foo@bar:~$ ncks -O -v XLAT,XLONG "$coordFile" coord2.nc
foo@bar:~$ nccopy -4 coord2.nc coord_new.nc 
foo@bar:~$ ncatted -O -a FieldType,XLAT,d,, coord_new.nc 
foo@bar:~$ ncatted -O -a MemoryOrder,XLAT,d,, coord_new.nc 
foo@bar:~$ ncatted -O -a stagger,XLAT,d,, coord_new.nc 
foo@bar:~$ ncatted -O -a coordinates,XLAT,d,, coord_new.nc 
foo@bar:~$ ncatted -O -a sr_x,XLAT,d,, coord_new.nc
foo@bar:~$ ncatted -O -a sr_y,XLAT,d,, coord_new.nc
foo@bar:~$ ncatted -O -a FieldType,XLONG,d,, coord_new.nc 
foo@bar:~$ ncatted -O -a MemoryOrder,XLONG,d,, coord_new.nc 
foo@bar:~$ ncatted -O -a stagger,XLONG,d,, coord_new.nc 
foo@bar:~$ ncatted -O -a coordinates,XLONG,d,, coord_new.nc
foo@bar:~$ ncatted -O -a sr_x,XLONG,d,, coord_new.nc
foo@bar:~$ ncatted -O -a sr_y,XLONG,d,, coord_new.nc
foo@bar:~$ ncwa -O -a Times coord_new.nc coord_new.nc
foo@bar:~$ ncks -O -v XLAT,XLONG coord_new.nc coord_new.nc
foo@bar:~$ ncrename -a XLONG@description,long_name coord_new.nc
foo@bar:~$ ncrename -a XLAT@description,long_name coord_new.nc
foo@bar:~$ ncatted -O -a cell_methods,,d,, coord_new.nc
foo@bar:~$ ncatted -O -a cell_methods,,d,, coord_new.nc
foo@bar:~$ ncatted -O -a ,global,d,, coord_new.nc
foo@bar:~$ ncatted -O -h -a license,global,c,c,"GNU General Public License v3 (GPLv3)" coord_new.nc
```
Furthermore, the substitute NetCDF file containing the coordinate variables are located at `/asset/coord_XLAT_XLONG_conus_i.nc` within this repository. The workaround NetCDF is automatically being used by the script to add the `XLAT` and `XLONG` variables to the final, produced files.

### Time-stamps
The time-stamp of the time-steps are missing from the dataset NetCDF files. However, the time-stamps for each time-step is obvious from the file names. The time-stamp pattern of the dataset files is as following: `%Y-%m-%d_%H:00:00` which will be changed to `%Y-%m-%s %H:00:00` to be registered as a valid time-stamp in the NetCDF files. The script is able to set the time-stamps for the final produced file(s) automatically.

## Dataset Variables
The NetCDF files of the dataset contain 281 variables. You may see a list of variables by using the `ncdump -h`  command on one of the files:
```console
foo@bar:~$ module load cdo/2.0.4
foo@bar:~$ module load nco/5.0.6
foo@bar:~$ ncdump -h  /project/6008034/Model_Output/WRF/CONUS/CTRL/2000/wrf2d_d01_2000-10-01_00:00:00
```

## Spatial Extent
The spatial extent of the `WRF-CONUSI` is on latitutes from `18.13629` to `57.91813` and longitudes from `-139.0548` to `-56.94519`.

## Temporal Extent
As is obvious from the nomenclature of the dataset files, the time-steps are hourly covering from the October 2000 to December 2013.

# Short Description on `WRF-CONUSI` Variables
In most hydrological modelling applications, usually 7 variables are needed detailed as following: 1) specific humidity at 2 meters, 2) surface pressure, 3) air temperature at 2 meters, 4) wind speed at 10 meters, 5) precipitation, 6) downward short wave radiation, and 7) downward long wave radiation. These variables are available through `WRF-CONUSI` dataset and their details are described in the table below:
|Variable Name        |WRF-CONUSI Variable|Unit |IPCC abbreviation|Comments            |
|---------------------|-------------------|-----|-----------------|--------------------|
|surface pressure     |PSFC               |Pa   |ps               |                    |
|specific humidity @2m|Q2                 |1    |huss             |                    |
|air tempreature @2m  |T2                 |k    |tas              |                    |
|wind speed @10m      |U10,V10            |m/s  |wspd             |WIND=SQRT(U10<sup>2</sup>+V10<sup>2</sup>)|
|precipitation        |PREC_ACC_NC        |mm/hr|                 |accumulated precipitation over one hour|
|short wave radiation |ACSWDNB            |W m-2|rsds             |                    |
|long wave radiation  |ACLWDNB            |W m-2|rlds             |                    |
