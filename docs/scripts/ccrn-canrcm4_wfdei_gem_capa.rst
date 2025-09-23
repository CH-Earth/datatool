CCRN ``CanRCM4-WFDEI-GEM-CaPA``
===============================

Location of Dataset Files
-------------------------

The ``CanRCM4-WFDEI-GEM-CaPA`` dataset is located under the following
directory accessible from Digital Alliance of Canada (formerly Compute
Canada) Graham cluster:

.. code:: console

   # Graham DRAC HPC Location
   /project/rpp-kshook/Model_Output/280_CanRCM4_Cor_WFDEI-GEM-CaPA # rpp-kshook allocation

   # Fir DRAC HPC Location
   /project/rrg-alpie/data/meteorological-data/280_CanRCM4_Cor_WFDEI-GEM-CaPA # rrg-alpie allocation

and the structure of the dataset hourly files is as following:

.. code:: console

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

Below is a list of ensemble members for this datase:

.. code::

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

Coordinate Variables and Time-stamps
------------------------------------

Coordinate Variables
~~~~~~~~~~~~~~~~~~~~

The coordinate variables of the ``CanRCM4-WFDEI-GEM-CaPA`` simulations
are ``lon`` and ``lat`` representing the longitude and latitude points,
respectively. ### Time-stamps The time-stamps are included in the
original files.

Dataset Variables
-----------------

Each NetCDF file belongs to a single variable. The list of variables
included in the dataset is descriped in `Short Description on Dataset
Variables <##short-description-on-dataset-variables>`__ ## Spatial
Extent The spatial extent of the dataset is on latitutes from
``31.0625`` to ``71.9375`` and longitudes from ``-149.9375`` to
``-50.0625`` covering North America. The resolution is 0.125 degrees.

Temporal Extent
---------------

The time-steps are 3-hourly covering from ``January 1951`` to
``December 2100``.

Short Description on Dataset Variables
--------------------------------------

In most hydrological modelling applications, usually 7 variables are
needed detailed as following: 1) specific humidity at the Lowest Model
Level (sigma=0.995), 2) surface pressure, 3) air temperature at the
Lowest Model Level, 4) wind speed at the Lowest Model Level
(sigma=0.995), 5) precipitation, 6) downward short wave radiation, and
7) downward long wave radiation. These variables are available through
``CanRCM4-WFDEI-GEM-CaPA`` dataset and their details are described in
the table below:

.. list-table:: Variable Information
   :header-rows: 1

   * - Variable Name
     - Dataset Variable
     - Unit
     - IPCC Abbreviation
     - Comments
   * - surface pressure
     - ps
     - Pa
     - ps
     - surface pressure
   * - specific humidity @1.5m
     - hus
     - 1
     - huss
     - Specific Humidity at Lowest Model Level (sigma=0.995)
   * - air temperature @1.5m
     - ta
     - K
     - tas
     - Air Temperature at Lowest Model Level (sigma=0.995)
   * - wind speed @10m
     - wind
     - m/s
     - wspd
     - Wind Modulus at Lowest Model Level (sigma=0.995)
   * - precipitation
     - pr
     - kg m\ :sup:`-2` s\ :sup:`-1`
     -
     - precipitation flux
   * - short wave radiation
     - rsds
     - W m\ :sup:`-2`
     - rsds
     - Surface Downwelling Shortwave Flux
   * - long wave radiation
     - lsds
     - W m\ :sup:`-2`
     - rlds
     - Surface Downwelling Longwave Flux
