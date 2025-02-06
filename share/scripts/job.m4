`# declaring arrays'
$(declare -p startDateArr)
$(declare -p endDateArr)
$(declare -p ensembleArr)
$(declare -p modelArr)
$(declare -p scenarioArr)

`# indices'
idxDate="$(( (${__ARRAY_TASK_ID__} / ${dateIter}) % ${dateLen} ))"
idxMember="$(( (${__ARRAY_TASK_ID__} / ${ensembleIter}) % ${ensembleLen} ))"
idxModel="$(( (${__ARRAY_TASK_ID__} / ${modelIter}) % ${modelLen} ))"
idxScenario="$(( ${__ARRAY_TASK_ID__} % ${scenarioLen} ))"

`# specifying job details'
tBegin="${startDateArr[$idxDate]}"
tEnd="${endDateArr[$idxDate]}"
memberChosen="${ensembleArr[$idxMember]}"
modelChosen="${modelArr[$idxModel]}"
scenarioChosen="${scenarioArr[$idxScenario]}"

`# messages'
echo "$(basename $0): Calling ${scriptName}.sh..."
echo "$(basename $0): #${__ARRAY_TASK_ID__} chunk submitted."
echo "$(basename $0): Chunk start date is $tBegin"
echo "$(basename $0): Chunk end date is   $tEnd"

if [[ -n ${modelChosen} ]]; then
  echo "$(logDate)$(basename $0): Model is            ${modelChosen}"
fi
if [[ -n ${scenarioChosen} ]]; then
  echo "$(logDate)$(basename $0): Scenario is         ${scenarioChosen}"
fi
if [[ -n ${memberChosen} ]]; then
  echo "$(logDate)$(basename $0): Ensemble member is  ${memberChosen}"
fi

`# run script'
srun ${script} \
  --start-date="$tBegin" \
  --end-date="$tEnd" \
  --cache="${cache}/cache-${__ARRAY_JOB_ID__}-${__ARRAY_TASK_ID__}" \
  --ensemble="${memberChosen}" \
  --model="${modelChosen}" \
  --scenario="${scenarioChosen}";

