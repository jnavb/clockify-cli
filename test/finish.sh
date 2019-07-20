#!/bin/bash

API_KEY=
USER=
WORKSPACE=
PROJECT=

TIMESTAMP=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
DAY_MONTH=$(date -u +'%d-%m')

task_in_progress=$(curl -sX GET \
  https://api.clockify.me/api/v1/workspaces/${WORKSPACE}/user/${USER}/time-entries?in-progress=true \
  -H "X-Api-Key: ${API_KEY}" \
  -H 'content-type: application/json')

  if [ "$task_in_progress" = "[]" ]; then
	echo 'Task is not started, not doing anything.'
  else

    id=$(echo $task_in_progress | jq -r .[0].id)
    start_time=$(echo $task_in_progress | jq -r .[0].timeInterval.start)

    echo $id
    echo $start_time

    curl -sX PUT \
    https://api.clockify.me/api/v1/workspaces/${WORKSPACE}/time-entries/${id} \
    -H "X-Api-Key: ${API_KEY}" \
    -H 'content-type: application/json' \
    -d '{
        "start": "'${start_time}'",
        "end": "'${TIMESTAMP}'",
        "billable": true,
        "description": "Fin jornada '${DAY_MONTH}'",
        "projectId": "'${PROJECT}'"
    }'
  fi

