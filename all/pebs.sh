#!/bin/bash

################################################################################
#                                   pebs                                       #
################################################################################
# First argument is results directory
# Second argument is the command to run
# Third argument is the PEBS frequency
function pebs {
  RESULTS_DIR="$1"
  COMMAND="$2"
  FREQ="$3"

  # User output
  echo "Running experiment:"
  echo "  Experiment: PEBS Profiling"
  echo "  Sample Frequency: ${FREQ}"
  echo "  Command: '${COMMAND}'"

  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_PROFILE_ALL="1"
  export SH_PROFILE_ALL_RATE="0"
  export SH_MAX_SAMPLE_PAGES="512"
  export SH_PROFILE_RSS="1"
  export SH_PROFILE_RSS_RATE="0"
  export SH_DEFAULT_NODE="0"
  export SH_SAMPLE_FREQ="${FREQ}"
  export OMP_NUM_THREADS="64"

  echo 3 | sudo tee /proc/sys/vm/drop_caches
  sleep 5
  eval "env time -v" "${COMMAND}" &>> ${RESULTS_DIR}/stdout.txt
}
