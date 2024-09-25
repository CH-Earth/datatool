`#'!/bin/bash
`#'SBATCH --array=0-__JOBARRLEN__
`#'SBATCH --cpus-per-task=__CPUS__
`#'SBATCH --nodes=__NODES__
`#'SBATCH --account=__ACCOUNT__
`#'SBATCH --partition=__PARTITION__
`#'SBATCH --time=__TIME__
`#'SBATCH --mem=__RAM__
`#'SBATCH --job-name=DATA___SCRIPTNAME__
`#'SBATCH --error=__LOGDIR__/datatool_%A-%a_err.txt
`#'SBATCH --output=__LOGDIR__/datatool_%A-%a.txt
`#'SBATCH --mail-user=__EMAIL__
`#'SBATCH --mail-type=BEGIN,END,FAIL
`#'SBATCH __PARSABLE__

