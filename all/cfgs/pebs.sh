#!/bin/bash

################################################################################
#                                   pebs                                       #
################################################################################
# Third argument is the PEBS frequency
function pebs {
  FREQ="$1"

  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="4"

  # Enable profiling
  export SH_PROFILE_ALL="1"
  export SH_PROFILE_RATE_NSECONDS="10000000"
  export SH_PROFILE_ALL_EVENTS="MEM_LOAD_UOPS_RETIRED:L3_MISS"
  export SH_MAX_SAMPLE_PAGES="512"
  export SH_PROFILE_RSS="1"
  export SH_PROFILE_RSS_SKIP_INTERVALS="100"

  # Bind to the fast node
  export SH_DEFAULT_NODE="1"
  export SH_SAMPLE_FREQ="${FREQ}"
  export JE_MALLOC_CONF="oversize_threshold:0"
  export OMP_NUM_THREADS="45"

  eval "${PRERUN}"

  DIR="${BASEDIR}/i0"
  mkdir ${DIR}
  echo 1 | sudo tee /proc/sys/kernel/perf_event_paranoid
  drop_caches
  if [[ "$(hostname)" = "JF1121-080209T" ]]; then
    eval "env time -v numactl --cpunodebind=1 --preferred=1 " "${COMMAND}" &>> ${DIR}/stdout.txt
  else
    eval "env time -v numactl --preferred=1" "${COMMAND}" &>> ${DIR}/stdout.txt
  fi
}
