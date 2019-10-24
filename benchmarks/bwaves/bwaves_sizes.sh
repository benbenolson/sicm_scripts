#!/bin/bash

export REF="sh -c '${SICM_ENV} ./bwaves.exe bwaves_1 < bwaves_1.in; ${SICM_ENV} ./bwaves.exe bwaves_2 < bwaves_2.in;'"
export TRAIN="sh -c '${SICM_ENV} ./bwaves.exe bwaves_1 < bwaves_1.in; ${SICM_ENV} ./bwaves.exe bwaves_2 < bwaves_2.in;'"
export TEST="sh -c '${SICM_ENV} ./bwaves.exe bwaves_1 < bwaves_1.in; ${SICM_ENV} ./bwaves.exe bwaves_2 < bwaves_2.in;'"

function bwaves_prerun {
  if [[ $SH_ARENA_LAYOUT = "SHARED_SITE_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  elif [[ $SH_ARENA_LAYOUT = "BIG_SMALL_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  else
    export JE_MALLOC_CONF="oversize_threshold:0"
  fi
}

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
