.. datatool documentation master file, created by

Welcome to ``datatool``'s documentation!
========================================
The current version of ``datatool`` can be run on any HPC. A JSON file
needs to be prepared the reflects the requirements needed by the tool.

JSON Configuration File for HPC Module Systems
==============================================

This JSON file provides the configuration specifications for running the datatool on any High-Performance Computing (HPC) system. It primarily describes the scheduler, job specifications, and module systems required for successful execution.

File Structure
--------------

**Root Keys:**

- **scheduler**: Specifies the type of scheduler used by the HPC system. In this case, the scheduler is set to `slurm`.

- **specs**: A dictionary containing the job specifications, such as allocated CPUs, runtime, memory, and other SLURM-specific parameters.

- **modules**: A dictionary defining the module system initialization commands and specific software modules required.

Details
-------

**Scheduler**

- ``scheduler``: 
  Specifies the HPC job scheduler. Current value: ``slurm``.

**Job Specifications**

- **specs**:
  Defines the job configuration to be submitted to the scheduler:
  
  - ``cpus``: Number of CPUs to allocate.
  - ``time``: Maximum runtime for the job in HH:MM:SS format.
  - ``nodes``: Number of nodes to allocate.
  - ``partition``: SLURM partition to use.
  - ``account``: HPC account name. Leave blank or specify as needed.
  - ``mem``: Memory allocation for the job in megabytes. Leave blank or
    specify as needed.

**Modules**

- **modules**:
  Defines the module system setup and required software:
  
  - ``init``: List of initialization commands for the module system
    (optional).
  - ``stdenv``: Placeholder for standard environment modules (optional).
  - ``compiler``: Loads the compiler (e.g., ``module -q load gcc/14.2.0``).
  - ``mpi``: Loads the MPI implementation (e.g., ``module -q load mpi-serial/2.5.0``).
  - ``gdal``: Loads GDAL library for geospatial data processing (e.g., ``module -q load gdal/3.9.2``).
  - ``cdo``: Loads CDO library for climate data operators (e.g., ``module -q load cdo/2.4.3``).
  - ``nco``: Loads NCO library for netCDF operations (e.g., ``module -q load nco/5.2.4``).
  - ``ncl``: Loads NCL library for data visualization and processing (e.g., ``module -q load ncl-mpi-serial/6.6.2``).

Usage
-----

This configuration file ensures that all necessary software and environment settings are loaded before running the datatool on an HPC system. Customize the fields (e.g., ``account`` or ``partition``) based on your specific HPC setup.

**Example:**

Save this JSON configuration as a file (e.g., ``hpc_config.json``) and reference it in your datatool configuration via the ``--cluster=/path/to/hpc_config.json`` argument.

Predefined HPC Configurations
-----------------------------

For ease of use, a few HPC systems have default configuration files included. Users can refer to these pre-configured files as needed:

- **Digital Research Alliance of Canada - Graham HPC**: ``./etc/clusters/drac-graham.json``
- **Perdue ACCESS Anvil HPC**: ``./etc/clusters/perdue-anvil.json``
- **UCalgary ARC HPC**: ``./etc/clusters/ucalgary-arc.json``
- **Environment and Climate Change Canada's Collab HPC**: ``./etc/clusters/eccc-collab.json``
- **Environment and Climate Change Canada's Science HPC**: ``./etc/clusters/eccc-science.json``

