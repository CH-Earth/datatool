`#!/bin/bash'
`#SBATCH' --array=0-__JOBARRLEN__
`#SBATCH' --cpus-per-task=__CPUS__
`#SBATCH' --nodes=__NODES__
`#SBATCH' --time=__TIME__
`#SBATCH' --mem=__MEM__
`#SBATCH' --job-name=DATA-__SCRIPTNAME__
`#SBATCH' --error=__LOGDIR__/datatool_%A-%a_err.txt
`#SBATCH' --output=__LOGDIR__/datatool_%A-%a.txt
ifdef(`__PARTITION__', `#SBATCH --partition='__PARTITION__, `dnl')
ifdef(`__ACCOUNT__', `#SBATCH --account='__ACCOUNT__, `dnl')
ifdef(`__PARSABLE__', `#SBATCH '__PARSABLE__, `dnl')
ifdef(`__EMAIL__', 
`#SBATCH --mail-user='__EMAIL__
`#SBATCH --mail-type=BEGIN,END,FAIL',
`dnl')
