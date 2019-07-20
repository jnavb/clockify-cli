#!/bin/bash

API_KEY=
USER=
WORKSPACE=
PROJECT=

TIMESTAMP=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
DAY_MONTH=$(date -u +'%d-%m')

init() {
  start_task
}

start_task() {
  task_in_progress=$(curl -sX GET \
  https://api.clockify.me/api/v1/workspaces/${WORKSPACE}/user/${USER}/time-entries?in-progress=true \
  -H "X-Api-Key: ${API_KEY}" \
  -H 'content-type: application/json')

  if [ "$task_in_progress" = "[]" ]; then
	  echo 'Starting task...'
    status_code=$(curl -sX POST -o /dev/null -w "%{http_code}" \
    https://api.clockify.me/api/v1/workspaces/${WORKSPACE}/time-entries \
    -H "X-Api-Key: ${API_KEY}" \
    -H 'content-type: application/json' \
    -d '{
      "start": "'${TIMESTAMP}'",
      "billable": true,
      "description": "Day '${DAY_MONTH}'",
      "projectId": "'${PROJECT}'"
    }')
    echo 'HTTP RESPONSE STATUS:'
    echo $status_code

    if [[ $status_code == 20* ]]; then
      osascript -e 'display notification "Set encouraging message" with title "Day start"'
    else
      osascript -e 'display notification "Cannot perform this action" with title "ERROR HTTP '$status_code'"'
    fi

  else
    echo 'Task is already started, not doing anything.'
    osascript -e 'display notification "Cannot perform this action" with title "Task already started."'
  fi
}

init "$@"
