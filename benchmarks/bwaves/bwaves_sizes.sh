#!/bin/bash

export REF="${SICM_ENV} ./bwaves.exe bwaves_1 < bwaves_1.in; ${SICM_ENV} ./bwaves.exe bwaves_2 < bwaves_2.in"
export TEST="${SICM_ENV} ./bwaves.exe bwaves_1 < bwaves_1.in; ${SICM_ENV} ./bwaves.exe bwaves_2 < bwaves_2.in"
export TRAIN="${SICM_ENV} ./bwaves.exe bwaves_1 < bwaves_1.in; ${SICM_ENV} ./bwaves.exe bwaves_2 < bwaves_2.in"

function bwaves_setup {
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
  cp src/bwaves.exe run/
}
