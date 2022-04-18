# NCAR-GWF WRF CONUSI Simulation Outputs

## Location of Dataset Files
The WRF-CONUSI simulation outputs are located under the following directory, accessible from Compute Canada (CC) Graham Cluster:
```
/project/6008034/Model_Output/WRF/CONUS/CTRL/
```
and the structure of the dataset hourly files is as following:
```console
/path/to/dataset/files/
├── %Y
│   ├── wrf2d_d01_%Y-%m-%d_%H:00:00
│   ├── .
│   ├── .
│   ├── .
│   .
│   .
│   .
├── 2001
│   ├── wrf2d_d01_2001-01-01_00:00:00
│   ├── wrf2d_d01_2001-01-01_01:00:00
│   ├── .
│   ├── .
│   ├── .
│   └── wrf2d_d01-2001-12-31_23:00:00
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

The coordinate variables of the WRF CONUSI simulations are located outside of the main dataset files. Dr. Zhenhua Li has provided the NetCDF file containing the coordinate varibles in the following address:
```console
/project/6008034/Model_Output/WRF/CONUS/CTRL/coord.nc
```
However, upon many trials by the author, the variables could not be concatenated with the main files. A workaround has been provided by Dr. Shervan Gharari to add at least two necessary variables, i.e., `XLAT` and `XLONG`, to the WRF simulation files. These two variables are enough to work with most of the meteorological variables included in the dataset. The following scripts are used on Compute Canada (CC) Graham Cluster to produce the workaround solution file:
```console
foo@bar:~$ 
foo@bar:~$ 
foo@bar:~$ 
```

## Dataset Dimensions
The NetCDF file of the dataset contains 283 variables. You may see a list of variables by using the following command on one of the files:
```consol
foo@bar:~$ module load cdo/2.0.4
foo@bar:~$ module load nco/5.0.6
foo@bar:~$ ncdump -h  /project/6008034/Model_Output/WRF/CONUS/CTRL/2000/wrf2d_d01_2000-10-01_00:00:00
```
## Spatial Extent
The spatial extent of the `WRF-CONUSI` is on latitutes from `18.13629` to `57.91813` and longitudes from `-139.0548` to `-56.94519`.

## Temporal Extent
As is obvious from the nomenclature of the dataset files, the time-steps are hourly and covers from the October 2010 to December 2013.

## 
