Ouranos ``ESPO-G6-R2 v1.0.0`` dataset
=====================================

In this file, the details of the dataset is explained.

Location of Dataset Files
-------------------------

The ``ESPO-G6-R2 v1.0.0`` dataset is located under the following
directory accessible from Compute Canada (CC) Graham Cluster:

.. code:: console

   /project/rpp-kshook/Climate_Forcing_Data/meteorological-data/ouranos-espo-g6-r2 # rpp-kshook allocation
   /project/rrg-mclark/data/meteorological-data/ouranos-espo-g6-r2 # rrg-mclark allocation

and the structure of the dataset hourly files is as following:

.. code:: console

   /project/rrg-mclark/data/meteorological-data/ouranos-espo-g6-r2
   ├── AS-RCEC
   │   └── TaiESM1 
   │       ├── ssp245 
   |       |   └── r1i1p1f1
   │       |       └── day
   |       |           ├── pr
   │       |           |   ├── pr_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_AS-RCEC_TaiESM1_ssp245_r1i1p1f1_19500101-19531231.nc
   |       |           |   ├── pr_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_AS-RCEC_TaiESM1_ssp245_r1i1p1f1_19540101-19571231.nc
   |       |           |   ├── . 
   |       |           |   ├── . 
   |       |           |   ├── . 
   |       |           |   ├── pr_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_AS-RCEC_TaiESM1_ssp245_r1i1p1f1_20940101-20971231.nc
   |       |           |   └── pr_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_AS-RCEC_TaiESM1_ssp245_r1i1p1f1_20980101-210031231.nc
   │       |           ├── tasmax
   |       |           |   ├── tasmax_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_AS-RCEC_TaiESM1_ssp245_r1i1p1f1_19500101-19531231.nc
   |       |           |   ├── tasmax_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_AS-RCEC_TaiESM1_ssp245_r1i1p1f1_19540101-19571231.nc
   |       |           |   ├── . 
   |       |           |   ├── . 
   |       |           |   ├── . 
   |       |           |   ├── tasmax_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_AS-RCEC_TaiESM1_ssp245_r1i1p1f1_20940101-20971231.nc
   |       |           |   └── tasmax_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_AS-RCEC_TaiESM1_ssp245_r1i1p1f1_20980101-21001231.nc
   |       |           └── tasmin
   |       |               ├── tasmin_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_AS-RCEC_TaiESM1_ssp245_r1i1p1f1_19500101-19531231.nc
   |       |               ├── tasmin_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_AS-RCEC_TaiESM1_ssp245_r1i1p1f1_19540101-19571231.nc
   |       |               ├── .
   |       |               ├── .
   |       |               ├── .
   |       |               ├── tasmin_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_AS-RCEC_TaiESM1_ssp245_r1i1p1f1_20940101-20971231.nc
   |       |               └── tasmin_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_AS-RCEC_TaiESM1_ssp245_r1i1p1f1_20980101-21001231.nc
   │       └── ssp370
   |           └── r1i1p1f1
   │               └── day
   |                   ├── pr
   │                   |   ├── . 
   │                   |   ├── . 
   │                   |   └── . 
   |                   ├── tasmax
   │                   |   ├── . 
   │                   |   ├── . 
   │                   |   └── . 
   |                   tasmin
   │                       ├── . 
   │                       ├── . 
   │                       └── . 
   │
   .
   .
   .
   ├── %{model}
   |   ├── %{submodel} # no need for explicit declaration in the scripts 
   |   |   ├── %{scenario}
   |   |   |   └── %{ensemble}
   |   |   |       └── day
   |   |   |           ├── %{var}
   |   |   |           |   ├── %{var}_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_%{model}_%{submodel}_%{scenario}_%{ensemble}_%{year}0101_%{year+3}1231.nc
   |   |   |           |   ├── . 
   |   |   |           |   ├── . 
   |   |   |           |   ├── . 
   |   |   |           |   └── %{var}_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_%{model}_%{submodel}_%{scenario}_%{ensemble}_%{year}0101_%{year+2}1231.nc
   .   .   .           .
   .   .   .           .
   .   .   .           .
   └── NUIST
       └── NESM3
           ├── ssp245 
           |   └── r1i1p1f1
           |       └── day
           |           ├── pr
           |           |   ├── pr_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_NUIST_NESM3_ssp245_r1i1p1f1_19500101-19531231.nc
           |           |   ├── pr_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_NUIST_NESM3_ssp245_r1i1p1f1_19540101-19571231.nc
           |           |   ├── . 
           |           |   ├── . 
           |           |   ├── . 
           |           |   ├── pr_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_NUIST_NESM3_ssp245_r1i1p1f1_20940101-20971231.nc
           |           |   └── pr_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_NUIST_NESM3_ssp245_r1i1p1f1_20980101-210031231.nc
           |           ├── tasmax
           |           |   ├── tasmax_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_NUIST_NESM3_ssp245_r1i1p1f1_19500101-19531231.nc
           |           |   ├── tasmax_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_NUIST_NESM3_ssp245_r1i1p1f1_19540101-19571231.nc
           |           |   ├── . 
           |           |   ├── . 
           |           |   ├── . 
           |           |   ├── tasmax_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_NUIST_NESM3_ssp245_r1i1p1f1_20940101-20971231.nc
           |           |   └── tasmax_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_NUIST_NESM3_ssp245_r1i1p1f1_20980101-21001231.nc
           |           └── tasmin
           |               ├── tasmin_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_NUIST_NESM3_ssp245_r1i1p1f1_19500101-19531231.nc
           |               ├── tasmin_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_NUIST_NESM3_ssp245_r1i1p1f1_19540101-19571231.nc
           |               ├── .
           |               ├── .
           |               ├── .
           |               ├── tasmin_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_NUIST_NESM3_ssp245_r1i1p1f1_20940101-20971231.nc
           |               └── tasmin_day_ESPO-G6-R2_v1.0.0_CMIP6_ScenarioMIP_NAM_NUIST_NESM3_ssp245_r1i1p1f1_20980101-21001231.nc
           └── ssp370
               └── r1i1p1f1
                   └── day
                       ├── pr
                       |   ├── . 
                       |   ├── . 
                       |   └── . 
                       ├── tasmax
                       |   ├── . 
                       |   ├── . 
                       |   └── . 
                       tasmin
                           ├── . 
                           ├── . 
                           └── . 

Coordinate Variables and Time-stamps
------------------------------------

Coordinate Variables
~~~~~~~~~~~~~~~~~~~~

The coordinate variables of the ``ESPO-G6-R2 v1.0.0`` simulations are
``rlon`` and ``rlat`` representing the longitude and latitude points,
respectively. ### Time-stamps The time-stamps are included in the
original files.

Dataset Variables
-----------------

The NetCDF files of the dataset contain one variable per file. You may
see a list of variables by browsing the dataset files:

.. code:: console

   foo@bar:~$ ls /project/rrg-mclark/data/meteorological-data/ouranos-espo-g6-r2/ESPO-G6-R2v1.0.0/AS-RCEC/TaiESM1/ssp245/r1i1p1f1/day

Spatial Extent
--------------

The spatial extent of the ``ESPO-G6-R2 v1.0.0`` is on latitutes from
``+5.75`` to ``+83.98`` and longitudes from ``-179.9925`` to
``179.9728`` covering North America. The resolution is 0.09 degrees
(~10km).

Temporal Extent
---------------

The time-stamps are already included in the original files. The dataset
offers **daily** time-series of climate variables. The following table
describes the temporal extent for senarios included in this dataset:

.. list-table:: Scenarios and Temporal Extent
   :header-rows: 1

   * - #
     - Scenarios (keyword for ``--scenario``)
     - Temporal Extent
   * - 1
     - ``ssp245``
     - ``2015-01-01`` to ``2100-12-31``
   * - 2
     - ``ssp370``
     - ``2015-01-01`` to ``2100-12-31``
   * - 3
     - ``ssp585``
     - ``2015-01-01`` to ``2100-12-31``


List of Ensemble Members
------------------------

+---+---------------------------+---------------------------------------+
| # | Models (keyword for       | Ensemble Members (keyword for         |
|   | ``--model``)              | ``--ensemble``)                       |
+===+===========================+=======================================+
| 1 | ``AS-RCEC``               | ``r1i1p1f1``                          |
+---+---------------------------+---------------------------------------+
| 2 | ``BCC``                   | ``r1i1p1f1``                          |
+---+---------------------------+---------------------------------------+
| 3 | ``CAS``                   | ``r1i1p1f1``                          |
+---+---------------------------+---------------------------------------+
| 4 | ``CCCma``                 | ``r1i1p1f1``                          |
+---+---------------------------+---------------------------------------+
| 5 | ``CMCC``                  | ``r1i1p1f1``                          |
+---+---------------------------+---------------------------------------+
| 6 | ``CNRM-CERFACS``          | ``r1i1p1f2``                          |
+---+---------------------------+---------------------------------------+
| 7 | ``CSIRO``                 | ``r1i1p1f1``                          |
+---+---------------------------+---------------------------------------+
| 8 | ``CSIRO-ARCCSS``          | ``r1i1p1f1``                          |
+---+---------------------------+---------------------------------------+
| 9 | ``DKRZ``                  | ``r1i1p1f1``                          |
+---+---------------------------+---------------------------------------+
| 1 | ``EC-Earth-Consortium``   | ``r1i1p1f1``                          |
| 0 |                           |                                       |
+---+---------------------------+---------------------------------------+
| 1 | ``INM``                   | ``r1i1p1f1``                          |
| 1 |                           |                                       |
+---+---------------------------+---------------------------------------+
| 1 | ``IPSL``                  | ``r1i1p1f1``                          |
| 2 |                           |                                       |
+---+---------------------------+---------------------------------------+
| 1 | ``MIROC``                 | ``r1i1p1f1``, ``r1i1p1f2``            |
| 3 |                           |                                       |
+---+---------------------------+---------------------------------------+
| 1 | ``MOHC``                  | ``r1i1p1f2``                          |
| 4 |                           |                                       |
+---+---------------------------+---------------------------------------+
| 1 | ``MPI-M``                 | ``r1i1p1f1``                          |
| 5 |                           |                                       |
+---+---------------------------+---------------------------------------+
| 1 | ``MRI``                   | ``r1i1p1f1``                          |
| 6 |                           |                                       |
+---+---------------------------+---------------------------------------+
| 1 | ``NCC``                   | ``r1i1p1f1``                          |
| 7 |                           |                                       |
+---+---------------------------+---------------------------------------+
| 1 | ``NIMS-KMA``              | ``r1i1p1f1``                          |
| 8 |                           |                                       |
+---+---------------------------+---------------------------------------+
| 1 | ``NOAA-GFDL``             | ``r1i1p1f1``                          |
| 9 |                           |                                       |
+---+---------------------------+---------------------------------------+
| 2 | ``NUIST``                 | ``r1i1p1f1``                          |
| 0 |                           |                                       |
+---+---------------------------+---------------------------------------+

Short Description on ``ESPO-G6-R2 v1.0.0`` Variables
----------------------------------------------------

This dataset only offers three climate variables: 1) daily precipitation
time-series (surface level), 2) daily minimum temperature time-series
(@2m, near-surface level), and 3) daily maximum temperature time-series
(@2m, near-surface level). Since the frequency of this dataset is daily,
and only offers precipitation and temperature values, therefore, it
could be potentially used for forcing conceptual hydrological models
that only need daily time-series of these variables.

The table below, summarizes the variables offered by this dataset:

.. list-table:: Variable Information
   :header-rows: 1

   * - Variable Name
     - Variable (keyword for ``--variable``)
     - Unit
     - IPCC Abbreviation
     - Comments
   * - maximum temperature
     - ``tasmax``
     - K
     - tasmax
     - near-surface 2m height
   * - minimum temperature
     - ``tasmin``
     - K
     - tasmin
     - near-surface 2m height
   * - precipitation
     - ``pr``
     - kg m\ :sup:`-2` s\ :sup:`-1`
     - pr
     - surface level
