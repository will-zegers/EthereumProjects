#!/bin/bash

PROJECT_NAME=$1

if [ -z "$PROJECT_NAME" ]; then
  echo "usage: ./solc_compile project_name"
  exit
fi

PROJ_DIR="/home/will/Ethereum_Projects/$PROJECT_NAME"

if [ ! -f "$PROJ_DIR/$PROJECT_NAME.sol" ]; then
  echo "$PROJ_DIR/$PROJECT_NAME.sol not found"
  exit
fi

echo "var compiledContract=`solc --optimize --combined-json abi,bin,interface $PROJ_DIR/$PROJECT_NAME.sol`" > $PROJ_DIR/$PROJECT_NAME.json
