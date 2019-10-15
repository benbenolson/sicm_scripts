#!/bin/bash

function online_allocs {
  FREQ="$1"
  RATE="$2" 
  SKIP_INTERVALS="$3"

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
  export SH_PROFILE_ALLOCS="1"
  export SH_PROFILE_ALLOCS_SKIP_INTERVALS="$SKIP_INTERVALS"

  # Turn on online
  export SH_PROFILE_ONLINE="1"
  export SH_PROFILE_ONLINE_EVENT="MEM_LOAD_UOPS_RETIRED:L3_MISS"

  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 4`

  eval "${PRERUN}"

  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
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

function online_extent_size {
  FREQ="$1"
  RATE="$2" 
  SKIP_INTERVALS="$3"

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
  export SH_PROFILE_EXTENT_SIZE_SKIP_INTERVALS="$SKIP_INTERVALS"

  # Turn on online
  export SH_PROFILE_ONLINE="1"
  export SH_PROFILE_ONLINE_EVENT="MEM_LOAD_UOPS_RETIRED:L3_MISS"

  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 4`

  eval "${PRERUN}"

  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
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

function online_rss {
  FREQ="$1"
  RATE="$2" 
  SKIP_INTERVALS="$3"

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
  export SH_PROFILE_RSS="1"
  export SH_PROFILE_RSS_SKIP_INTERVALS="$SKIP_INTERVALS"

  # Turn on online
  export SH_PROFILE_ONLINE="1"
  export SH_PROFILE_ONLINE_EVENT="MEM_LOAD_UOPS_RETIRED:L3_MISS"

  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 4`

  eval "${PRERUN}"

  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
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

# PEBS frequency, profiling rate, capacity skip intervals, online skip intervals, ratio on upper tier
function online_memreserve {
  FREQ="$1"
  RATE="$2"
  CAP_SKIP_INTERVALS="$3"
  ONLINE_SKIP_INTERVALS="$4"
  RATIO=$(echo "${5}/100" | bc -l)
  CANARY_CFG="firsttouch_all_shared_site:"
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
  export SH_PROFILE_ALLOCS="1"
  export SH_PROFILE_ALLOCS_SKIP_INTERVALS="$CAP_SKIP_INTERVALS"

  # Turn on online
  export SH_PROFILE_ONLINE="1"
  export SH_PROFILE_ONLINE_EVENT="MEM_LOAD_UOPS_RETIRED:L3_MISS"
  export SH_PROFILE_ONLINE_SKIP_INTERVALS="$ONLINE_SKIP_INTERVALS"
  export SH_PROFILE_ONLINE_PRINT_RECONFIGURES="1"

  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 4`

  eval "${PRERUN}"
  
  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches
    memreserve ${DIR} ${NUM_PAGES} ${SH_UPPER_NODE}
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    numastat -m &>> ${DIR}/numastat_before.txt
    eval "${COMMAND}" &>> ${DIR}/stdout.txt
    numastat_kill
    pcm_kill
    memreserve_kill
  done
}
