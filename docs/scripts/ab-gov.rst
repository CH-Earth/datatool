Alberta Government Climate Dataset (``ab-gov``)
===============================================

Location of Dataset Files
-------------------------

The ``ab-gov`` dataset is located under the following directories
accessible from multiple clusters: 

.. code:: console

   # DRAC Graham HPC location
   /project/rpp-kshook/Climate_Forcing_Data/meteorological-data/ab-gov # rpp-kshook allocation

   # UCalgary ARC HPC location
   /work/comphyd_lab/data/meteorological-data/ab-gov # comphyd_lab allocation

and the structure of the dataset yearly files (containing daily
time-steps) is as following:

.. code:: console

   /path/to/dataset/dir/
   ├── BCC-CSM2-MR
   │   ├── Downscaled_BCC-CSM2-MR_MBCDS_historical_pr_tmn_tmx_1950.nc 
   │   ├── .
   │   ├── .
   │   ├── .
   │   ├── Downscaled_BCC-CSM2-MR_MBCDS_historical_pr_tmn_tmx_2014.nc  
   │   ├── Downscaled_BCC-CSM2-MR_MBCDS_ssp126_pr_tmn_tmx_2015.nc
   │   ├── .
   │   ├── .
   │   ├── .
   │   ├── Downscaled_BCC-CSM2-MR_MBCDS_ssp126_pr_tmn_tmx_2100.nc
   │   ├── Downscaled_BCC-CSM2-MR_MBCDS_ssp370_pr_tmn_tmx_2015.nc
   │   ├── .
   │   ├── .
   │   ├── .
   │   ├── .
   │   └── Downscaled_BCC-CSM2-MR_MBCDS_ssp126_pr_tmn_tmx_2100.nc
   .
   .
   .
   ├── %model
   │   ├── Downscaled_%{model}_MBCDS_historical_pr_tmn_tmx_1950.nc 
   │   ├── .
   │   ├── .
   │   ├── Downscaled_%{model}_MBCDS_historical_pr_tmn_tmx_2014.nc
   │   ├── Downscaled_%{model}_MBCDS_ssp%%%_pr_tmn_tmx_2015.nc
   │   ├── .
   │   ├── .
   │   ├── Downscaled_%{model}_MBCDS_%{scenario}_pr_tmn_tmx_%{year}.nc
   │   ├── .
   │   ├── .
   │   └── Downscaled_%{model}_MBCDS_%{scenario}_pr_tmn_tmx_2100.nc
   .
   .
   .
   └── Hybrid-observation
       ├── Hybrid_Daily_BCABSK_US_pr_1950.nc
       ├── .
       ├── .
       ├── .
       ├── Hybrid_Daily_BCABSK_US_%{var}_%{year}.nc
       ├── .
       ├── .
       ├── .
       └── Hybrid_Daily_BCABSK_US_tmin_2019.nc

``ab-gov`` Climate Models
-------------------------

This dataset offers outputs of various climate models. Table below
summarizes the models and relevant keywords that could be used with the
main ``datatool`` script:

+---+-----------------------------+-------------------------------------+
| # | Model (keyword for          | Scenarios (keyword for              |
|   | ``--model``)                | ``--scenario``)                     |
+===+=============================+=====================================+
| 1 | ``BCC-CSM2-MR``             | ``historical``, ``ssp126``,         |
|   |                             | ``ssp370``                          |
+---+-----------------------------+-------------------------------------+
| 2 | ``CNRM-CM6-1``              | ``historical``, ``ssp126``,         |
|   |                             | ``ssp585``                          |
+---+-----------------------------+-------------------------------------+
| 3 | ``EC-Earth3-Veg``           | ``historical``, ``ssp126``,         |
|   |                             | ``ssp370``                          |
+---+-----------------------------+-------------------------------------+
| 4 | ``GFDL-CM4``                | ``historical``, ``ssp245``          |
+---+-----------------------------+-------------------------------------+
| 5 | ``GFDL-ESM4``               | ``historical``, ``ssp585``          |
+---+-----------------------------+-------------------------------------+
| 6 | ``IPSL-CM6A-LR``            | ``historical``, ``ssp126``,         |
|   |                             | ``ssp370``                          |
+---+-----------------------------+-------------------------------------+
| 7 | ``MRI-ESM2-0``              | ``historical``, ``ssp370``,         |
|   |                             | ``ssp585``                          |
+---+-----------------------------+-------------------------------------+
| 8 | ``Hybrid-observation``      | no keyword necessary                |
+---+-----------------------------+-------------------------------------+

Coordinate Variables, Spatial and Temporal extents, and Time-stamps
-------------------------------------------------------------------

Coordinate Variables
~~~~~~~~~~~~~~~~~~~~

The coordinate variables of the ``ab-gov`` climate dataset files are
``lon`` and ``lat`` representing the longitude and latitude points,
respectively.

Temporal Extents and Time-stamps
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The time-stamps are already included in the original files. The dataset
offers **daily** time-series of climate variables. The following table
describes the temporal extent for senarios included in this dataset:

.. list-table:: Model and Scenario Information
   :header-rows: 1

   * - #
     - Model (keyword for ``--model``)
     - Scenarios (keyword for ``--scenario``)
   * - 1
     - ``BCC-CSM2-MR``
     - ``historical``, ``ssp126``, ``ssp370``
   * - 2
     - ``CNRM-CM6-1``
     - ``historical``, ``ssp126``, ``ssp585``
   * - 3
     - ``EC-Earth3-Veg``
     - ``historical``, ``ssp126``, ``ssp370``
   * - 4
     - ``GFDL-CM4``
     - ``historical``, ``ssp245``
   * - 5
     - ``GFDL-ESM4``
     - ``historical``, ``ssp585``
   * - 6
     - ``IPSL-CM6A-LR``
     - ``historical``, ``ssp126``, ``ssp370``
   * - 7
     - ``MRI-ESM2-0``
     - ``historical``, ``ssp370``, ``ssp585``
   * - 8
     - ``Hybrid-observation``
     - no keyword necessary


.. note::
   Values of the ``Temporal extent`` column are the limits for
   ``--start-date`` and ``--end-date`` options with the main
   ``datatool`` script.

.. note::
   The ``Hybrid-observation`` model does not accept any
   ``--scenario`` values, however, it covers climate date from
   ``1950-01-01`` to ``2020-01-01``.

Dataset Variables
-----------------

The NetCDF files of the dataset contain 3 variables. You may see a list
of variables by using the ``ncdump -h`` command on one of the files:

.. code:: console

   foo@bar:~$ module load gcc
   foo@bar:~$ module load cdo
   foo@bar:~$ ncdump -h /path/to/ab-gov/BCC-CSM2-MR/Downscaled_BCC-CSM2-MR_MBCDS_ssp126_pr_tmn_tmx_2015.nc

Spatial Extent
--------------

The ``ab-gov`` dataset covers the entire Canadian province of Alberta
(AB), in addition to northern parts of British Columbia (BC), western
parts of Saskatchewan (SK), and northern parts of the American State of
Montana (MT).

Short Description on ``ab-gov`` Climate Dataset Variables
---------------------------------------------------------

This dataset only offers three climate variables: 1) daily precipitation
time-series (surface level), 2) daily minimum temperature time-series
(@1.5m, near-surface level), and 3) daily maximum temperature
time-series (@1.5m, near-surface level). Since the frequency of this
dataset is daily, and only offers precipitation and temperature values,
therefore, it could be potentially used for forcing conceptual
hydrological models that only need daily time-series of these variables.

The table below, summarizes the variables offered by this dataset:

.. list-table:: Variable Information
   :header-rows: 1

   * - Variable Name
     - Variable (keyword for ``--variable``)
     - Unit
     - IPCC Abbreviation
     - Comments
   * - maximum temperature
     - ``tmax``
     - °C
     - tasmax
     -
   * - minimum temperature
     - ``tmin``
     - °C
     - tasmin
     -
   * - precipitation
     - ``pr``
     - mm/day
     - pr
     -
