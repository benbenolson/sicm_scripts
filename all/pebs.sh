#!/bin/bash

################################################################################
#                                   pebs                                       #
################################################################################
# First argument is results directory
# Second argument is the command to run
# Third argument is the PEBS frequency
function pebs {
  BASEDIR="$1"
  COMMAND="$2"
  FREQ="$3"

  # User output
  echo "Running experiment:"
  echo "  Config: 'pebs'"
  echo "  Sample Frequency: '${FREQ}'"

  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="4"
  export SH_PROFILE_ALL="1"
  export SH_PROFILE_ALL_RATE="0"
  export SH_MAX_SAMPLE_PAGES="512"
  export SH_PROFILE_RSS="1"
  export SH_PROFILE_RSS_RATE="0"
  export SH_DEFAULT_NODE="0"
  export SH_SAMPLE_FREQ="${FREQ}"
  export OMP_NUM_THREADS="270" # Two threads for profiling

  DIR="${BASEDIR}/i0"
  mkdir ${DIR}
  echo 1 | sudo tee /proc/sys/kernel/perf_event_paranoid
  drop_caches
  eval "env time -v" "${COMMAND}" &>> ${DIR}/stdout.txt
}
