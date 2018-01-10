#!/bin/bash

# fail fast
set -e

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
#  # Run bundler if needed - useful in dev
#  if [[ "$APP_ENV" == "development" ]]; then
#    npm install
#  fi
  :
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

    if [[ "$PARITY_CHAIN" == "mainnet" ]]; then
      echo "Deploying to mainnet"
      npm run deploy:mainnet
    elif [[ "$PARITY_CHAIN" == "kovan" ]]; then
      echo "Deploying to kovan"
      npm run deploy:kovan
    else
      echo "Deploying to development"
      npm run deploy:development
    fi

    if [[ -n $ABI_BUCKET ]]; then
      echo "Copying ABI to $ABI_BUCKET"
      aws s3 cp --acl bucket-owner-full-control --recursive \
        build/ s3://$ABI_BUCKET/
    fi
  ;;

  console)
    wait_for_services
    app_init

    truffle console
  ;;

  test)
    wait_for_services
    npm run compile
    npm run test:truffle
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
