#!/bin/bash

################################################################################
#                                 offline_all_manual                           #
################################################################################
# First argument is results directory
# Second argument is the command to run
# Third argument is the NUMA node to pack onto
# Fourth argument is the NUMA node to use as a lower tier
# This config expects you to install `guidance.txt` in the right place manually.
function offline_all_manual {
  NODE=${1}
  SLOWNODE=${2}

  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="4096"
  export SH_DEFAULT_NODE="${SLOWNODE}"
  export SH_GUIDANCE_FILE="${BASEDIR}/guidance.txt"
  export JE_MALLOC_CONF="oversize_threshold:0"

  eval "${PRERUN}"
  
  for i in {0..0}; do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    if [[ "$(hostname)" = "JF1121-080209T" ]]; then
      eval "env time -v numactl --cpunodebind=${NODE} " "${COMMAND}" #&>> ${DIR}/stdout.txt
    else
      eval "env time -v " "${COMMAND}" &>> ${DIR}/stdout.txt
    fi
    numastat_kill
    pcm_kill
    memreserve_kill
  done
}

function offline_manual {
  BASEDIR="$1"
  COMMAND="$2"
  RATIO=$(echo "${3}/100" | bc -l)
  NODE=${4}
  SLOWNODE=${5}
  CANARY_CFG="firsttouch_all_exclusive_device_${NODE}_${SLOWNODE}"
  CANARY_STDOUT="${BASEDIR}/../${CANARY_CFG}/i0/stdout.txt"

  # This file is used to get the peak RSS
  if [ ! -r "${CANARY_STDOUT}" ]; then
    echo "ERROR: The file '${CANARY_STDOUT}' doesn't exist yet. Aborting."
    exit
  fi

  # This is in kilobytes
  PEAK_RSS=$(${SCRIPTS_DIR}/stat.sh ${CANARY_STDOUT} rss_kbytes)
  PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)
  # How many pages we need to be free on MCDRAM
  NUM_PAGES=$(echo "${PEAK_RSS} * ${RATIO} / 4" | bc)
  NUM_BYTES_FLOAT=$(echo "${PEAK_RSS} * ${RATIO} * 1024" | bc)
  NUM_BYTES=${NUM_BYTES_FLOAT%.*}

  # User output
  echo "Running experiment:"
  echo "  Config: 'offline_pebs_guided'"
  echo "  Percentage: '${3}%'"
  echo "  Node: ${NODE}"
  echo "  Slow node: ${SLOWNODE}"
  echo "  Packing into bytes: '${NUM_BYTES}'"
  echo "  Scaling down to peak RSS: '${PEAK_RSS}'"

  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="4096"
  export SH_DEFAULT_NODE="${SLOWNODE}"
  export SH_GUIDANCE_FILE="${BASEDIR}/guidance.txt"
  export JE_MALLOC_CONF="oversize_threshold:0"

  eval "${PRERUN}"
  
  for i in {0..4}; do
    DIR="${BASEDIR}/i${i}"
    rm -rf ${DIR}
    mkdir ${DIR}
    drop_caches
    memreserve ${DIR} ${NUM_PAGES} ${NODE}
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    eval "env time -v numactl --cpunodebind=${NODE} --membind=${NODE},${SLOWNODE} " "${COMMAND}" &>> ${DIR}/stdout.txt
    #echo ${COMMAND}
    #eval "env time -v numactl --cpunodebind=${NODE} --membind=${NODE},${SLOWNODE} " "gdb ./lulesh2.0"
    numastat_kill
    pcm_kill
    memreserve_kill
  done
}

