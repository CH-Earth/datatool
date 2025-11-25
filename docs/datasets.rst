.. Copyright 2022-2024 University of Calgary, University of Saskatchewan
   and other datatool developers.

   SPDX-License-Identifier: (GPL-3.0-or-later)

.. _datatool-datasets:

========
Datasets
========
This page details the dataset recipes available with ``datatool``.

-------
Summary
-------
The following table lists available datasets, their DOI, and provides links to sections describing the dataset.

+----+------------------------------+--------------------------------------------------------------------------------------+
| #  | Dataset                      | DOI                                                                                  |
+====+==============================+======================================================================================+
| 1  | GWF-NCAR WRF-CONUS I         | 10.1007/s00382-016-3327-9                                                            |
+----+------------------------------+--------------------------------------------------------------------------------------+
| 2  | GWF-NCAR WRF-CONUS II [#f1]_ | 10.5065/49SN-8E08                                                                    |
+----+------------------------------+--------------------------------------------------------------------------------------+
| 3  | ECMWF ERA5 [#f2]_            | 10.24381/cds.adbb2d47 and `ERA5 preliminary extension <era5_preliminary_extension>`_ |
+----+------------------------------+--------------------------------------------------------------------------------------+
| 4  | ECCC RDRSv2.1                | 10.5194/hess-25-4917-2021                                                            |
+----+------------------------------+--------------------------------------------------------------------------------------+
| 5  | CCRN CanRCM4-WFDEI-GEM-CaPA  | 10.5194/essd-12-629-2020                                                             |
+----+------------------------------+--------------------------------------------------------------------------------------+
| 6  | CCRN WFDEI-GEM-CaPA          | 10.20383/101.0111                                                                    |
+----+------------------------------+--------------------------------------------------------------------------------------+
| 7  | ORNL Daymet [#f3]_           | 10.3334/ORNLDAAC/2129                                                                |
+----+------------------------------+--------------------------------------------------------------------------------------+
| 8  | Alberta Gov Climate Dataset  | 10.5194/hess-23-5151-2019                                                            |
+----+------------------------------+--------------------------------------------------------------------------------------+
| 9  | Ouranos ESPO-G6-R2           | 10.1038/s41597-023-02855-z                                                           |
+----+------------------------------+--------------------------------------------------------------------------------------+
| 10 | Ouranos MRCC5-CMIP6          | 10.5281/zenodo.11061924                                                              |
+----+------------------------------+--------------------------------------------------------------------------------------+
| 11 | NASA NEX-GDDP-CMIP6          | 10.1038/s41597-022-01393-4                                                           |
+----+------------------------------+--------------------------------------------------------------------------------------+
| 12 | ECCC CaSRv3.1 (aka RDRS)     | TBD                                                                                  |
+----+------------------------------+--------------------------------------------------------------------------------------+
| 13 | ECCC CaSRv3.2 (aka RDRS)     | TBD                                                                                  |
+----+------------------------------+--------------------------------------------------------------------------------------+

.. [#f1] For access to the files on the Graham cluster, please contact `Stephen O'Hearn <mailto:sdo124@mail.usask.ca>`_.
.. [#f2] ERA5 data from 1950-1979 are based on `ERA5 preliminary extension <https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels-preliminary-back-extension?tab=overview>`_ and 1979 onwards are based on `ERA5 1979-present <https://doi.org/10.24381/cds.adbb2d47>`_.
.. [#f3] For the Puerto Rico domain of the dataset, data are available from January 1950 until December 2022.

.. _era5_preliminary_extension: https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels-preliminary-back-extension?tab=overview/

---------------------
Detailed Descriptions
---------------------
.. toctree::
   :maxdepth: 2
   :caption: Contents:

   scripts/ab-gov.rst
   scripts/ccrn-canrcm4_wfdei_gem_capa.rst
   scripts/ccrn-wfdei_gem_capa.rst
   scripts/eccc-rdrs.rst
   scripts/eccc-casr31.rst
   scripts/eccc-casr32.rst
   scripts/ecmwf-era5.rst
   scripts/gwf-ncar-conus_i.rst
   scripts/gwf-ncar-conus_ii.rst
   scripts/nasa-nex-gddp-cmip6.rst
   scripts/ornl-daymet.rst
   scripts/ouranos-espo-g6-r2.rst
   scripts/ouranos-mrcc5-cmip6.rst

