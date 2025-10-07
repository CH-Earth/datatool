`#'!/bin/bash
`#'PBS -J 0-__JOBARRLEN__
`#'PBS -l select=__NODES__:ncpus=__CPUS__:mem=__MEM__
`#'PBS -l walltime=__TIME__
`#'PBS -N DATA-__SCRIPTNAME__
`#'PBS -e __LOGDIR__/datatool_err.txt
`#'PBS -o __LOGDIR__/datatool_log.txt
ifdef(`__ACCOUNT__', `#PBS -A '__ACCOUNT__, `dnl')
ifdef(`__PARTITION__', `#PBS -q '__PARTITION__, `dnl')
ifdef(`__EMAIL__',
`#PBS -M '__EMAIL__
`#PBS -m bea',
`dnl')
