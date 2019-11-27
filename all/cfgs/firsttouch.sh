#!/bin/bash

DO_MEMRESERVE=false

function firsttouch {
  eval "${PRERUN}"

  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches
    if [ "$DO_MEMRESERVE" = true ]; then
      memreserve ${DIR} ${NUM_PAGES} ${SH_UPPER_NODE}
    fi
    pcm_background "${DIR}"
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    eval "${COMMAND}" &>> ${DIR}/stdout.txt
    numastat_kill
    pcm_kill
    if [ "$DO_MEMRESERVE" = true ]; then
      memreserve_kill
    fi
  done
}

function firsttouch_default {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  firsttouch $@
}

function firsttouch_lower_exclusive_device {
  export SH_DEFAULT_NODE="${SH_LOWER_NODE}"
  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  firsttouch $@
}

function firsttouch_exclusive_device {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  firsttouch $@
}

function firsttouch_lower_shared_site {
  export SH_DEFAULT_NODE="${SH_LOWER_NODE}"
  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  firsttouch $@
}

function firsttouch_shared_site {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  firsttouch $@
}

function firsttouch_memreserve_shared_site {
  # This just takes a percentage that should be left available on the upper tier
  RATIO=$(echo "${1}/100" | bc -l)
  CANARY_CFG="firsttouch_shared_site:"
  CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/i0/"

  # This is in kilobytes
  PEAK_RSS=`${SCRIPTS_DIR}/all/stat --metric=peak_rss_kbytes ${CANARY_DIR}`
  PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)

  # How many pages we need to be free on upper tier
  NUM_PAGES=$(echo "${PEAK_RSS} * ${RATIO} / 4" | bc)
  NUM_BYTES_FLOAT=$(echo "${PEAK_RSS} * ${RATIO} * 1024" | bc)
  NUM_BYTES=${NUM_BYTES_FLOAT%.*}

  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  DO_MEMRESERVE=true
  firsttouch
}
