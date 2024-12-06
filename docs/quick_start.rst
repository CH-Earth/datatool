.. Copyright 2022-2024 University of Calgary, University of Saskatchewan
   and other datatool Developers.

   SPDX-License-Identifier: (GPL-3.0-or-later)

.. _main-datatool:

===========
Quick Start
===========

-----------
Example Run
-----------
As an example, follow the code block below. Please remember that you MUST
have access to the RDRSv2.1 model outputs on your HPC of interest. Enter
the following codes in your ``bash`` shell as a test case:

.. code:: console

   foo@bar:~$ git clone https://github.com/kasra-keshavarz/datatool.git # clone the repository
   foo@bar:~$ cd ./datatool/ # move to the repository's directory
   foo@bar:~$ ./extract-dataset.sh -h # view the usage message
   foo@bar:~$ ./extract-dataset.sh  \
     --dataset="rdrs" \
     --dataset-dir="/project/rpp-kshook/Climate_Forcing_Data/meteorological-data/rdrsv2.1" \
     --output-dir="$HOME/scratch/rdrs_outputs/" \
     --start-date="2001-01-01T00:00:00" \
     --end-date="2001-12-31T23:00:00" \
     --lat-lims="49,51"  \
     --lon-lims="-117,-115" \
     --variable="RDRS_v2.1_A_PR0_SFC,RDRS_v2.1_P_HU_09944" \
     --cache="$HOME/.cache/"" \
     --cluster="./etc/clusters/drac-graham.json" \
     --prefix="testing_";

The test case above is assumed to be run on the ``Digital Research Alliance of
Canada``'s Graham cluster. Nevertheless, the test case can run on any cluster
where the data are available. View the details of the
`JSON configuration file <json>`_ to configure the tool for various HPCs.

There are a few examples available in the
`examples <https://github.com/CH-Earth/datatool/tree/main/examples>`_ directory of the repository.

----
Logs
----
The datasets logs are generated under the ``$HOME/.datatool`` directory, only
in cases where jobs are submitted to clusters' schedulers. If processing is
not submitted as a job, then the logs are printed on screen (i.e., ``stdout``).


-------
Support
-------
Please open a new ticket on the `Issues <https://github.com/CH-Earth/datatool/issues>`_
tab of this repository for support.
