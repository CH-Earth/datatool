# reading job configuration JSON
declare -A conf
while IFS="=" read -r key value; do
    conf["$key"]=$value
done < <(jq -r 'to_entries | .[] | "\(.key)=\(.value)"' __CONF__)

# declaring needed arrays
$(declare -p startDateArr)
$(declare -p endDateArr)
$(declare -p ensembleArr)
$(declare -p modelArr)
$(declare -p scenarioArr)

# extracting indices
idxDate="$(( (__ARRAY_TASK_ID__ / ${dateIter}) % ${dateLen} ))"
idxMember="$(( (__ARRAY_TASK_ID__ / ${ensembleIter}) % ${ensembleLen} ))"
idxModel="$(( (__ARRAY_TASK_ID__ / ${modelIter}) % ${modelLen} ))"
idxScenario="$(( __ARRAY_TASK_ID__ % ${scenarioLen} ))"

# extracting relevant chunk values
tBegin="${startDateArr[$idxDate]}"
tEnd="${endDateArr[$idxDate]}"
memberChosen="${ensembleArr[$idxMember]}"
modelChosen="${modelArr[$idxModel]}"
scenarioChosen="${scenarioArr[$idxScenario]}"

# information
echo "$(logDate)$(basename $0): Calling ${scriptName}.sh..."
echo "$(logDate)$(basename $0): #__ARRAY_TASK_ID__ chunk submitted."
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

# running script
srun ${script} \
  --start-date="$tBegin" \
  --end-date="$tEnd" \
  --cache="${cache}/cache-__ARRAY_JOB_ID__-__ARRAY_TASK_ID__" \
  --ensemble="${memberChosen}" \
  --model="${modelChosen}" \
  --scenario="${scenarioChosen}";

