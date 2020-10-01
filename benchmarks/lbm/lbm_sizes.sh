#!/bin/bash

export REF="${SICM_ENV} ./lbm.exe 2000 reference.dat 0 0 200_200_260_ldc.of"
export TRAIN="${SICM_ENV} ./lbm.exe 300 reference.dat 0 1 200_200_260_ldc.of"
export TEST="${SICM_ENV} ./lbm.exe 20 reference.dat 0 1 200_200_260_ldc.of"

function lbm_setup {
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
  cp src/lbm.exe run/
}
