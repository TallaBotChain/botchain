#!/bin/bash

# fail fast
set -e

export RACK_ENV=$APP_ENV
export RAILS_ENV=$APP_ENV

function wait_for_host_port {
  if [[ $# != 2 ]]; then echo "usage: $FUNCNAME host port"; return 1; fi

  host=$1
  port=$2
  echo "Waiting for $host:$port to become available"
  while ! nc -z $host $port  > /dev/null 2>&1; do echo .; sleep 2; done
  echo "The service on $host:$port is now available"
}

function wait_for_services {
  for svc in $SERVICES; do
    host=${svc%%:*}
    port=${svc##*:}
    wait_for_host_port ${!host} ${!port}
  done
}

function app_init {
  # Run bundler if needed - useful in dev
  if [[ "$APP_ENV" == "development" ]]; then
    npm install
  fi
}
export -f app_init

action=$1; shift

case $action in

  compile)
    wait_for_services
    app_init

    npm run compile
  ;;

  deploy)
    wait_for_services
    app_init

    npm run deploy
    if [[ -n $ABI_BUCKET ]]; then
      echo "Copying ABI to $ABI_BUCKET"
      aws s3 cp -r build/ s3://$ABI_BUCKET/
      # TODO: put deployed addresses as contracts.json as well
    fi
  ;;

  console)
    wait_for_services
    app_init

    ./node_modules/.bin/truffle develop
  ;;

  test)
    wait_for_services
    npm run compile
    npm test
  ;;

  bash)
    exec bash -il
  ;;

  exec)
    exec "$@"
  ;;

  *)
    echo "Invalid action: $action"
    exit 1
  ;;

esac
