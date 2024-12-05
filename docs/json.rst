JSON Configuration File for HPC Module Systems
==============================================
This JSON file provides the configuration specifications for running ``datatool``
on any High-Performance Computing (HPC) system. It primarily describes the
scheduler, "unit" job specifications, and module systems required for successful
execution of the subset extraction process.

General View
------------
Below is an example of the ``JSON`` file that can be fed to ``datatool``
using the ``--cluster`` option.

.. code-block:: json

    {
        "scheduler": "slurm",
        "specs": {
            "cpus": 1,
            "time": "04:00:00",
            "nodes": 1,
            "partition": "cpu2023",
            "account": "",
            "mem": "8000M"
        },
        "modules": {
            "init": [
                ". /work/comphyd_lab/local/modules/spack/2024v5/lmod-init-bash",
                "module unuse $MODULEPATH",
                "module use /work/comphyd_lab/local/modules/spack/2024v5/modules/linux-rocky8-x86_64/Core/",
                "module -q purge"
            ],
            "stdenv": "",
            "compiler": "module -q load gcc/14.2.0",
            "mpi": "module -q load mpi-serial/2.5.0",
            "gdal": "module -q load gdal/3.9.2",
            "cdo": "module -q load cdo/2.4.3",
            "nco": "module -q load nco/5.2.4",
            "ncl": "module -q load ncl-mpi-serial/6.6.2"
        }
    }


In brief, the ``JSON`` configuration file, describes the specifics about
the HPC of interest's scheduler type, the "unit" job executation details,
including the number of CPUs, time needed to finish the process of a
single job, the number of nodes where the executation happens, the
partition where executions should take place, the memory required per unit
job, and the account name of the user.

.. note::

   If an option in the JSON file is left empty, the tool will ignore that
   option during processing. Ensure that optional fields are left empty only
   if their functionality is not required on your HPC of choice.

In the following, the details of each section of the required ``JSON``
file are described.


File Structure
--------------
**Root Keys:**

- **scheduler**: Specifies the type of scheduler used by the HPC system. 
  In this case, the scheduler is set to ``slurm``. Currently available
  schedulers are: ``SLURM``, ``PBS Pro`` and ``IBM Spectrum LFS``. The 
  acceptable keyword for each scheduler in the ``JSON`` file is:

  +--------+-------------------+--------------+
  | Number | Scheduler Name    | Keyword      |
  +========+===================+==============+
  | 1      | SLURM             | ``slurm``    |
  +--------+-------------------+--------------+
  | 2      | PBS Pro           | ``pbs``      |
  +--------+-------------------+--------------+
  | 3      | IBM Spectrum LFS  | ``lfs``      |
  +--------+-------------------+--------------+

- **specs**: A dictionary containing the job specifications, such as
  allocated CPUs, runtime, memory, and other SLURM-specific parameters.

- **modules**: A dictionary defining the module system initialization
  commands and specific software modules required.


Details
-------

**Job Specifications**

- **specs**:
  Defines the job configuration to be submitted to the scheduler:
  
  - ``cpus``: Number of CPUs to allocate,
  - ``time``: Maximum runtime for the job in ``d-HH:MM:SS`` format,
  - ``nodes``: Number of nodes to allocate,
  - ``partition``: SLURM partition to use,
  - ``account``: HPC account name, and
  - ``mem``: Memory allocation for the job in megabytes.

**Modules**

- **modules**:
  This section defines the module system setup and required software.
  Please note that all arguments are optional and should be entered at the
  discretion of the end-user:
  
  - ``init``: List of initialization commands for the module system,
  - ``stdenv``: Placeholder for standard environment modules,
  - ``compiler``: Loads the compiler (e.g., ``module -q load gcc/14.2.0``),
  - ``mpi``: Loads the MPI implementation (e.g., ``module -q load mpi-serial/2.5.0``),
  - ``gdal``: Loads GDAL library for geospatial data processing (e.g., ``module -q load gdal/3.9.2``),
  - ``cdo``: Loads CDO library for climate data operators (e.g., ``module -q load cdo/2.4.3``),
  - ``nco``: Loads NCO library for netCDF operations (e.g., ``module -q load nco/5.2.4``),
  - ``ncl``: Loads NCL library for data visualization and processing (e.g., ``module -q load ncl-mpi-serial/6.6.2``),

.. note::

   Users may add other options as needed. However, the order of the sections is 
   important for the proper execution of targeted module systems.


Usage
-----

This configuration file ensures that all necessary software and environment
settings are loaded before running ``datatool`` on an HPC system. Customize
the fields (e.g., ``account`` or ``partition``) based on your specific HPC setup.

Predefined HPC Configurations
-----------------------------
For ease of use, a few HPC systems have default configuration files included.
Users can refer to these pre-configured files as needed:

- **Digital Research Alliance of Canada - Graham HPC**: ``./etc/clusters/drac-graham.json``
- **Perdue ACCESS Anvil HPC**: ``./etc/clusters/perdue-anvil.json``
- **UCalgary ARC HPC**: ``./etc/clusters/ucalgary-arc.json``
- **Environment and Climate Change Canada's (ECCC) Collab HPC**: ``./etc/clusters/eccc-collab.json``
- **Environment and Climate Change Canada's (ECCC) Science HPC**: ``./etc/clusters/eccc-science.json``

Users may target these HPCs by using the ``--cluster`` option and specify
the path to each. For instance by using
``--cluster=./etc/clusters/drac-graham.json``, the tool uses the
pre-defined configuration file of the ``Digital Research Alliance of
Canada``'s ``Graham`` cluster to execute subset extraction processes.
