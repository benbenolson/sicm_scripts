#!/bin/bash

function multi_iter_online {
  FREQ="$1"
  RATE="$2"
  CAP_SKIP_INTERVALS="$3"
  ONLINE_SKIP_INTERVALS="$4"
  ONLINE_LAST_ITER_VALUE="$5"
  ONLINE_LAST_ITER_WEIGHT="$6"

  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_PROFILE_RATE_NSECONDS=$(echo "${RATE} * 1000000" | bc)

  # Value profiling
  export SH_PROFILE_ALL="1"
  export SH_PROFILE_ALL_EVENTS="MEM_LOAD_UOPS_RETIRED:L3_MISS"
  export SH_MAX_SAMPLE_PAGES="512"
  export SH_SAMPLE_FREQ="${FREQ}"

  # Weight profiling
  export SH_PROFILE_EXTENT_SIZE="1"
  export SH_PROFILE_EXTENT_SIZE_SKIP_INTERVALS="$CAP_SKIP_INTERVALS"

  # Turn on online
  export SH_PROFILE_ONLINE="1"
  export SH_PROFILE_ONLINE_EVENT="MEM_LOAD_UOPS_RETIRED:L3_MISS"
  export SH_PROFILE_ONLINE_SKIP_INTERVALS="$ONLINE_SKIP_INTERVALS"

  # Super mega verbose
  export SH_PROFILE_ONLINE_PRINT_RECONFIGURES="1"
  export SH_PROFILE_ONLINE_DEBUG="1"

  # Set how much we should prioritize the last iter
  export SH_PROFILE_ONLINE_LAST_ITER_VALUE="$ONLINE_LAST_ITER_VALUE"
  export SH_PROFILE_ONLINE_LAST_ITER_WEIGHT="$ONLINE_LAST_ITER_WEIGHT"

  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 1`

  eval "${PRERUN}"

  for i in $(seq 1 $MAX_ITER); do
    # Parse the previous run's profiling information
    if [[ ${i} -gt 0 ]]; then
      PREV=$(echo "${i} - 1" | bc)
      export SH_PROFILE_INPUT_FILE="${BASEDIR}/i${PREV}/profile.txt"
      echo ${SH_PROFILE_INPUT_FILE}
    fi
    DIR="${BASEDIR}/i${i}"
    export SH_PROFILE_OUTPUT_FILE="${DIR}/profile.txt"
    mkdir ${DIR}
    drop_caches
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    eval "${COMMAND}" &>> ${DIR}/stdout.txt
    numastat_kill
    pcm_kill
  done
}
