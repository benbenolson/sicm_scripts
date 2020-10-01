#!/bin/bash

export REF="${SICM_ENV} ./cam4.exe"
export TEST="${SICM_ENV} ./cam4.exe"
export TRAIN="${SICM_ENV} ./cam4.exe"

function cam4_prerun {
  export SH_MAX_SITES="6000"
  export OMP_STACKSIZE="256M"
}

function cam4_setup {
  if [[ $SIZE = "ref" ]]; then
    rm -rf run
    cp -r run-ref run
  elif [[ $SIZE = "train" ]]; then
    rm -rf run
    cp -r run-train run
  elif [[ $SIZE = "test" ]]; then
    rm -rf run
    cp -r run-test run
  fi
  cp src/cam4.exe run/
}
