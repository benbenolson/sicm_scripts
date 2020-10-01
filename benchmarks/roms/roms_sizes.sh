#!/bin/bash

export REF="${SICM_ENV} ./roms.exe < ocean_benchmark3.in"
export TEST="${SICM_ENV} ./roms.exe < ocean_benchmark0.in"
export TRAIN="${SICM_ENV} ./roms.exe < ocean_benchmark1.in"

function roms_prerun {
  export SH_MAX_SITES="16000"
}

function roms_setup {
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
  cp src/roms.exe run/
}
