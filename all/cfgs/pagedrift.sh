#!/bin/bash

DO_MEMRESERVE=false

function pagedrift_base {
  WAIT_SECONDS="${1}"
  PROFILE_TIME="${2}"
  FREQ="${3}"
  
  eval "${PRERUN}"
  
  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"

  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches_start
    if [ "$DO_MEMRESERVE" = true ]; then
      memreserve ${DIR} ${NUM_PAGES} ${SH_UPPER_NODE}
    fi
    pcm_background "${DIR}"
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    eval "${COMMAND}" &>> ${DIR}/stdout.txt &
    EVAL_PID="$!"
    sleep 5
    BENCH_PID=$(ps aux | grep "${BENCH_EXE_NAME}" | awk -v exe_name=${BENCH_EXE_NAME} '{ if($11 == exe_name) { print $2; } }')
    pagedrift_tool "${DIR}" "${WAIT_SECONDS}" "${PROFILE_TIME}" "${FREQ}" "${BENCH_PID}"
    wait ${EVAL_PID}
    
    # Kill everything
    numastat_kill
    pcm_kill
    drop_caches_end
    if [ "$DO_MEMRESERVE" = true ]; then
      memreserve_kill
    fi
  done
}

function pagedrift {
  export SH_DEFAULT_NODE="${SH_LOWER_NODE}"
  pagedrift_base $@
}

function pagedrift_memreserve {
  # This just takes a percentage that should be left available on the upper tier
  RATIO=$(echo "${4}/100" | bc -l)
  CANARY_CFG="firsttouch_exclusive_device:"
  CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/i0"

  # This is in kilobytes
  echo "${SCRIPTS_DIR}/all/stat --single --metric=peak_rss_kbytes ${CANARY_DIR}"
  PEAK_RSS=`${SCRIPTS_DIR}/all/stat --single --metric=peak_rss_kbytes ${CANARY_DIR}`
  echo "PEAK_RSS: ${PEAK_RSS}"
  PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)

  # How many pages we need to be free on upper tier
  NUM_PAGES=$(echo "${PEAK_RSS} * ${RATIO} / 4" | bc)
  NUM_BYTES_FLOAT=$(echo "${PEAK_RSS} * ${RATIO} * 1024" | bc)
  NUM_BYTES=${NUM_BYTES_FLOAT%.*}

  export SH_DEFAULT_NODE="${SH_LOWER_NODE}"
  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  
  DO_MEMRESERVE=true
  pagedrift_base $@
}
