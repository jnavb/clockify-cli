#!/bin/bash

API_KEY=
WORKSPACE=
PROJECT=
TIME=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
DAY_MONTH=$(date -u +'%d-%m')

curl -X POST \
  https://api.clockify.me/api/v1/workspaces/${WORKSPACE}/time-entries \
  -H "X-Api-Key: ${API_KEY}" \
  -H 'content-type: application/json' \
  -d '{
    "start": "'${TIME}'",
    "billable": true,
    "description": "Inicio jornada '${DAY_MONTH}'",
    "projectId": "'${PROJECT}'"
  }'
