NASA NEX-GDDP-CMIP6 Climate Dataset (``nex-gddp-cmip6``)
========================================================

In this file, the details of the dataset is explained.

Location of Dataset Files
-------------------------

The ``nex-gddp-cmip6`` dataset is located under the following
directory(s) accessible from Compute Canada (CC) Graham Cluster:

.. code:: console

   /project/rrg-mclark/data/meteorological-data/nasa-nex-gddp-cmip6/NEX-GDDP-CMIP6 # rrg-mclark allocation

and the structure of the dataset’s yearly files (containing daily
time-steps) is as following:

.. code:: console

   /project/rrg-mclark/data/meteorological-data/nasa-nex-gddp-cmip6/NEX-GDDP-CMIP6/
   ├── ACCESS-CM2
   │   ├── historical
   │   │   └── r1i1p1f1
   │   │       ├── hurs
   │   │       │   ├── hurs_day_ACCESS-CM2_historical_r1i1p1f1_gn_1950.nc
   |   |       |   ├── hurs_day_ACCESS-CM2_historical_r1i1p1f1_gn_1950_v1.1.nc
   │   │       │   ├── hurs_day_ACCESS-CM2_historical_r1i1p1f1_gn_1951.nc
   │   │       │   ├── hurs_day_ACCESS-CM2_historical_r1i1p1f1_gn_1951_v1.1.nc
   │   │       │   ├── .
   │   │       │   ├── .
   │   │       │   ├── .
   │   |       │   ├── hurs_day_ACCESS-CM2_historical_r1i1p1f1_gn_2014.nc
   │   |       │   └── hurs_day_ACCESS-CM2_historical_r1i1p1f1_gn_2014_v1.1.nc
   │   |       ├── huss
   │   |       |   ├── huss_day_ACCESS-CM2_historical_r1i1p1f1_gn_1950.nc
   │   |       |   ├── huss_day_ACCESS-CM2_historical_r1i1p1f1_gn_1951.nc
   |   |       |   ├── huss_day_ACCESS-CM2_historical_r1i1p1f1_gn_1952.nc
   |   |       |   ├── .
   |   |       |   ├── .
   |   |       |   ├── .
   |   |       |   ├── huss_day_ACCESS-CM2_historical_r1i1p1f1_gn_2013.nc
   |   |       |   └── huss_day_ACCESS-CM2_historical_r1i1p1f1_gn_2014.nc
   |   |       ├── pr
   │   |       |   ├── pr_day_ACCESS-CM2_historical_r1i1p1f1_gn_1950.nc
   │   |       |   ├── pr_day_ACCESS-CM2_historical_r1i1p1f1_gn_1951.nc
   |   |       |   ├── pr_day_ACCESS-CM2_historical_r1i1p1f1_gn_1952.nc
   |   |       |   ├── .
   |   |       |   ├── .
   |   |       |   ├── .
   |   |       |   ├── pr_day_ACCESS-CM2_historical_r1i1p1f1_gn_2013.nc
   |   |       |   └── pr_day_ACCESS-CM2_historical_r1i1p1f1_gn_2014.nc
   |   |       ├── rlds
   │   |       |   ├── rlds_day_ACCESS-CM2_historical_r1i1p1f1_gn_1950.nc
   │   |       |   ├── rlds_day_ACCESS-CM2_historical_r1i1p1f1_gn_1951.nc
   |   |       |   ├── rlds_day_ACCESS-CM2_historical_r1i1p1f1_gn_1952.nc
   |   |       |   ├── .
   |   |       |   ├── .
   |   |       |   ├── .
   |   |       |   ├── rlds_day_ACCESS-CM2_historical_r1i1p1f1_gn_2013.nc
   |   |       |   └── rlds_day_ACCESS-CM2_historical_r1i1p1f1_gn_2014.nc
   |   |       ├── rsds
   │   |       |   ├── rsds_day_ACCESS-CM2_historical_r1i1p1f1_gn_1950.nc
   │   |       |   ├── rsds_day_ACCESS-CM2_historical_r1i1p1f1_gn_1951.nc
   |   |       |   ├── rsds_day_ACCESS-CM2_historical_r1i1p1f1_gn_1952.nc
   |   |       |   ├── .
   |   |       |   ├── .
   |   |       |   ├── .
   |   |       |   ├── rsds_day_ACCESS-CM2_historical_r1i1p1f1_gn_2013.nc
   |   |       |   └── rsds_day_ACCESS-CM2_historical_r1i1p1f1_gn_2014.nc
   |   |       ├── tas
   │   |       |   ├── tas_day_ACCESS-CM2_historical_r1i1p1f1_gn_1950.nc
   │   |       |   ├── tas_day_ACCESS-CM2_historical_r1i1p1f1_gn_1951.nc
   |   |       |   ├── tas_day_ACCESS-CM2_historical_r1i1p1f1_gn_1952.nc
   |   |       |   ├── . 
   |   |       |   ├── . 
   |   |       |   ├── . 
   |   |       |   ├── tas_day_ACCESS-CM2_historical_r1i1p1f1_gn_2013.nc
   |   |       |   └── tas_day_ACCESS-CM2_historical_r1i1p1f1_gn_2014.nc
   |   |       ├── tasmax
   │   |       |   ├── tasmax_day_ACCESS-CM2_historical_r1i1p1f1_gn_1950.nc
   │   |       |   ├── tasmax_day_ACCESS-CM2_historical_r1i1p1f1_gn_1951.nc
   |   |       |   ├── tasmax_day_ACCESS-CM2_historical_r1i1p1f1_gn_1952.nc
   |   |       |   ├── . 
   |   |       |   ├── . 
   |   |       |   ├── . 
   |   |       |   ├── tasmax_day_ACCESS-CM2_historical_r1i1p1f1_gn_2013.nc
   |   |       |   └── tasmax_day_ACCESS-CM2_historical_r1i1p1f1_gn_2014.nc
   |   |       └── tasmin
   │   |           ├── tasmin_day_ACCESS-CM2_historical_r1i1p1f1_gn_1950.nc
   │   |           ├── tasmin_day_ACCESS-CM2_historical_r1i1p1f1_gn_1951.nc
   |   |           ├── tasmin_day_ACCESS-CM2_historical_r1i1p1f1_gn_1952.nc
   |   |           ├── .
   |   |           ├── .
   |   |           ├── .
   |   |           ├── tasmin_day_ACCESS-CM2_historical_r1i1p1f1_gn_2013.nc
   |   |           └── tasmin_day_ACCESS-CM2_historical_r1i1p1f1_gn_2014.nc
   │   ├── ssp126 
   │   |   └── r1i1p1f1
   │   |       ├── hurs
   │   |       |   ├── hurs_day_ACCESS-CM2_ssp126_r1i1p1f1_gn_2015.nc
   │   |       |   ├── hurs_day_ACCESS-CM2_ssp126_r1i1p1f1_gn_2015_v1.1.nc
   │   |       |   ├── .
   │   |       |   ├── .
   │   |       |   ├── .
   │   |       |   ├── hurs_day_ACCESS-CM2_ssp126_r1i1p1f1_gn_2100.nc
   │   |       |   └── hurs_day_ACCESS-CM2_ssp126_r1i1p1f1_gn_2100_v1.1.nc
   |   |       .
   |   |       .
   |   |       .
   |   |       └── tasmin
   |   |           ├── tasmin_day_ACCESS-CM2_ssp126_r1i1p1f1_gn_2015.nc
   |   |           ├── tasmin_day_ACCESS-CM2_ssp126_r1i1p1f1_gn_2016.nc
   |   |           ├── .
   |   |           ├── .
   |   |           ├── .
   |   |           └── tasmin_day_ACCESS-CM2_ssp126_r1i1p1f1_gn_2100.nc
   |   .
   |   .
   |   .
   |   ├── %{scenario}
   |       ├── %{ensemble}
   |   .   .   ├── %{var}
   |   .   .   .   ├── %{var}_day_ACCESS-CM2_%{scenario}_%{ensemble}_gn_%{year}%{version}.nc
   |   .   .   .   .
   |   .   .   .   .
   |   .   .   .   .
   |   └── ssp585 
   │       └── r1i1p1f1
   │           ├── hurs
   │           |   ├── hurs_day_ACCESS-CM2_ssp126_r1i1p1f1_gn_2015.nc
   │           |   ├── .
   │           |   ├── .
   │           |   ├── .
   │           |   └── hurs_day_ACCESS-CM2_ssp126_r1i1p1f1_gn_2100.nc
   |           .
   |           .
   |           .
   |           └── tasmin
   |               ├── tasmin_day_ACCESS-CM2_ssp126_r1i1p1f1_gn_2015.nc
   |               ├── .
   |               ├── .
   |               ├── .
   |               └── tasmin_day_ACCESS-CM2_ssp126_r1i1p1f1_gn_2100.nc
   .
   .   .
   .   .
   ├── %{model}
   .   ├── %{scenario}
   .   .   └── %{ensemble}
   .   .       ├── %{var}
   .   .       .   ├── %{var}_day_%{model}_%{scenario}_%{ensemble}_gn_%{year}%{version}.nc
   .   .       .   .
   .   .       .   .
   .   .       .   .
   └── UKESM1-0-LL
       ├── historical
       |   └── r1i1p1f2
       |       ├── hurs
       |       |   ├── hurs_day_UKESM1-0-LL_historical_r1i1p1f2_gn_1950.nc
       |       |   ├── hurs_day_UKESM1-0-LL_historical_r1i1p1f2_gn_1950_v1.1.nc
       |       |   ├── . 
       |       |   ├── . 
       |       |   ├── . 
       |       |   ├── hurs_day_UKESM1-0-LL_historical_r1i1p1f2_gn_2014.nc
       |       |   └── hurs_day_UKESM1-0-LL_historical_r1i1p1f2_gn_2014_v1.1.nc
       |       .   .
       |       .   .
       |       .   .
       |       └── tasmin
       |           .
       |           .
       |           └── tasmin_day_UKESM1-0-LL_historical_r1i1p1f2_gn_2014.nc
       .
       .
       .
       └── ssp585
           └── r1i1p1f2
               ├── hurs
               |   ├── hurs_day_UKESM1-0-LL_ssp585_r1i1p1f2_gn_2015.nc
               |   ├── . 
               |   ├── . 
               |   ├── . 
               |   └── hurs_day_UKESM1-0-LL_ssp585_r1i1p1f2_gn_2100.nc
               .
               .
               .
               └── tasmin
                   ├── tasmin_day_UKESM1-0-LL_ssp585_r1i1p1f2_gn_2015.nc
                   .
                   .
                   .
                   └── tasmin_day_UKESM1-0-LL_ssp585_r1i1p1f2_gn_2100.nc

..

   [!important] Not all models have the same number of scenarios,
   enesmble members, and variables. Each individual model needs to be
   investigate individually.

   [!caution] Currently, ``datatool`` is NOT capable of identifying
   various versions of dataset files. In this dataset, as can be
   observed files for ``v1.1`` (those indicated with a ``_v1.1_`` in
   their file names) are ignored. This will be addressed in the future
   versions.

``nex-gddp-cmip6`` Climate Models
---------------------------------

This dataset offers downscaled outputs of various climate models. Table
below summarizes the models and relevant keywords that could be used
with the main ``datatool`` script:

+---+------------------------+------------------------------------------+
| # | Model (keyword for     | Scenarios (keyword for ``--scenario``)   |
|   | ``--model``)           |                                          |
+===+========================+==========================================+
| 1 | ``ACCESS-CM2``         | ``historical``, ``ssp126``, ``ssp245``,  |
|   |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 2 | ``ACCESS-ESM1-5``      | ``historical``, ``ssp126``, ``ssp245``,  |
|   |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 3 | ``BCC-CSM2-MR``        | ``historical``, ``ssp126``, ``ssp245``,  |
|   |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 4 | ``CanESM5``            | ``historical``, ``ssp126``, ``ssp245``,  |
|   |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 5 | ``CESM2``              | ``historical``, ``ssp126``, ``ssp245``,  |
|   |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 6 | ``CESM2-WACCM``        | ``historical``, ``ssp245``, ``ssp585``   |
+---+------------------------+------------------------------------------+
| 7 | ``CMCC-CM2-SR5``       | ``historical``, ``ssp126``, ``ssp245``,  |
|   |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 8 | ``CMCC-ESM2``          | ``historical``, ``ssp126``, ``ssp245``,  |
|   |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 9 | ``CNRM-CM6-1``         | ``historical``, ``ssp126``, ``ssp245``,  |
|   |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 1 | ``CNRM-ESM2-1``        | ``historical``, ``ssp126``, ``ssp245``,  |
| 0 |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 1 | ``EC-Earth3``          | ``historical``, ``ssp126``, ``ssp245``,  |
| 1 |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 1 | ``EC-Earth3-Veg-LR``   | ``historical``, ``ssp126``, ``ssp245``,  |
| 2 |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 1 | ``FGOALS-g3``          | ``historical``, ``ssp126``, ``ssp245``,  |
| 3 |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 1 | ``GFDL-CM4``           | ``historical``, ``ssp245``, ``ssp585``   |
| 4 |                        |                                          |
+---+------------------------+------------------------------------------+
| 1 | ``GFDL-CM4_gr2``       | ``historical``, ``ssp245``, ``ssp585``   |
| 5 |                        |                                          |
+---+------------------------+------------------------------------------+
| 1 | ``GFDL-ESM4``          | ``historical``, ``ssp126``, ``ssp245``,  |
| 6 |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 1 | ``GISS-E2-1-G``        | ``historical``, ``ssp126``, ``ssp245``,  |
| 7 |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 1 | ``HadGEM3-GC31-LL``    | ``historical``, ``ssp126``, ``ssp245``,  |
| 8 |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 1 | ``HadGEM3-GC31-MM``    | ``historical``, ``ssp126``, ``ssp245``,  |
| 9 |                        | ``ssp585``                               |
+---+------------------------+------------------------------------------+
| 2 | ``IITM-ESM``           | ``historical``, ``ssp126``, ``ssp585``   |
| 0 |                        |                                          |
+---+------------------------+------------------------------------------+
| 2 | ``INM-CM4-8``          | ``historical``, ``ssp126``, ``ssp245``,  |
| 1 |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 2 | ``INM-CM5-0``          | ``historical``, ``ssp126``, ``ssp245``,  |
| 2 |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 2 | ``IPSL-CM6A-LR``       | ``historical``, ``ssp126``, ``ssp245``,  |
| 3 |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 2 | ``KACE-1-0-G``         | ``historical``, ``ssp126``, ``ssp245``,  |
| 4 |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 2 | ``KIOST-ESM``          | ``historical``, ``ssp126``, ``ssp245``,  |
| 5 |                        | ``ssp585``                               |
+---+------------------------+------------------------------------------+
| 2 | ``MIROC6``             | ``historical``, ``ssp126``, ``ssp245``,  |
| 6 |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 2 | ``MIROC-ES2L``         | ``historical``, ``ssp126``, ``ssp245``,  |
| 7 |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 2 | ``MPI-ESM1-2-HR``      | ``historical``, ``ssp126``, ``ssp245``,  |
| 8 |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 2 | ``MPI-ESM1-2-LR``      | ``historical``, ``ssp126``, ``ssp245``,  |
| 9 |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 3 | ``MRI-ESM2-0``         | ``historical``, ``ssp126``, ``ssp245``,  |
| 0 |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 3 | ``NESM3``              | ``historical``, ``ssp126``, ``ssp245``,  |
| 1 |                        | ``ssp585``                               |
+---+------------------------+------------------------------------------+
| 3 | ``NorESM2-LM``         | ``historical``, ``ssp126``, ``ssp245``,  |
| 2 |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 3 | ``NorESM2-MM``         | ``historical``, ``ssp126``, ``ssp245``,  |
| 3 |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 3 | ``TaiESM1``            | ``historical``, ``ssp126``, ``ssp245``,  |
| 4 |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 3 | ``UKESM1-0-LL``        | ``historical``, ``ssp126``, ``ssp245``,  |
| 5 |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+

``nex-gddp-cmip6`` Climate Models’ Ensemble Members
---------------------------------------------------

This dataset offers downscaled outputs of various climate models. Table
below summarizes the dataset ensemble members for each climate model:

+---+------------------------+------------------------------------------+
| # | Model (keyword for     | Ensemble Member(s) (keyword for          |
|   | ``--model``)           | ``--ensemble``)                          |
+===+========================+==========================================+
| 1 | ``ACCESS-CM2``         | ``r1i1p1f1``                             |
+---+------------------------+------------------------------------------+
| 2 | ``ACCESS-ESM1-5``      | ``r1i1p1f1``                             |
+---+------------------------+------------------------------------------+
| 3 | ``BCC-CSM2-MR``        | ``r1i1p1f1``                             |
+---+------------------------+------------------------------------------+
| 4 | ``CanESM5``            | ``r1i1p1f1``                             |
+---+------------------------+------------------------------------------+
| 5 | ``CESM2``              | ``r4i1p1f1``                             |
+---+------------------------+------------------------------------------+
| 6 | ``CESM2-WACCM``        | ``r3i1p1f1``                             |
+---+------------------------+------------------------------------------+
| 7 | ``CMCC-CM2-SR5``       | ``r1i1p1f1``                             |
+---+------------------------+------------------------------------------+
| 8 | ``CMCC-ESM2``          | ``r1i1p1f1``                             |
+---+------------------------+------------------------------------------+
| 9 | ``CNRM-CM6-1``         | ``r1i1p1f2``                             |
+---+------------------------+------------------------------------------+
| 1 | ``CNRM-ESM2-1``        | ``r1i1p1f2``                             |
| 0 |                        |                                          |
+---+------------------------+------------------------------------------+
| 1 | ``EC-Earth3``          | ``r1i1p1f1``                             |
| 1 |                        |                                          |
+---+------------------------+------------------------------------------+
| 1 | ``EC-Earth3-Veg-LR``   | ``r1i1p1f1``                             |
| 2 |                        |                                          |
+---+------------------------+------------------------------------------+
| 1 | ``FGOALS-g3``          | ``r3i1p1f1``                             |
| 3 |                        |                                          |
+---+------------------------+------------------------------------------+
| 1 | ``GFDL-CM4``           | ``r1i1p1f1``                             |
| 4 |                        |                                          |
+---+------------------------+------------------------------------------+
| 1 | ``GFDL-CM4_gr2``       | ``r1i1p1f1``                             |
| 5 |                        |                                          |
+---+------------------------+------------------------------------------+
| 1 | ``GFDL-ESM4``          | ``r1i1p1f1``                             |
| 6 |                        |                                          |
+---+------------------------+------------------------------------------+
| 1 | ``GISS-E2-1-G``        | ``r1i1p1f2``                             |
| 7 |                        |                                          |
+---+------------------------+------------------------------------------+
| 1 | ``HadGEM3-GC31-LL``    | ``r1i1p1f3``                             |
| 8 |                        |                                          |
+---+------------------------+------------------------------------------+
| 1 | ``HadGEM3-GC31-MM``    | ``r1i1p1f3``                             |
| 9 |                        |                                          |
+---+------------------------+------------------------------------------+
| 2 | ``IITM-ESM``           | ``r1i1p1f1``                             |
| 0 |                        |                                          |
+---+------------------------+------------------------------------------+
| 2 | ``INM-CM4-8``          | ``r1i1p1f1``                             |
| 1 |                        |                                          |
+---+------------------------+------------------------------------------+
| 2 | ``INM-CM5-0``          | ``r1i1p1f1``                             |
| 2 |                        |                                          |
+---+------------------------+------------------------------------------+
| 2 | ``IPSL-CM6A-LR``       | ``r1i1p1f1``                             |
| 3 |                        |                                          |
+---+------------------------+------------------------------------------+
| 2 | ``KACE-1-0-G``         | ``r1i1p1f1``                             |
| 4 |                        |                                          |
+---+------------------------+------------------------------------------+
| 2 | ``KIOST-ESM``          | ``r1i1p1f1``                             |
| 5 |                        |                                          |
+---+------------------------+------------------------------------------+
| 2 | ``MIROC6``             | ``r1i1p1f1``                             |
| 6 |                        |                                          |
+---+------------------------+------------------------------------------+
| 2 | ``MIROC-ES2L``         | ``r1i1p1f2``                             |
| 7 |                        |                                          |
+---+------------------------+------------------------------------------+
| 2 | ``MPI-ESM1-2-HR``      | ``r1i1p1f1``                             |
| 8 |                        |                                          |
+---+------------------------+------------------------------------------+
| 2 | ``MPI-ESM1-2-LR``      | ``r1i1p1f1``                             |
| 9 |                        |                                          |
+---+------------------------+------------------------------------------+
| 3 | ``MRI-ESM2-0``         | ``r1i1p1f1``                             |
| 0 |                        |                                          |
+---+------------------------+------------------------------------------+
| 3 | ``NESM3``              | ``r1i1p1f1``                             |
| 1 |                        |                                          |
+---+------------------------+------------------------------------------+
| 3 | ``NorESM2-LM``         | ``r1i1p1f1``                             |
| 2 |                        |                                          |
+---+------------------------+------------------------------------------+
| 3 | ``NorESM2-MM``         | ``r1i1p1f1``                             |
| 3 |                        |                                          |
+---+------------------------+------------------------------------------+
| 3 | ``TaiESM1``            | ``r1i1p1f1``                             |
| 4 |                        |                                          |
+---+------------------------+------------------------------------------+
| 3 | ``UKESM1-0-LL``        | ``r1i1p1f2``                             |
| 5 |                        |                                          |
+---+------------------------+------------------------------------------+

Coordinate Variables, Spatial and Temporal extents, and Time-stamps
-------------------------------------------------------------------

Coordinate Variables
~~~~~~~~~~~~~~~~~~~~

The coordinate variables of the ``nex-gddp-cmip6`` climate dataset files
are ``rlon`` and ``rlat`` representing the longitude and latitude
points, respectively.

Temporal Extents and Time-stamps
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The time-stamps are already included in the original files. The dataset
offers **daily** time-series of climate variables. The following table
describes the temporal extent for senarios included in this dataset:

.. list-table::
   :header-rows: 1

   * - #
     - Scenarios (keyword for ``--scenario``)
     - Temporal extent
   * - 1
     - ``historical``
     - ``1950-01-01`` to ``2014-12-31``
   * - 2
     - ``ssp126``
     - ``2015-01-01`` to ``2100-12-31``
   * - 3
     - ``ssp245``
     - ``2015-01-01`` to ``2100-12-31``
   * - 4
     - ``ssp370``
     - ``2015-01-01`` to ``2100-12-31``
   * - 5
     - ``ssp585``
     - ``2015-01-01`` to ``2100-12-31``


.. note::
   Values of the ``Temporal extent`` column are the limits for
   ``--start-date`` and ``--end-date`` options with the main
   ``datatool`` script.

Dataset Variables
-----------------

The NetCDF files of the dataset contain various variables. You may see a
list of variables by browsing the dataset’s directory:

.. code:: console

   foo@bar:~$ ls /project/rrg-mclark/data/meteorological-data/nasa-nex-gddp-cmip6/NEX-GDDP-CMIP6/ACCESS-CM2/ssp126/r1i1p1f1/
   hurs  huss  pr  rlds  rsds  sfcWind  tas  tasmax  tasmin

Spatial Extent
--------------

The ``nex-gddp-cmip6`` dataset spatial extent is global.

Short Description on ``nex-gddp-cmip6`` Climate Dataset Variables
-----------------------------------------------------------------

This dataset offers 9 climate variables: 1) precipitation, 2) mean air
temperature, 3) daily maximum temperature, 4) daily minimum temperature,
5) specific humidity, 6) relative humidity, 7) shortwave radiation, 8)
longwave radiation, and 9) wind speed.

Since the frequency of this dataset is daily, including daily
time-series of precipitation and air temperature, it could be
potentially used for forcing conceptual hydrological models that only
need daily time-series of these variables.

Furthermore, with common existing disaggregation methods existing in the
literature, one can generate sub-daily time-series of each variable and
use them for forcing physically based models that may need more climate
variables as their forcing data.

The table below, summarizes the variables offered by this dataset:

.. list-table::
   :header-rows: 1

   * - Variable Name
     - Variable (keyword for ``--variable``)
     - Unit
     - IPCC Abbreviation
     - Comments
   * - maximum temperature@2m
     - ``tasmax``
     - K
     - tasmax
     - near-surface 2m level
   * - minimum temperature@2m
     - ``tasmin``
     - K
     - tasmin
     - near-surface 2m level
   * - precipitation
     - ``pr``
     - mm/day
     - pr
     - surface level
   * - relative humidity
     - ``hurs``
     - %
     - hurs
     - near-surface level
   * - specific humidity
     - ``huss``
     - 1
     - huss
     - near-surface 2m level
   * - longwave radiation
     - ``rlds``
     - W/m^2
     - rlds
     - surface level
   * - shortwave radiation
     - ``rsds``
     - W/m^2
     - rsds
     - surface level
   * - wind speed@10m
     - ``sfcWind``
     - m/s
     - (N/A)
     - near-surface 10m level
   * - mean air temperature@2m
     - ``tas``
     - K
     - tas
     - near-surface 2m level


For the most up-to-date information please visit `NASA’s NEX-GDDP-CMIP6
project
website <https://www.nccs.nasa.gov/services/data-collections/land-based-products/nex-gddp-cmip6>`__.
