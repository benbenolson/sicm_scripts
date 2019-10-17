#!/bin/bash

################################################################################
#                            offline_all_pebs_guided                           #
################################################################################
function offline {
  PEBS_FREQ="$1"
  PEBS_SIZE="$2"
  PACK_ALGO="$3"

  CANARY_CFG="firsttouch_all_exclusive_device:"
  CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/i0/"
  PEBS_FILE="${BASEDIR}/../../${PEBS_SIZE}/pebs_${PEBS_FREQ}/i0/stdout.txt"

  # This file is used for the profiling information
  if [ ! -r "${PEBS_FILE}" ]; then
    echo "ERROR: The file '${PEBS_FILE}' doesn't exist yet. Aborting."
    exit
  fi

  # This file is used to get the peak RSS
  if [ ! -r "${CANARY_DIR}" ]; then
    echo "ERROR: The file '${CANARY_DIR}' doesn't exist yet. Aborting."
    exit
  fi

  # Get the amount of free memory in the upper tier right now
  COLUMN_NUMBER=$(echo ${SH_UPPER_NODE} + 2 | bc)
  UPPER_SIZE="$(numastat -m | awk -v column_number=${COLUMN_NUMBER} '/MemFree/ {printf "%d * 1024 * 1024\n", $column_number}' | bc)"

  # Get the peak RSS of the canary run
  PEAK_RSS=`${SCRIPTS_DIR}/all/stat --metric=peak_rss_kbytes ${CANARY_DIR}`
  PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)

  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="4096"
  export SH_DEFAULT_NODE="${SH_LOWER_NODE}"
  export SH_GUIDANCE_FILE="${BASEDIR}/guidance.txt"

  eval "${PRERUN}"

  # Generate the guidance file
  cat "${PEBS_FILE}" | \
    sicm_hotset acc ${PACK_ALGO} constant ${UPPER_SIZE} ${SH_UPPER_NODE} ${PEAK_RSS_BYTES} > \
      ${BASEDIR}/guidance.txt

  # Run the iterations
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
#                        offline_pebs_guided_percent                           #
################################################################################
# First argument is the frequency of PEBS sampling to use
# Second argument is the size of the PEBS sampling to use
# Third argument is the packing strategy
# Fourth argument is the percentage of the peak RSS that should be available on the node
# Fifth argument is the NUMA node to pack onto
# Sixth argument is the NUMA node to use as a lower tier
function offline_pebs_guided {
  PEBS_FREQ="$1"
  PEBS_SIZE="$2"
  PACK_ALGO="$3"
  RATIO=$(echo "${4}/100" | bc -l)
  NODE=${5}
  SLOWNODE=${6}
  if [[ "$(hostname)" = "JF1121-080209T" ]]; then
    CANARY_CFG="firsttouch_all_exclusive_device:1_3"
  else
    CANARY_CFG="firsttouch_all_exclusive_device:1_0"
  fi
  CANARY_STDOUT="${BASEDIR}/../${CANARY_CFG}/i0/stdout.txt"
  PEBS_FILE="${BASEDIR}/../../${PEBS_SIZE}/pebs:${PEBS_FREQ}/i0/stdout.txt"

  # This file is used for the profiling information
  if [ ! -r "${PEBS_FILE}" ]; then
    echo "ERROR: The file '${PEBS_FILE}' doesn't exist yet. Aborting."
    exit
  fi

  # This file is used to get the peak RSS
  if [ ! -r "${CANARY_STDOUT}" ]; then
    echo "ERROR: The file '${CANARY_STDOUT}' doesn't exist yet. Aborting."
    exit
  fi

  # This is in kilobytes
  PEAK_RSS=`${SCRIPTS_DIR}/all/stat --metric=peak_rss_kbytes ${CANARY_STDOUT}`
  echo "Got a peak RSS: ${PEAK_RSS}"
  PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)
  # How many pages we need to be free on MCDRAM
  NUM_PAGES=$(echo "${PEAK_RSS} * ${RATIO} / 4" | bc)
  NUM_BYTES_FLOAT=$(echo "${PEAK_RSS} * ${RATIO} * 1024" | bc)
  NUM_BYTES=${NUM_BYTES_FLOAT%.*}

  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="4096"
  export SH_DEFAULT_NODE=${SLOWNODE}
  export SH_GUIDANCE_FILE="${BASEDIR}/guidance.txt"
  export JE_MALLOC_CONF="oversize_threshold:0"

  eval "${PRERUN}"
  
  # Generate the hotset/knapsack/thermos
  #cat "${PEBS_FILE}" |  \
  #  sicm_hotset MEM_LOAD_UOPS_RETIRED:L3_MISS alloc_size ${PACK_ALGO} constant ${NUM_BYTES} 1 ${PEAK_RSS_BYTES} > ${BASEDIR}/guidance.txt
  if $MEMSYS; then
    cat "${PEBS_FILE}" |  \
      sicm_hotset pebs ${PACK_ALGO} constant ${NUM_BYTES} 1 ${PEAK_RSS_BYTES} > \
      ${BASEDIR}/guidance.txt
  else
    cat "${PEBS_FILE}" |  \
      sicm_hotset MEM_LOAD_UOPS_RETIRED:L3_MISS rss ${PACK_ALGO} constant ${NUM_BYTES} 1 ${PEAK_RSS_BYTES} > ${BASEDIR}/guidance.txt
  fi
  for i in {0..0}; do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches
    memreserve ${DIR} ${NUM_PAGES} ${NODE}
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    if [[ "$(hostname)" = "JF1121-080209T" ]]; then
      eval "env time -v numactl --cpunodebind=1 --membind=${NODE},${SLOWNODE} " "${COMMAND}" &>> ${DIR}/stdout.txt
    else
      eval "env time -v " "${COMMAND}" &>> ${DIR}/stdout.txt
    fi
    numastat_kill
    pcm_kill
    memreserve_kill
  done
}

