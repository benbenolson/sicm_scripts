#!/bin/bash

# Arguments:
# 1. Packing algorithm (hotset, thermos).
# 2. PEBS Frequency (16, 128).
# 3. Profiling interval length (10, 100, 1000) (in ms).
# 4. The number of online skip intervals (10, 100, 1000) (in intervals).
# 5. The number of capacity skip intervals (10, 100, 1000) (in intervals).
# ONLY IF USING MEMRESERVE:
# 6. Arena layout to use for determining the percentage of RSS to reserve (share, excl, def).
# 7. Percentage of peak RSS to leave available with memreserve.

DO_MEMRESERVE=false
DO_DEBUG=false
MEMRESERVE_RATIO=""
CAPACITY_SKIP_INTERVALS=""

function online_base {
  PACKING_ALGO="$1"
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

  # Value profiling
  export SH_PROFILE_ALL="1"
  export SH_MAX_SAMPLE_PAGES="2048"
  export SH_SAMPLE_FREQ="${FREQ}"
  export SH_PROFILE_RATE_NSECONDS=$(echo "${RATE} * 1000000" | bc)
  export SH_PROFILE_ALL_EVENTS="MEM_LOAD_UOPS_LLC_MISS_RETIRED:LOCAL_DRAM,MEM_LOAD_UOPS_RETIRED:LOCAL_PMM"
  export SH_PROFILE_ALL_MULTIPLIERS="1,5"
  
  export SH_PROFILE_BW="1"
  export SH_PROFILE_BW_IMC="skx_unc_imc0,skx_unc_imc1,skx_unc_imc2,skx_unc_imc3,skx_unc_imc4,skx_unc_imc5"
  export SH_PROFILE_BW_EVENTS="UNC_M_CAS_COUNT:RD"
  export SH_PROFILE_BW_SKIP_INTERVALS="1"
  export SH_PROFILE_BW_RELATIVE="1"

  # Turn on online
  export SH_PROFILE_ONLINE="1"
  export SH_PROFILE_ONLINE_WEIGHTS="1,5"
  export SH_PROFILE_ONLINE_EVENTS="MEM_LOAD_UOPS_LLC_MISS_RETIRED:LOCAL_DRAM,MEM_LOAD_UOPS_RETIRED:LOCAL_PMM"
  export SH_PROFILE_ONLINE_SKIP_INTERVALS="$ONLINE_SKIP_INTERVALS"
  export SH_PROFILE_ONLINE_PACKING_ALGO="$PACKING_ALGO"

  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 1`

  eval "${PRERUN}"

  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    if [ "$DO_DEBUG" = true ]; then
      export SH_PROFILE_ONLINE_DEBUG_FILE="${DIR}/online.txt"
      export SH_PRINT_PROFILE_INTERVALS="1"
    fi
    export SH_PROFILE_OUTPUT_FILE="${DIR}/profile.txt"
    drop_caches
    if [ "$DO_MEMRESERVE" = true ]; then
      memreserve ${DIR} ${NUM_PAGES} ${SH_UPPER_NODE}
    fi
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    #pcm_background "${DIR}"
    eval "${COMMAND}" &>> ${DIR}/stdout.txt
    numastat_kill
    #pcm_kill
    if [ "$DO_MEMRESERVE" = true ]; then
      memreserve_kill
    fi
  done
}

function online_memreserve_extent_size {
  export SH_PROFILE_EXTENT_SIZE="1"
  export SH_PROFILE_EXTENT_SIZE_SKIP_INTERVALS="$5"
  export CAPACITY_SKIP_INTERVALS="$5"
  
  DO_MEMRESERVE=true
  CANARY_LAYOUT="$6"
  MEMRESERVE_RATIO="$7"

  online_base $@
}

function online_memreserve_rss {
  export SH_PROFILE_RSS="1"
  export SH_PROFILE_RSS_SKIP_INTERVALS="$5"
  export CAPACITY_SKIP_INTERVALS="$5"
  
  DO_MEMRESERVE=true
  CANARY_LAYOUT="$6"
  MEMRESERVE_RATIO="$7"

  online_base $@
}

function online_rss {
  export SH_PROFILE_RSS="1"
  export SH_PROFILE_RSS_SKIP_INTERVALS="$5"
  export CAPACITY_SKIP_INTERVALS="$5"
  
  online_base $@
}

function online_memreserve_rss_ski {
  export SH_PROFILE_ONLINE_STRAT_SKI="1"

  online_memreserve_rss $@
}

function online_memreserve_rss_ski_debug {
  DO_DEBUG=true

  online_memreserve_rss_ski $@
}

function online_memreserve_extent_size_ski {
  export SH_PROFILE_ONLINE_STRAT_SKI="1"

  online_memreserve_extent_size $@
}

function online_memreserve_extent_size_ski_debug {
  DO_DEBUG=true

  online_memreserve_extent_size_ski $@
}

function online_rss_ski {
  online_rss $@
}

function online_rss_ski_debug {
  DO_DEBUG=true
  
  online_rss_ski $@
}
