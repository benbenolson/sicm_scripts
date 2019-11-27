#!/bin/bash

DO_MEMRESERVE=false

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
  #export SH_PROFILE_ONLINE_PRINT_RECONFIGURES="1"
  #export SH_PROFILE_ONLINE_DEBUG="1"

  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 1`

  eval "${PRERUN}"

  for i in $(seq 0 $MAX_ITER); do
    # Parse the previous run's profiling information
    if [[ ${i} -gt 0 ]]; then
      PREV=$(echo "${i} - 1" | bc)
      export SH_PROFILE_INPUT_FILE="${BASEDIR}/i${PREV}/profile.txt"
      export SH_PROFILE_ONLINE_LAST_ITER_VALUE="$ONLINE_LAST_ITER_VALUE"
      export SH_PROFILE_ONLINE_LAST_ITER_WEIGHT="$ONLINE_LAST_ITER_WEIGHT"
    fi
    DIR="${BASEDIR}/i${i}"
    export SH_PROFILE_OUTPUT_FILE="${DIR}/profile.txt"
    mkdir ${DIR}
    drop_caches
    if [ "$DO_MEMRESERVE" = true ]; then
      memreserve ${DIR} ${NUM_PAGES} ${SH_UPPER_NODE}
    fi
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    eval "${COMMAND}" &>> ${DIR}/stdout.txt
    numastat_kill
    pcm_kill
    if [ "$DO_MEMRESERVE" ]; then
      memreserve_kill
    fi
  done
}

function multi_iter_online_memreserve {
  # Accepts the same arguments as multi_iter_online, but with the addition of a percentage
  # as the last argument, which is the portion of the application that should be left
  # available on the upper tier.
  RATIO=$(echo "${7}/100" | bc -l)
  CANARY_CFG="firsttouch_shared_site:"
  CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/i0/"

  if [ ! -r ${CANARY_STDOUT} ]; then
    echo "ERROR: The file '${CANARY_STDOUT} doesn't exist yet. Aborting."
    exit
  fi

  # This is in kilobytes
  PEAK_RSS=`${SCRIPTS_DIR}/all/stat --metric=peak_rss_kbytes ${CANARY_DIR}`
  PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)

  # How many pages we need to be free on upper tier
  NUM_PAGES=$(echo "${PEAK_RSS} * ${RATIO} / 4" | bc)
  NUM_BYTES_FLOAT=$(echo "${PEAK_RSS} * ${RATIO} * 1024" | bc)
  NUM_BYTES=${NUM_BYTES_FLOAT%.*}

  DO_MEMRESERVE=true
  multi_iter_online $@
}
