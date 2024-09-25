`#'!/bin/bash
`#'PBS -J 0-__JOBARRLEN__
`#'PBS -l select=__NODES__:ncpus=__CPUS__:mem=__RAM__
`#'PBS -l walltime=__TIME__
`#'PBS -N DATA___SCRIPTNAME__
`#'PBS -M __EMAIL__
`#'PBS -m bea
`#'PBS -A __ACCOUNT__
`#'PBS -q __PARTITION__
`#'PBS -e __LOGDIR__/datatool_$PBS_JOBID-$PBS_ARRAY_INDEX_err.txt
`#'PBS -o __LOGDIR__/datatool_$PBS_JOBID-$PBS_ARRAY_INDEX.txt

