#!/bin/bash

################################################################################
#                                 offline_all_manual                           #
################################################################################
# First argument is results directory
# Second argument is the command to run
# Third argument is the NUMA node to pack onto
# Fourth argument is the NUMA node to use as a lower tier
# This config expects you to install `guidance.txt` in the right place manually.
function offline_all_manual {
  BASEDIR="$1"
  COMMAND="$2"
  NODE=${3}
  SLOWNODE=${4}

  # User output
  echo "Running experiment:"
  echo "  Config: 'offline_all_manual'"
  echo "  Profiling frequency: '${PEBS_FREQ}'"
  echo "  Profiling size: '${PEBS_SIZE}'"
  echo "  Packing algorithm: '${PACK_ALGO}'"
  echo "  Packing into upper tier: '${UPPER_SIZE}'"
  echo "  Scaling down to peak RSS: '${PEAK_RSS}'"

  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="4096"
  export SH_DEFAULT_NODE="${SLOWNODE}"
  export SH_GUIDANCE_FILE="${BASEDIR}/guidance.txt"
  export JE_MALLOC_CONF="oversize_threshold:0"

  eval "${PRERUN}"
  
  for i in {0..0}; do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    if [[ "$(hostname)" = "JF1121-080209T" ]]; then
      eval "env time -v numactl --cpunodebind=${NODE} " "${COMMAND}" &>> ${DIR}/stdout.txt
    else
      eval "env time -v " "${COMMAND}" &>> ${DIR}/stdout.txt
    fi
    numastat_kill
    pcm_kill
    memreserve_kill
  done
}

