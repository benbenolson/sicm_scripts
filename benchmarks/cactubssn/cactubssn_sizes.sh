#!/bin/bash

export REF="${SICM_ENV} ./cactubssn.exe spec_ref.par"
export TRAIN="${SICM_ENV} ./cactubssn.exe spec_train.par"
export TEST="${SICM_ENV} ./cactubssn.exe spec_test.par"

function cactubssn_setup {
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
  cp src/cactubssn.exe run/
}
