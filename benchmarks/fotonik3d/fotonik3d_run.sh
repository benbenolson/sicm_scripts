#!/bin/bash

export REF="${SICM_ENV} ./fotonik3d.exe yee.dat"
export TEST="${SICM_ENV} ./fotonik3d.exe yee.dat"
export TRAIN="${SICM_ENV} ./fotonik3d.exe yee.dat"

function fotonik3d_setup {
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
  cp src/fotonik3d.exe run/
}
