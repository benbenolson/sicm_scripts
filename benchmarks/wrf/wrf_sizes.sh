#!/bin/bash

export REF="${SICM_ENV} ./wrf.exe"
export TEST="${SICM_ENV} ./wrf.exe"
export TRAIN="${SICM_ENV} ./wrf.exe"

function wrf_prerun {
  export SH_MAX_SITES="18500"
}

function wrf_setup {
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
  cp src/wrf.exe run/
}
