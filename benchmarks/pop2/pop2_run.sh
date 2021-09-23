#!/bin/bash

#export REF="${SICM_ENV} valgrind --soname-synonyms=somalloc=NONE ./pop2.exe"
#export REF="${SICM_ENV} valgrind --tool=exp-sgcheck ./pop2.exe"
#export REF="${SICM_ENV} valgrind --tool=drd --read-var-info=yes ./pop2.exe"
#export REF="${SICM_ENV} valgrind --tool=helgrind --read-var-info=yes ./pop2.exe"
#export REF="${SICM_ENV} gdb ./pop2.exe"
export REF="${SICM_ENV} ./pop2.exe"
export TEST="${SICM_ENV} ./pop2.exe"
export TRAIN="${SICM_ENV} ./pop2.exe"

function pop2_prerun {
  export OMP_STACKSIZE="128M"
}

function pop2_setup {
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
  cp src/pop2.exe run/
}
