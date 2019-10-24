#!/bin/bash

################################################################################
#                    firsttouch_all_exclusive_device                           #
################################################################################
function firsttouch_all_exclusive_device {
  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"

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

################################################################################
#                        firsttouch_all_default                                #
################################################################################
function firsttouch_all_default {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"

  eval "${PRERUN}"

  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    numastat -m &>> ${DIR}/numastat_before.txt
    eval "${COMMAND}"  &>> ${DIR}/stdout.txt
    numastat_kill
    pcm_kill
  done
}


################################################################################
#                    firsttouch_all_shared_site                                #
################################################################################
function firsttouch_all_shared_site {
  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"

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

################################################################################
#                           firsttouch_all_big_small                           #
################################################################################
# Argument is the number of bytes to use as a threshold for big/small
function firsttouch_all_big_small {
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="${1}"
  export SH_MAX_SITES_PER_ARENA="5000"
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"

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

# Ratio available on upper tier
function firsttouch_shared_site_memreserve {
  RATIO=$(echo "${1}/100" | bc -l)
  CANARY_CFG="firsttouch_all_shared_site:"
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

  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  export SH_DEFAULT_NODE=${SH_UPPER_NODE}

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
