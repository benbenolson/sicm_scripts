#!/bin/bash

DO_MEMRESERVE=false
MEMRESERVE_RATIO=""

function online_base {
  CANARY_LAYOUT="$1"
  FREQ="$2"
  RATE="$3"
  ONLINE_SKIP_INTERVALS="$4"

  # First, get ready to do memreserve if applicable
  if [ "${DO_MEMRESERVE}" = true ]; then
    RATIO=$(echo "${MEMRESERVE_RATIO}/100" | bc -l)
    if [[ "${CANARY_LAYOUT}" == "excl" ]]; then
      CANARY_CFG="firsttouch_exclusive_device:"
    elif [[ "${CANARY_LAYOUT}" == "share" ]]; then
      CANARY_CFG="firsttouch_shared_site:"
    elif [[ "${CANARY_LAYOUT}" == "def" ]]; then
      CANARY_CFG="firsttouch_default:"
    fi
    CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/i0/"

    # This file is used to get the peak RSS
    if [ ! -r "${CANARY_DIR}" ]; then
      echo "ERROR: The file '${CANARY_DIR}' doesn't exist yet. Aborting."
      exit
    fi

    # This is in kilobytes
    PEAK_RSS=`${SCRIPTS_DIR}/all/stat --metric=peak_rss_kbytes ${CANARY_DIR}`
    PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)

    # How many pages we need to be free on upper tier
    NUM_PAGES=$(echo "${PEAK_RSS} * ${RATIO} / 4" | bc)
    NUM_BYTES_FLOAT=$(echo "${PEAK_RSS} * ${RATIO} * 1024" | bc)
    NUM_BYTES=${NUM_BYTES_FLOAT%.*}
    echo "Reserving $NUM_PAGES pages."
  fi

  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_PROFILE_RATE_NSECONDS=$(echo "${RATE} * 1000000" | bc)

  # Value profiling
  export SH_PROFILE_ALL="1"
  export SH_MAX_SAMPLE_PAGES="512"
  export SH_SAMPLE_FREQ="${FREQ}"

  export SH_PROFILE_ONLINE_EVENTS="MEM_LOAD_UOPS_LLC_MISS_RETIRED:LOCAL_DRAM,MEM_LOAD_UOPS_RETIRED:LOCAL_PMM"
  export SH_PROFILE_ALL_EVENTS="MEM_LOAD_UOPS_LLC_MISS_RETIRED:LOCAL_DRAM,MEM_LOAD_UOPS_RETIRED:LOCAL_PMM"

  # Turn on online
  export SH_PROFILE_ONLINE="1"
  export SH_PROFILE_ONLINE_SKIP_INTERVALS="$ONLINE_SKIP_INTERVALS"

  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 1`

  eval "${PRERUN}"

  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    export SH_PROFILE_ONLINE_OUTPUT_FILE="${DIR}/online.txt"
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
    if [ "$DO_MEMRESERVE" = true ]; then
      memreserve_kill
    fi
  done
}

function online_extent_size {
  CAP_SKIP_INTERVALS="$5"
  export SH_PROFILE_EXTENT_SIZE="1"
  export SH_PROFILE_EXTENT_SIZE_SKIP_INTERVALS="$CAP_SKIP_INTERVALS"

  online_base $@
}

function online_allocs {
  CAP_SKIP_INTERVALS="$5"
  export SH_PROFILE_ALLOCS="1"
  export SH_PROFILE_ALLOCS_SKIP_INTERVALS="$CAP_SKIP_INTERVALS"

  online_base $@
}

function online_rss {
  CAP_SKIP_INTERVALS="$5"
  export SH_PROFILE_RSS="1"
  export SH_PROFILE_RSS_SKIP_INTERVALS="$CAP_SKIP_INTERVALS"

  online_base $@
}

function online_memreserve_extent_size {
  DO_MEMRESERVE=true
  MEMRESERVE_RATIO="$6"

  online_extent_size $@
}

function online_memreserve_extent_size_nobind {
  DO_MEMRESERVE=true
  MEMRESERVE_RATIO="$6"

  export SH_PROFILE_ONLINE_NOBIND="1"

  online_extent_size $@
}

function online_memreserve_extent_size_gp1000 {
  DO_MEMRESERVE=true
  MEMRESERVE_RATIO="$6"

  export SH_PROFILE_ONLINE_GRACE_ACCESSES="1000"

  online_extent_size $@
}

function online_memreserve_allocs {
  DO_MEMRESERVE=true
  MEMRESERVE_RATIO="$6"

  online_allocs $@
}

function online_memreserve_rss {
  DO_MEMRESERVE=true
  MEMRESERVE_RATIO="$6"

  online_rss $@
}
