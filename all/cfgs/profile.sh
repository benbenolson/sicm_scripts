#!/bin/bash

################################################################################
#                                   pebs                                       #
################################################################################
# First argument is the PEBS frequency
# Second is the sampling rate
# Third is skip intervals for capacity profiling
function profile_all_and_allocs {
  FREQ="$1"
  RATE="$2"
  SIZE_SKIP_INTERVALS="$3"

  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"

  # Enable profiling
  export SH_PROFILE_ALL="1"
  export SH_PROFILE_RATE_NSECONDS=$(echo "$RATE * 1000000" | bc)
  export SH_PROFILE_ALL_EVENTS="MEM_LOAD_UOPS_RETIRED:L3_MISS"
  export SH_MAX_SAMPLE_PAGES="512"
  export SH_PROFILE_ALLOCS="1"
  export SH_PROFILE_ALLOCS_SKIP_INTERVALS="$SIZE_SKIP_INTERVALS"
  export SH_SAMPLE_FREQ="${FREQ}"

  # One for master profiling, one for PROFILE_ALL, one for capacity profiling
  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 3`

  eval "${PRERUN}"

  DIR="${BASEDIR}/i0"
  mkdir ${DIR}
  echo 1 | sudo tee /proc/sys/kernel/perf_event_paranoid
  drop_caches
  eval "${COMMAND}" &>> ${DIR}/stdout.txt
}

# First argument is the PEBS frequency
# Second is the sampling rate
# Third is skip intervals for capacity profiling
function profile_all_and_extent_size {
  FREQ="$1"
  RATE="$2"
  SIZE_SKIP_INTERVALS="$3"

  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"

  # Enable profiling
  export SH_PROFILE_ALL="1"
  export SH_PROFILE_RATE_NSECONDS=$(echo "$RATE * 1000000" | bc)
  export SH_PROFILE_ALL_EVENTS="MEM_LOAD_UOPS_RETIRED:L3_MISS"
  export SH_MAX_SAMPLE_PAGES="512"
  export SH_PROFILE_EXTENT_SIZE="1"
  export SH_PROFILE_EXTENT_SIZE_SKIP_INTERVALS="$SIZE_SKIP_INTERVALS"

  # Bind to the fast node
  export SH_SAMPLE_FREQ="${FREQ}"

  # One for master profiling, one for PROFILE_ALL, one for jemalloc background thread
  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 3`

  eval "${PRERUN}"

  DIR="${BASEDIR}/i0"
  mkdir ${DIR}
  echo 1 | sudo tee /proc/sys/kernel/perf_event_paranoid
  drop_caches
  eval "${COMMAND}" &>> ${DIR}/stdout.txt
}
