ECCC ``CaSR`` v3.1
==================

In this file, the details of the dataset is explained.

Location of Dataset Files
-------------------------

The ``CaSR`` v3.1 dataset is located under the following directories
accessible from multiple clusters listed below:

.. code:: console

   # DRAC Nibi (formerly Graham) cluster
   /project/def-kshook/Climate_Forcing_Data/meteorological-data/casrv3.1 # def-kshook allocation

   # DRAC Fir cluster
   /project/rrg-alpie/data/meteorological-data/casrv3.1 # rrg-alpie allocation

   # UCalgary ARC cluster
   /work/comphyd_lab/data/meteorological-data/casrv3.1 # comphyd_lab allocation

and the structure of the dataset hourly files is as following:

.. code:: console

   /project/def-kshook/Climate_Forcing_Data/meteorological-data/casrv3.1
   ├── 1979123112.nc
   ├── 1980010112.nc
   ├── 1980010212.nc
   ├── 1980010312.nc
   ├── .
   ├── .
   ├── .
   ├── %Y010112.nc
   ├── .
   ├── .
   ├── %Y%m%d12.nc
   ├── .
   ├── .
   ├── %Y123112.nc
   ├── 2024010112.nc
   ├── .
   ├── .
   ├── .
   └── 2024123012.nc

Coordinate Variables and Time-stamps
------------------------------------

Coordinate Variables
~~~~~~~~~~~~~~~~~~~~

The coordinate variables of the ``CaSRv3.1`` simulations are ``lon`` and
``lat`` representing the longitude and latitude data, respectively.

Variable Time-stamps
--------------------

Time-stamps The time-stamps are included in the original files.

Dataset Variables
-----------------

The NetCDF files of the dataset contain 38 variables. You may see a list
of variables by using the ``ncdump -h`` command on one of the files:

.. code:: console

   foo@bar:~$ ncdump -h /path/to/dataset/files/casrv3.1/2018010112.nc

Spatial Extent
--------------

The spatial extent of the ``CaSR`` v3.1 is on latitudes from ``+7.75``
to ``+84.75`` and longitudes from ``-179.9925`` to ``179.9728`` covering
North America. The resolution is 0.09 degrees (~10km).

Temporal Extent
---------------

The time-steps are hourly covering from ``January 1980`` to
``December 2024``.

Short Description on ``CaSR`` v3.1 Variables
--------------------------------------------

In most hydrological modelling applications, usually 7 variables are
needed detailed as following: 1) specific humidity, 2) surface pressure,
3) air temperature, 4) wind speed, 5) precipitation (surface level), 6)
downward short wave radiation (surface level), and 7) downward long wave
radiation (surface level). These variables are available through
``CaSR`` v3.1 dataset and their details are described in the table
below:

.. list-table:: Variable Mapping
   :widths: 30 30 10 30
   :header-rows: 1

   * - Variable Name
     - CaSRv3.1 Variable
     - Unit
     - Comments
   * - surface pressure
     - CaSR_v3.1_P_P0_SFC
     - ``mb``
     - 
   * - air temperature @20m
     - CaSR_v3.1_P_TT_09975
     - ``°C``
     - 
   * - air temperature @1.5m
     - CaSR_v3.1_P_TT_1.5m
     - ``°C``
     - 
   * - wind speed U-component @20m
     - CaSR_v3.1_P_UUC_09975
     - ``kts``
     - Corrected U-component along West-East direction at ~20m
   * - wind speed U-component @10m
     - CaSR_v3.1_P_UUC_10m
     - ``kts``
     - Corrected U-component along West-East direction at ~10m
   * - wind speed V-component @20m
     - CaSR_v3.1_P_VVC_09975
     - ``kts``
     - Corrected V-component along South-North direction at ~20m
   * - wind speed V-component @10m
     - CaSR_v3.1_P_VVC_10m
     - ``kts``
     - Corrected V-component along South-North direction at ~10m
   * - wind modulus @20m
     - CaSR_v3.1_P_UVC_09975
     - ``kts``
     - Forecast: Wind Modulus (derived using UU and VV) at 20m
   * - wind modulus @10m
     - CaSR_v3.1_P_UVC_10m
     - ``kts``
     - Forecast: Wind Modulus (derived using UU and VV) at 10m
   * - precipitation
     - CaSR_v3.1_A_PR0_SFC
     - ``m/hr``
     - Analysis: Quantity of precipitation (CaPA 24h disaggregated hourly) at surface
   * - short wave radiation
     - CaSR_v3.1_P_FB_SFC
     - ``W m-2``
     - Downward solar flux at the surface
   * - long wave radiation
     - CaSR_v3.1_P_FI_SFC
     - ``W m-2``
     - Downward infrared flux at the surface
   * - specific humidity @20m
     - CaSR_v3.1_P_HU_09975
     - 1
     - Specific humidity at ~20m (0.997502 hy)
   * - specific humidity @1.5m
     - CaSR_v3.1_P_HU_1.5m
     - 1
     - Specific humidity at ~1.50m

Other useful variables in hydrological modelling evaluations are:

.. list-table:: Snow and Precipitation Variables
   :widths: 35 30 10 25
   :header-rows: 1

   * - Variable Name
     - CaSRv3.1 Variable
     - Unit
     - Comments
   * - Water equivalent of snow cover
     - CaSR_v3.1_P_SWE_LAND
     - ``kg m-2``
     - Water equivalent of snow cover at land surface subgrid tile
   * - Snow depth
     - CaSR_v3.1_P_SD_LAND
     - ``cm``
     - Snow depth at land surface subgrid tile
   * - Freezing precipitation
     - CaSR_v3.1_P_FR0_SFC
     - ``m``
     - Quantity of freezing precipitation (liquid water equivalent) at surface
   * - Geopotential height
     - CaSR_v3.1_P_GZ_09975
     - ``dam``
     - Geopotential height at ~20m (0.997502 hy)
   * - Geopotential height
     - CaSR_v3.1_P_GZ_SFC
     - ``dam``
     - Geopotential height at the surface
   * - Liquid precipitation
     - CaSR_v3.1_P_RN0_SFC
     - ``m``
     - Forecast: Quantity of liquid precipitation at surface
   * - Meteorological wind direction
     - CaSR_v3.1_P_WDC_09975
     - ``degree``
     - Forecast: Meteorological wind direction (derived using UU and VV) at ~20m (0.997502 hy)
   * - Meteorological wind direction
     - CaSR_v3.1_P_WDC_10m
     - ``degree``
     - Forecast: Meteorological wind direction (derived using UU and VV) at ~10m

.. note::

   A bug has been identified in the precipitation analysis for the years 
   2005 to 2010 (variables: ``A_PR0_SFC``, ``A_PR24_SFC``, ``A_CFIA_SFC``),
   mainly affecting Quebec (and very slightly and sporadically elsewhere
   in Canada). We are actively working to resolve this issue. The upcoming
   corrected release, **CaSRv3.2**, is expected within the next few weeks.
   In addition to fixing this bug, it will also include further improvements
   to precipitation analyses for the year 2024 as well as a number of
   technical changes.


Last updated: September 8, 2025
