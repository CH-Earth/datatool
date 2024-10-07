
# logging function
logDate () { echo "($(date +"%Y-%m-%d %H:%M:%S")) "; }

# reading job configuration JSON
declare -A conf
while IFS="=" read -r key value; do
    conf["$key"]=$value
done < <(jq -r 'to_entries | .[] | "\(.key)=\(.value)"' __CONF__)

# declaring needed arrays
startDateArr=($(echo "${conf[startDateArr]}" | tr -d '[]"' | tr ',' ' '))
endDateArr=($(echo "${conf[endDateArr]}" | tr -d '[]"' | tr ',' ' '))
ensembleArr=($(echo "${conf[ensembleArr]}" | tr -d '[]"' | tr ',' ' '))
modelArr=($(echo "${conf[modelArr]}" | tr -d '[]"' | tr ',' ' '))
scenarioArr=($(echo "${conf[scenarioArr]}" | tr -d '[]"' | tr ',' ' '))

# extracting indices
idxDate="$(( (__ARRAY_TASK_ID__ / ${conf[dateIter]}) % ${conf[dateLen]} ))"
idxMember="$(( (__ARRAY_TASK_ID__ / ${conf[ensembleIter]}) % ${conf[ensembleLen]} ))"
idxModel="$(( (__ARRAY_TASK_ID__ / ${conf[modelIter]}) % ${conf[modelLen]} ))"
idxScenario="$(( __ARRAY_TASK_ID__ % ${conf[scenarioLen]} ))"

# extracting relevant chunk values
tBegin="${startDateArr[$idxDate]}"
tEnd="${endDateArr[$idxDate]}"
memberChosen="${ensembleArr[$idxMember]}"
modelChosen="${modelArr[$idxModel]}"
scenarioChosen="${scenarioArr[$idxScenario]}"

# information
echo "$(logDate)$(basename $0): Calling "${conf[scriptName]}".sh..."
echo "$(logDate)$(basename $0): `#'__ARRAY_TASK_ID__ chunk submitted."
echo "$(logDate)$(basename $0): Chunk start date is $tBegin"
echo "$(logDate)$(basename $0): Chunk end date is   $tEnd"

# details of submission chunk
if [[ -n ${modelChosen} ]]; then
  echo "$(logDate)$(basename $0): Model is           ${modelChosen}"
fi
if [[ -n ${scenarioChosen} ]]; then
  echo "$(logDate)$(basename $0): Scenario is        ${scenarioChosen}"
fi
if [[ -n ${memberChosen} ]]; then
  echo "$(logDate)$(basename $0): Ensemble member is ${memberChosen}"
fi

cache="${conf[cache]}"

# running script
eval ${conf[scriptFile]} \
  --dataset="${conf[dataset]}" \
  --dataset-dir="${conf[datasetDir]}" \
  --variable="${conf[variable]}" \
  --output-dir="${conf[outputDir]}" \
  --time-scale="${conf[timeScale]}" \
  --lat-lims="${conf[latLims]}" \
  --lon-lims="${conf[lonLims]}" \
  --prefix="${conf[prefix]}" \
  --start-date="$tBegin" \
  --end-date="$tEnd" \
  --cache="${cache}/cache-__ARRAY_JOB_ID__-__ARRAY_TASK_ID__" \
  --ensemble="${memberChosen}" \
  --model="${modelChosen}" \
  --scenario="${scenarioChosen}";

