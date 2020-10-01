#!/bin/bash

export REF="${SICM_ENV} ./nab.exe 3j1n 20140317 220"
export TRAIN="${SICM_ENV} ./nab.exe aminos 391519156 1000; ./nab.exe gcn4dna 1850041461 300"
export TEST="${SICM_ENV} ./nab.exe hkrdenq 1930344093 1000"

function nab_setup {
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
  cp src/nab.exe run/
}
