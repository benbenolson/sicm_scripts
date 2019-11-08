#!/bin/bash

function offline {
  PEBS_SIZE="$1"
  PEBS_FREQ="$2"
  PEBS_RATE="$3"
  CAP_INTERVAL="$4"
  PACK_ALGO="$5"

  CANARY_CFG="firsttouch_all_exclusive_device:"
  CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/i0/"
  PEBS_DIR="${BASEDIR}/../../${PEBS_SIZE}/profile_all_and_allocs:${PEBS_FREQ}_${PEBS_RATE}_${CAP_INTERVAL}/i0/"
  PEBS_FILE="${PEBS_DIR}/stdout.txt"

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
  PEAK_RSS_CANARY=`${SCRIPTS_DIR}/all/stat --metric=peak_rss_kbytes ${CANARY_DIR}`
  PEAK_RSS_CANARY_BYTES=$(echo "${PEAK_RSS_CANARY} * 1024" | bc)

  # Get the peak RSS of the profiling run
  PEAK_RSS_PROFILING=`${SCRIPTS_DIR}/all/stat --metric=peak_rss_kbytes ${PEBS_DIR}`
  PEAK_RSS_PROFILING_BYTES=$(echo "${PEAK_RSS_PROFILING} * 1024" | bc)

  # Now get the ratio that we should scale the sites' weights down by
  SCALE=$(echo "${PEAK_RSS_CANARY_BYTES} / ${PEAK_RSS_PROFILING_BYTES}" | bc -l)

  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="4096"
  export SH_DEFAULT_NODE="${SH_LOWER_NODE}"
  export SH_GUIDANCE_FILE="${BASEDIR}/guidance.txt"

  eval "${PRERUN}"

  # Generate the guidance file
  cat "${PEBS_FILE}" | \
    sicm_hotset --capacity=${UPPER_SIZE} --scale=${SCALE} --verbose \
    > ${BASEDIR}/guidance.txt

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
