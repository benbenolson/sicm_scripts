#!/bin/bash

################################################################################
#                        offline_pebs_guided_percent                           #
################################################################################
# First argument is results directory
# Second argument is the command to run
# Third argument is the frequency of PEBS sampling to use
# Fourth argument is the size of the PEBS sampling to use
# Fifth argument is the packing strategy
# Sixth argument is the percentage of the peak RSS that should be available on the node
# Seventh argument is the NUMA node to pack onto
function offline_pebs_guided {
  BASEDIR="$1"
  COMMAND="$2"
  PEBS_FREQ="$3"
  PEBS_SIZE="$4"
  PACK_ALGO="$5"
  RATIO=$(echo "${6}/100" | bc -l)
  NODE=${7}
  CANARY_CFG="firsttouch_all_exclusive_device_0_0"
  CANARY_STDOUT="${BASEDIR}/../${CANARY_CFG}/i0/stdout.txt"
  PEBS_FILE="${BASEDIR}/../../${PEBS_SIZE}/pebs_${PEBS_FREQ}/i0/stdout.txt"

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
  PEAK_RSS=$(${SCRIPTS_DIR}/stat.sh ${CANARY_STDOUT} rss_kbytes)
  PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)
  # How many pages we need to be free on MCDRAM
  NUM_PAGES=$(echo "${PEAK_RSS} * ${RATIO} / 4" | bc)
  NUM_BYTES_FLOAT=$(echo "${PEAK_RSS} * ${RATIO} * 1024" | bc)
  NUM_BYTES=${NUM_BYTES_FLOAT%.*}

  # User output
  echo "Running experiment:"
  echo "  Config: 'offline_pebs_guided'"
  echo "  Profiling frequency: '${PEBS_FREQ}'"
  echo "  Profiling size: '${PEBS_SIZE}'"
  echo "  Packing algorithm: '${PACK_ALGO}'"
  echo "  Percentage: '${6}%'"
  echo "  Packing into bytes: '${NUM_BYTES}'"
  echo "  Scaling down to peak RSS: '${PEAK_RSS}'"

  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="4096"
  export SH_DEFAULT_NODE="0"
  export SH_GUIDANCE_FILE="${BASEDIR}/guidance.txt"
  export JE_MALLOC_CONF="oversize_threshold:0"

  eval "${PRERUN}"
  
  # Generate the hotset/knapsack/thermos
  cat "${PEBS_FILE}" | \
    sicm_hotset pebs ${PACK_ALGO} constant ${NUM_BYTES} 1 ${PEAK_RSS_BYTES} > \
      ${BASEDIR}/guidance.txt
  for i in {0..0}; do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches
    memreserve ${DIR} ${NUM_PAGES} ${NODE}
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    eval "env time -v " "${COMMAND}" &>> ${DIR}/stdout.txt
    numastat_kill
    pcm_kill
    memreserve_kill
  done
}

################################################################################
#                        offline_pebs_guided                                   #
################################################################################
# First argument is results directory
# Second argument is the command to run
# Third argument is the frequency of PEBS sampling to use
# Fourth argument is the size of PEBS profiling run to use
# Fifth argument is the packing strategy
function offline_all_pebs_guided {
  BASEDIR="$1"
  COMMAND="$2"
  PEBS_FREQ="$3"
  PEBS_SIZE="$4"
  PACK_ALGO="$5"
  PEAK_RSS_FILE="${BASEDIR}/../firsttouch_all_exclusive_device_0_0/i0/stdout.txt"
  PEBS_FILE="${BASEDIR}/../../${PEBS_SIZE}/pebs_${PEBS_FREQ}/i0/stdout.txt"

  # This file is used for the profiling information
  if [ ! -r "${PEBS_FILE}" ]; then
    echo "ERROR: The file '${PEBS_FILE}' doesn't exist yet. Aborting."
    exit
  fi

  # This file is used to get the peak RSS
  if [ ! -r "${PEAK_RSS_FILE}" ]; then
    echo "ERROR: The file '${PEAK_RSS_FILE}' doesn't exist yet. Aborting."
    exit
  fi

  MCDRAM_SIZE="$(numastat -m | awk '/MemFree/ {printf "%d * 1024 * 1024\n", $3}' | bc)"
  PEAK_RSS_KBYTES=$(${SCRIPTS_DIR}/stat.sh ${PEAK_RSS_FILE} rss_kbytes)
  PEAK_RSS=$(echo "${PEAK_RSS_KBYTES} * 1024" | bc)

  # User output
  echo "Running experiment:"
  echo "  Config: 'offline_all_pebs_guided'"
  echo "  Profiling frequency: '${PEBS_FREQ}'"
  echo "  Profiling size: '${PEBS_SIZE}'"
  echo "  Packing algorithm: '${PACK_ALGO}'"
  echo "  Packing into MCDRAM: '${MCDRAM_SIZE}'"
  
  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="4096"
  export SH_DEFAULT_NODE="0"
  export SH_GUIDANCE_FILE="${BASEDIR}/guidance.txt"
  export JE_MALLOC_CONF="oversize_threshold:0"

  eval "${PRERUN}"
  
  cat "${PEBS_FILE}" | \
    sicm_hotset pebs ${PACK_ALGO} constant ${MCDRAM_SIZE} 1 ${PEAK_RSS} > \
    ${BASEDIR}/guidance.txt
  for i in {0..0}; do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    eval "env time -v " "${COMMAND}" &>> ${DIR}/stdout.txt
    numastat_kill
    pcm_kill
  done
}
