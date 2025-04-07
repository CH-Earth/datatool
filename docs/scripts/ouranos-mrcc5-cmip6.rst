Ouranos ``MRCC5-CMIP6`` dataset
===============================

In this file, the details of the dataset is explained.

Location of Dataset Files
-------------------------

The ``MRCC5-CMIP6`` dataset is located under the following directory
accessible on the following locations:

.. code:: console

   # DRAC Graham HPC locations
   # only CanESM5 and MPI-ESM1-2-LR models
   /project/def-alpie-ab/data/meteorological-data/ouranos-mrcc5-cmip6 # def-alpie-ab allocation with DRAC Graham
   # only CNRM-ESM2-1 model
   /project/rpp-kshook/Climate_Forcing_Data/meteorological-data/ouranos-mrcc5-cmip6 # rpp-kshook allocation with DRAC Graham

and the structure of the dataset hourly files is as following:

.. code:: console

   /path/to/dataset/directory/
   ├── MPI-ESM1-2-LR
   │   ├── ssp126
   |   |   └── r1i1p1f1
   │   |       └── CRCM5
   |   |           └── v1-r1
   |   |               └── 1hr
   |   |                   ├── hurs 
   |   |                   |   └── %version_number
   │   |                   |       ├── hurs_NAM-12_MPI-ESM1-2-LR_ssp126_r1i1p1f1_OURANOS_CRCM5_v1-r1_1hr_201501010030-201512312330.nc
   |   |                   |       ├── hurs_NAM-12_MPI-ESM1-2-LR_ssp126_r1i1p1f1_OURANOS_CRCM5_v1-r1_1hr_201601010030-201612312330.nc
   |   |                   |       ├── .
   |   |                   |       ├── .
   |   |                   |       ├── .
   |   |                   |       ├── hurs_NAM-12_MPI-ESM1-2-LR_ssp126_r1i1p1f1_OURANOS_CRCM5_v1-r1_1hr_209901010030-209912312330.nc
   |   |                   |       └── hurs_NAM-12_MPI-ESM1-2-LR_ssp126_r1i1p1f1_OURANOS_CRCM5_v1-r1_1hr_210001010030-210012312330.nc
   │   |                   ├── %variable
   |   |                   |   └── %version_number
   |   |                   |       ├── %variable_NAM-12_MPI-ESM1-2-LR_ssp126_r1i1p1f1_OURANOS_CRCM5_v1-r1_1hr_201501010030-201512312330.nc
   |   |                   |       ├── . 
   |   |                   |       ├── . 
   |   |                   |       ├── . 
   |   |                   |       └── %variable_NAM-12_MPI-ESM1-2-LR_ssp126_r1i1p1f1_OURANOS_CRCM5_v1-r1_1hr_210001010030-210012312330.nc
   |   |                   └── vas
   |   |                       └── %version_number
   |   |                           ├── vas_NAM-12_MPI-ESM1-2-LR_ssp126_r1i1p1f1_OURANOS_CRCM5_v1-r1_1hr_201501010000-201512312300.nc
   |   |                           ├── vas_NAM-12_MPI-ESM1-2-LR_ssp126_r1i1p1f1_OURANOS_CRCM5_v1-r1_1hr_201601010000-201612312300.nc
   |   |                           ├── .
   |   |                           ├── .
   |   |                           ├── .
   |   |                           ├── vas_NAM-12_MPI-ESM1-2-LR_ssp126_r1i1p1f1_OURANOS_CRCM5_v1-r1_1hr_209901010000-209912312300.nc
   |   |                           └── vas_NAM-12_MPI-ESM1-2-LR_ssp126_r1i1p1f1_OURANOS_CRCM5_v1-r1_1hr_210001010000-210012312300.nc
   │   ├── ssp370
   .   .   .
   .   .   .
   .   .   .
   ├── %{model}
   |   ├── %{scenario}
   |   |   ├── %{ensemble}
   |   |   |   └── CRCM5
   |   |   |       └── v1-r1
   |   |   |           └── 1hr
   |   |   |               ├── %{var}
   |   |                   |   └── %version_number
   |   |   |               |       ├── %variable_NAM-12_%model_%scenario_%ensemble_OURANOS_CRCM5_v1-r1_1hr_201501010030-201512312330.nc
   |   |   |               |       ├── .
   |   |   |               |       ├── .
   |   |   |               |       ├── .
   |   |   |               |       └── %variable_NAM-12_%model_%scenario_%ensemble_OURANOS_CRCM5_v1-r1_1hr_210001010030-210012312330.nc
   .   .   .               .
   .   .   .               .
   .   .   .               .

..

   [!important] Not all models have the same number of scenarios,
   enesmble members, and variables. Each individual model needs to be
   investigated individually. However, ``datatool`` can ignore invalid
   choices automatically upon job submission.

Coordinate Variables and Time-stamps
------------------------------------

Coordinate Variables
~~~~~~~~~~~~~~~~~~~~

The coordinate variables for this dataset are ``rlon`` and ``rlat``
representing the longitude and latitude points, respectively. ###
Time-stamps The time-stamps are included in the original files.

``MRCC5-CMIP6`` Climate Models
------------------------------

This dataset offers downscaled outputs of various climate models. Table
below summarizes the models and relevant keywords that could be used
with the main ``datatool`` script:

+---+------------------------+------------------------------------------+
| # | Model (keyword for     | Scenarios (keyword for ``--scenario``)   |
|   | ``--model``)           |                                          |
+===+========================+==========================================+
| 1 | ``CanESM5``            | ``historical``, ``ssp126``, ``ssp245``,  |
|   |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 2 | ``MPI-ESM1-2-LR``      | ``historical``, ``ssp126``, ``ssp245``,  |
|   |                        | ``ssp370``, ``ssp585``                   |
+---+------------------------+------------------------------------------+
| 3 | ``CNRM-ESM2-1``        | ``historical``, ``ssp126``, ``ssp245``,  |
|   |                        | ``ssp370``                               |
+---+------------------------+------------------------------------------+

``MRCC5-CMIP6`` Climate Models’ Ensemble Members
------------------------------------------------

This dataset offers downscaled outputs of various climate models. Table
below summarizes the dataset ensemble members for each climate model:

+---+------------------------+------------------------------------------+
| # | Model (keyword for     | Ensemble Member(s) (keyword for          |
|   | ``--model``)           | ``--ensemble``)                          |
+===+========================+==========================================+
| 1 | ``CanESM5``            | ``r1i1p1f1`` and ``r1i1p2f1``            |
+---+------------------------+------------------------------------------+
| 2 | ``MPI-ESM1-2-LR``      | ``r1i1p1f1`` and ``r1i1p2f1``            |
+---+------------------------+------------------------------------------+
| 3 | ``CNRM-ESM2-1``        | ``r1i1p1f2``                             |
+---+------------------------+------------------------------------------+

Dataset Variables
-----------------

The NetCDF files of the dataset contain various variables. You may see a
list of variables by browsing the dataset’s directory:

.. code:: console

   foo@bar:~$ ls /path/to/dataset/dir/CanESM5/ssp126/r1i1p2f1/CRCM5/v1-r1/1hr/
   hurs  huss  pr  ps  rlds  rsds  tas  uas  vas

Spatial Extent
--------------

The spatial extent of the ``MRCC5-CMIP6`` is on latitutes from ``+6.33``
to ``+82.84`` and longitudes from ``-179.99`` to ``179.99`` covering
North America. The resolution is 0.11 degrees (~10km).

Temporal Extent
---------------

The time-stamps are already included in the original files. The dataset
offers **hourly** time-series of climate variables. The following table
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
     - ``ssp245``
     - ``2015-01-01`` to ``2100-12-31``
   * - 3
     - ``ssp370``
     - ``2015-01-01`` to ``2100-12-31``
   * - 4
     - ``ssp585``
     - ``2015-01-01`` to ``2100-12-31``
   * - 5
     - ``ssp585``
     - ``2015-01-01`` to ``2100-12-31``


.. note::
  Values of the ``Temporal extent`` column are the limits for
  ``--start-date`` and ``--end-date`` options with the main
  ``datatool`` script.

.. note::
   ``CanESM5`` model reports all variables at the beginning of
   the hour ``(YYYY-mm-ddTHH:00:00)``.

.. note::
   ``MPI-ESM1-2-LR`` and ``CNRM-ESM2-1`` report ``pr``, ``rlds``,
   ``rsds`` at the middle of the hour (YYYY-mm-ddTHH:30:00), while
   all other variables are reported at the top of the hour.


Calendar
--------
+--------------------------+-------------------+
| Model                    | Calendar Type     |
+==========================+===================+
| ``MPI-ESM1-2-LR``        | standard          |
+--------------------------+-------------------+
| ``CNRM-ESM2-1``          | standard          |
+--------------------------+-------------------+
| ``CanESM5``              | 365_day           |
+--------------------------+-------------------+


Short Description on ``MRCC5-CMIP6`` Variables
----------------------------------------------

This dataset only offers seven climate variables: 1) hourly
precipitation time-series (surface level), 2) hourly temperature
time-series (@2m, near-surface level), 3) hourly specific humidity
time-series (@2m, near-surface level), 4) hourly surface pressue
time-series (surface level), 5) hourly wind speed (@10m, near-surface
level), 6) hourly shortwave radiation (surface level), and 7) hourly
longwave radiation (surface level).

The table below, summarizes the variables offered by this dataset:

.. list-table:: Variable Information
   :header-rows: 1

   * - Variable Name
     - Variable (keyword for ``--variable``)
     - Unit
     - IPCC Abbreviation
     - Comments
   * - specific humidity
     - ``huss``
     - 1
     -
     - @2 meters above surface
   * - precipitation
     - ``pr``
     - kg m\ :sup:`-2` s\ :sup:`-1`
     -
     - surface level
   * - surface air pressure
     - ``ps``
     - Pa
     -
     - surface level
   * - longwave radiation
     - ``rlds``
     - W m\ :sup:`-2`
     -
     - surface level
   * - shortwave radiation
     - ``rsds``
     - W m\ :sup:`-2`
     -
     - surface level
   * - air temperature
     - ``tas``
     - K
     -
     - @2 meters above surface
   * - wind speed (eastward)
     - ``uas``
     - m s\ :sup:`-1`
     -
     - eastward wind speed @10 meters above surface
   * - wind speed (northward)
     - ``vas``
     - m s\ :sup:`-1`
     -
     - northward wind speed @10 meters above surface
