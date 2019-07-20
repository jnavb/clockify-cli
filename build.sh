#!/bin/bash

######## INTRODUCE VARIABLES ###########
API_KEY=
WORKSPACE=
PROJECT=
########################################

init() {
  require_api_data
  require_jq

  pre_build_api_data
  pre_build_user_id

  build
  deploy
  clean
}

require_api_data() {
  if [ -z $API_KEY ]; then
    echo 'Exit: API_KEY is missing.'
    exit 1
  fi
  if [ -z $WORKSPACE ]; then
    echo 'Exit: WORKSPACE is missing.'
    exit 1
  fi
  if [ -z $PROJECT ]; then
    echo 'Exit: PROJECT is missing.'
    exit 1
  fi
}

require_jq() {
  jq --version || brew install jq
}

pre_build_api_data() {
  sed -i '' -e '1,/API_KEY=/s/API_KEY=/API_KEY='${API_KEY}'/' ./src/clockify-start.sh
  sed -i '' -e '1,/API_KEY=/s/API_KEY=/API_KEY='${API_KEY}'/' ./src/clockify-finish.sh
  sed -i '' -e '1,/WORKSPACE=/s/WORKSPACE=/WORKSPACE='${WORKSPACE}'/' ./src/clockify-start.sh
  sed -i '' -e '1,/WORKSPACE=/s/WORKSPACE=/WORKSPACE='${WORKSPACE}'/' ./src/clockify-finish.sh
  sed -i '' -e '1,/PROJECT=/s/PROJECT=/PROJECT='${PROJECT}'/' ./src/clockify-start.sh
  sed -i '' -e '1,/PROJECT=/s/PROJECT=/PROJECT='${PROJECT}'/' ./src/clockify-finish.sh
}

pre_build_user_id() {
    user_response=$(curl -sX GET https://api.clockify.me/api/v1/user \
    -H "X-Api-Key: ${API_KEY}" \
    -H 'content-type: application/json')

    id=$(echo $user_response | jq -r .id)
    USER=$id

    sed -i '' -e '1,/USER=/s/USER=/USER='${id}'/' ./src/clockify-start.sh
    sed -i '' -e '1,/USER=/s/USER=/USER='${id}'/' ./src/clockify-finish.sh
}

build() {
  ./lib/appify.sh ./src/clockify-start.sh "Start clockify"
  ./lib/appify.sh ./src/clockify-finish.sh "Finish clockify"
}

deploy() {
  mv "Start clockify.app" build/
  mv "Finish clockify.app" build/
  
  cp src/clockify-start.sh build/clock-start
  cp src/clockify-finish.sh build/clock-finish
  cp build/clock-start /usr/local/bin/
  cp build/clock-finish /usr/local/bin/

  printf "\n\n// Clockify aliases" >> $HOME/.bash_profile
  printf "\nalias cls=clock-start" >> $HOME/.bash_profile
  printf "\nalias clf=clock-finish" >> $HOME/.bash_profile
}

clean() {
  git checkout src
  echo Done!
}

init "$@"
