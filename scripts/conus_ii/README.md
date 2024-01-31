# NCAR-GWF `WRF-CONUSII` Simulation Outputs

In this file, the details of the dataset is explained.

> [!WARNING]
> It must be noted that the `WRF-CONUSII` dataset are in `.tar` format and the script untars the files automatically. 

> [!CAUTION]
> `WRF-CONUSI` dataset needs extensive I/O operations in the `cache`
> directory. So, in case of submitting `SLURM` jobs, it is recommended to
> use the `$SLURM_TMPDIR` directory as `cache`. This can be provided to
> the main `extract-dataset.sh` script using the `--cache='$SLURM_TMPDIR'`
## Location of Dataset Files

The `WRF-CONUSII` simulation outputs are located under the following directory accessible from Compute Canada (CC) Graham Cluster:
```
/project/rpp-kshook/Model_Output/wrf-conus/CONUSII/hist
```
and the structure of the dataset hourly files is as following:
```console
/project/rpp-kshook/Model_Output/wrf-conus/CONUSII/hist
├── 1995
│   ├── wrf2d_conusii_19950101.tar
│   ├── wrf2d_conusii_19950102.tar
│   ├── .
│   ├── .
│   ├── .
│   └── wrf2d_conusii_19951231.tar
.
.
.
├── %Y
│   ├── wrf2d_conusii_%Y%m%d.tar
│   ├── .
│   ├── .
│   ├── .
│   .
│   .
│   .
.
.
.
└── 2015
    ├── .
    ├── .
    ├── .
    └── wrf2d_conusii_20151231.tar
```
And, each `.tar` file has the following structure of content:
```
foo@bar:~$ tar --strip-components=5 -xvf wrf2d_conusii_%Y%m%d.tar > /dev/null
/path/to/tar/extracted/files
└── %Y
    ├── wrf2d_d01_%Y-%m-%d_00:00:00
    .
    .
    .
    └── wrf2d_d01_%Y-%m-%d_23:00:00
```
## Coordinate Variables and Time-stamps

### Coordinate Variables
The coordinate variables of the `WRF-CONUSII` simulations are located outside of the main dataset files. The NetCDF file containing the coordinate varibles could be found at the following:
```console
/project/rpp-kshook/Model_Output/wrf-conus/CONUSII/hist/wrf04km_coord.nc
```
However, upon many trials by the author, the variables were not concatenated with the main NetCDF files easily. A workaround has been provided to add at least two necessary coordinate variables, i.e., `XLAT` and `XLONG`, to the WRF simulation files. These two coordinates are enough to work with almost all of the meteorological variables included in the dataset. The following scripts are used on Compute Canada (CC) Graham Cluster to produce the substitute NetCDF file containing coordinate variables:
```console
# make a copy of coordinate variable NetCDF file first!
foo@bar:~$ module load cdo/2.0.4; module load nco/5.0.6; # load necessary modules
foo@bar:~$ coordFile="/project/rpp-kshook/Model_Output/wrf-conus/CONUSII/hist/wrf04km_coord.nc"
foo@bar:~$ ncks -v XLAT,XLONG "$coordFile" coord.nc
foo@bar:~$ nccopy -4 coord.nc coord_new.nc
foo@bar:~$ ncatted -O -a FieldType,XLAT,d,, coord_new.nc
foo@bar:~$ ncatted -O -a MemoryOrder,XLAT,d,, coord_new.nc
foo@bar:~$ ncatted -O -a stagger,XLAT,d,, coord_new.nc
foo@bar:~$ ncatted -O -a coordinates,XLAT,d,, coord_new.nc 
foo@bar:~$ ncatted -O -a FieldType,XLONG,d,, coord_new.nc
foo@bar:~$ ncatted -O -a MemoryOrder,XLONG,d,, coord_new.nc
foo@bar:~$ ncatted -O -a stagger,XLONG,d,, coord_new.nc
foo@bar:~$ ncatted -O -a coordinates,XLONG,d,, coord_new.nc
foo@bar:~$ ncwa -O -a Time coord_new.nc coord_new.nc
foo@bar:~$ ncrename -a XLONG@description,long_name coord_new.nc
foo@bar:~$ ncrename -a XLAT@description,long_name coord_new.nc
foo@bar:~$ ncatted -O -a cell_methods,,d,, coord_new.nc
foo@bar:~$ ncatted -O -a cell_methods,,d,, coord_new.nc
foo@bar:~$ ncatted -O -a ,global,d,, coord_new.nc
foo@bar:~$ ncatted -O -h -a license,global,c,c,"GNU General Public License v3 (GPLv3)" coord_new.nc
```
Furthermore, the substitute NetCDF file containing the coordinate variables are located at `/asset/coord_XLAT_XLONG_conus_i.nc` within this repository. The workaround NetCDF is automatically being used by the script to add the `XLAT` and `XLONG` variables to the final, produced files.

### Time-stamps
Each hourly, extracted NetCDF files from `.tar` files will have a single time-stamp indicating the time-step of the file.

## Dataset Variables
The NetCDF files of the dataset contain 187 variables. You may see a list of variables by using the `ncdump -h`  command on one of the files:
```console
foo@bar:~$ module load cdo/2.0.4
foo@bar:~$ module load nco/5.0.6
foo@bar:~$ ncdump -h  /path/to/extracted/conusii/netcdf/file.nc
```

## Spatial Extent
The spatial extent of the `WRF-CONUSII` is on latitutes from `15.02852` to `73.27542` and longitudes from `-156.8242` to `-40.3046`.

## Temporal Extent
As is obvious from the nomenclature of the dataset files, the time-steps are hourly covering from the January 1995 to December 2015.

# Short Description on `WRF-CONUSII` Variables
In most hydrological modelling applications, usually 7 variables are needed detailed as following: 1) specific humidity at 2 meters, 2) surface pressure, 3) air temperature at 2 meters, 4) wind speed at 10 meters, 5) precipitation, 6) downward short wave radiation, and 7) downward long wave radiation. These variables are available through `WRF-CONUSII` dataset and their details are described in the table below:
|Variable Name        |WRF-CONUSII Variable|Unit |IPCC abbreviation|Comments            |
|---------------------|--------------------|-----|-----------------|--------------------|
|surface pressure     |PSFC                |Pa   |ps               |                    |
|specific humidity @2m|Q2                  |1    |huss             |                    |
|air tempreature @2m  |T2                  |k    |tas              |                    |
|wind speed @10m      |U10,V10             |m/s  |wspd             |WIND=SQRT(U10<sup>2</sup>+V10<sup>2</sup>)|
|precipitation        |PREC_ACC_NC         |mm/hr|                 |accumulated precipitation over one hour|
|short wave radiation |ACSWDNB             |W m-2|rsds             |                    |
|long wave radiation  |ACLWDNB             |W m-2|rlds             |                    |
