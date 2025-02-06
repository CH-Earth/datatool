ECCC ``RDRS`` v2.1
==================

In this file, the details of the dataset is explained.

Location of Dataset Files
-------------------------

The ``RDRS`` v2.1 dataset is located under the following directory
accessible from Compute Canada (CC) Graham Cluster:

.. code:: console

   /project/rpp-kshook/Climate_Forcing_Data/meteorological-data/rdrsv2.1 # rpp-kshook allocation
   /project/rrg-mclark/data/meteorological-data/rdrsv2.1 # rrg-mclark allocation

and the structure of the dataset hourly files is as following:

.. code:: console

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

Coordinate Variables and Time-stamps
------------------------------------

Coordinate Variables
~~~~~~~~~~~~~~~~~~~~

The coordinate variables of the ``ERA5`` simulations are ``lon`` and
``lat`` representing the longitude and latitude points, respectively.
### Time-stamps The time-stamps are included in the original files.

Dataset Variables
-----------------

The NetCDF files of the dataset contain 28 variables. You may see a list
of variables by using the ``ncdump -h`` command on one of the files:

.. code:: console

   foo@bar:~$ module load cdo/2.0.4
   foo@bar:~$ module load nco/5.0.6
   foo@bar:~$ ncdump -h /project/rpp-kshook/Model_Output/RDRSv2.1/1980/1980010112.nc

Spatial Extent
--------------

The spatial extent of the ``RDRS`` v2.1 is on latitutes from ``+5.75``
to ``+64.75`` and longitudes from ``-179.9925`` to ``179.9728`` covering
North America. The resolution is 0.09 degrees (~10km).

Temporal Extent
---------------

The time-steps are hourly covering from ``January 1980`` to
``December 2018``.

Short Description on ``RDRS`` v2.1 Variables
--------------------------------------------

In most hydrological modelling applications, usually 7 variables are
needed detailed as following: 1) specific humidity (@1.5-2.0m or @40m),
2) surface pressure, 3) air temperature (@1.5m-2.0m or 40m), 4) wind
speed (@10m or @40m), 5) precipitation (surface level), 6) downward
short wave radiation (surface level), and 7) downward long wave
radiation (surface level). These variables are available through
``RDRS`` v2.1 dataset and their details are described in the table
below:

.. list-table:: Variable Information
   :header-rows: 1
   :widths: 20 20 10 10 40

   * - Variable Name
     - RDRSv2.1 Variable
     - Unit
     - IPCC abbreviation
     - Comments
   * - surface pressure
     - ``RDRS_v2.1_P_P0_SFC``
     - mb
     - ps
     -
   * - specific humidity@1.5m
     - ``RDRS_v2.1_P_HU_1.5m``
     - 1
     - huss
     -
   * - air temperature @1.5m
     - ``RDRS_v2.1_P_TT_1.5m``
     - °C
     - tas
     -
   * - wind speed @10m
     - ``RDRS_v2.1_P_UVC_10m``
     - kts
     - wspd
     - WIND=SQRT(U10^2+V10^2)
   * - precipitation
     - ``RDRS_v2.1_A_PR0_SFC``
     - m/hr
     -
     - CaPA outputs
   * - short wave radiation
     - ``RDRS_v2.1_P_FB_SFC``
     - W m-2
     - rsds
     - Downward solar flux
   * - long wave radiation
     - ``RDRS_v2.1_P_FI_SFC``
     - W m-2
     - rlds
     - Downward infrared flux
   * - specific humidity @40m
     - ``RDRS_v2.1_P_HU_09944``
     - 1
     - huss
     -
   * - air temperature @40m
     - ``RDRS_v2.1_P_TT_09944``
     - °C
     - tas
     -
   * - wind speed @40m
     - ``RDRS_v2.1_P_UVC_09944``
     - kts
     - wspd
     -


Please visit the `official
website <https://github.com/julemai/CaSPAr/wiki/Available-products>`__
for the dataset for the most up-to-date information.
