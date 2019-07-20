#!/bin/bash

API_KEY=
USER=
WORKSPACE=
PROJECT=

TIMESTAMP=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
DAY_MONTH=$(date -u +'%d-%m')

init() {
  finish_task
}

finish_task() {
	task_in_progress=$(curl -sX GET \
  https://api.clockify.me/api/v1/workspaces/${WORKSPACE}/user/${USER}/time-entries?in-progress=true \
  -H "X-Api-Key: ${API_KEY}" \
  -H 'content-type: application/json')

  if [ "$task_in_progress" = "[]" ]; then
	  echo 'Task is not started, not doing anything.'
    osascript -e 'display notification "Cannot perform this action" with title "Task already started"'
  else

    id=$(echo $task_in_progress | jq -r .[0].id)
    start_time=$(echo $task_in_progress | jq -r .[0].timeInterval.start)

    status_code=$( curl -sX PUT -o /dev/null -w "%{http_code}" \
    https://api.clockify.me/api/v1/workspaces/${WORKSPACE}/time-entries/${id} \
    -H "X-Api-Key: ${API_KEY}" \
    -H 'content-type: application/json' \
    -d '{
        "start": "'${start_time}'",
        "end": "'${TIMESTAMP}'",
        "billable": true,
        "description": "Day '${DAY_MONTH}'",
        "projectId": "'${PROJECT}'"
    }')
    echo 'HTTP RESPONSE STATUS:'
    echo $status_code

    if [[ $status_code == 20* ]]; then
      osascript -e 'display notification "Time stopped." with title "End of day"'
    else
      osascript -e 'display notification "Cannot perform this action." with title "ERROR HTTP '$status_code'"'
    fi

  fi
}

init "$@"
