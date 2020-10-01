#!/bin/bash

export SMALL_AEP="${SICM_ENV} ./preqx < ./input.nl"
export MEDIUM_AEP="${SICM_ENV} ./preqx < ./input.nl"
export LARGE_AEP="${SICM_ENV} ./preqx < ./input.nl"

function cam-se_prerun {
  rm -rf run/movies/*
  rm -rf run/mass.out
  rm -rf run/HommeTime
  rm -rf run/input.nl

  # Now we have to generate the input file, since it hardcodes the number of threads.
  # We're expecting OMP_NUM_THREADS to be set before this function is run.
  # We set some environment variables that this script looks for, depending on the size
  # of the run. I know it's janky, but it works.
  if [[ $SIZE == "small_aep" ]]; then
    export CAM_SE_NE="16"
    export CAM_SE_PARTMETHOD="4"
  elif [[ $SIZE == "medium_aep" ]]; then
    export CAM_SE_NE="32"
    export CAM_SE_PARTMETHOD="4"
  elif [[ $SIZE == "large_aep" ]]; then
    export CAM_SE_NE="96"
    export CAM_SE_PARTMETHOD="4"
    export CAM_SE_MULTILEVEL="1"
    export CAM_SE_QSIZE="16"
  fi
  ./generate_input.sh
}
