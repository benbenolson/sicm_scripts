#!/bin/bash

DO_MEMRESERVE=false
DO_SCALE=true
CAPACITY_PROF_TYPE=""
VALUE_PROF_TYPE=""
ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"

function off_base {
  PACKING_ALGO="$1"

  CANARY_CFG="ft_ed:"
  CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/i0/"
  PEBS_DIR="${PROFILE_DIR}/"
  PEBS_FILE="${PEBS_DIR}/profile.txt"

  # This file is used for the profiling information
  if [ ! -f "${PEBS_FILE}" ]; then
    echo "ERROR: The file '${PEBS_FILE}' doesn't exist yet. Aborting."
    exit
  fi

  # This file is used to get the peak RSS
  if [ ! -r "${CANARY_DIR}" ]; then
    echo "ERROR: The file '${CANARY_DIR}' doesn't exist yet. Aborting."
    exit
  fi

  # Get the peak RSS of the canary run
  PEAK_RSS_CANARY=`${SCRIPTS_DIR}/all/stat --single="${CANARY_DIR}" --metric=peak_rss_kbytes`
  PEAK_RSS_CANARY_BYTES=$(echo "${PEAK_RSS_CANARY} * 1024" | bc)

  # Get the peak RSS of the profiling run
  PEAK_RSS_PROFILING=`${SCRIPTS_DIR}/all/stat --single="${PEBS_DIR}" --metric=peak_rss_kbytes`
  PEAK_RSS_PROFILING_BYTES=$(echo "${PEAK_RSS_PROFILING} * 1024" | bc)

  if [ "$DO_SCALE" = true ]; then
    # Now get the ratio that we should scale the sites' weights down by
    SCALE=$(echo "${PEAK_RSS_CANARY_BYTES} / ${PEAK_RSS_PROFILING_BYTES}" | bc -l)
  fi

  export SH_ARENA_LAYOUT="${ARENA_LAYOUT}"
  export SH_MAX_SITES_PER_ARENA="4096"
  export SH_DEFAULT_NODE="${SH_LOWER_NODE}"
  export SH_GUIDANCE_FILE="${BASEDIR}/guidance.txt"

  eval "${PRERUN}"

  # Generate the guidance file
  HOTSET_ARGS="--capacity=${NUM_BYTES} --node=${SH_UPPER_NODE} --verbose"
  if [ "$DO_SCALE" = true ]; then
    HOTSET_ARGS="${HOTSET_ARGS} --scale=${SCALE}"
  fi
  if [[ ! -z ${CAPACITY_PROF_TYPE} ]]; then
    HOTSET_ARGS="${HOTSET_ARGS} --weight=${CAPACITY_PROF_TYPE}"
  fi
  if [[ ! -z ${VALUE_PROF_TYPE} ]]; then
    echo "${VALUE_PROF_TYPE}"
    HOTSET_ARGS="${HOTSET_ARGS} --value=${VALUE_PROF_TYPE}"
  fi
  HOTSET_ARGS="${HOTSET_ARGS} --algo=${PACKING_ALGO}"
  cat "${PEBS_FILE}" | \
    sicm_hotset ${HOTSET_ARGS} \
    > ${BASEDIR}/guidance.txt

  # Run the iterations
  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches_start
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
    drop_caches_end
  done
}

function off {
  # Get the amount of free memory in the upper tier right now
  COLUMN_NUMBER=$(echo ${SH_UPPER_NODE} + 2 | bc)
  UPPER_SIZE="$(numastat -m | awk -v column_number=${COLUMN_NUMBER} '/MemFree/ {printf "%d * 1024 * 1024\n", $column_number}' | bc)"
  NUM_BYTES=${UPPER_SIZE}

  off_base $@
}

function off_mr {
  RATIO=$(echo "${2}/100" | bc -l)
  CANARY_CFG="ft_ed:"
  CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/i0/"

  # This is in kilobytes
  PEAK_RSS=`${SCRIPTS_DIR}/all/stat --single --metric=peak_rss_kbytes ${CANARY_DIR}`
  PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)

  # How many pages we need to be free on upper tier
  NUM_PAGES=$(echo "${PEAK_RSS} * ${RATIO} / 4" | bc)
  NUM_BYTES_FLOAT=$(echo "${PEAK_RSS} * ${RATIO} * 1024" | bc)
  NUM_BYTES=${NUM_BYTES_FLOAT%.*}

  DO_MEMRESERVE=true
  off_base "$@"
}

function off_mr_all {
  VALUE_PROF_TYPE="profile_all_total"
  off_mr $@
}

function off_mr_bw_relative {
  VALUE_PROF_TYPE="profile_bw_relative_total"
  off_mr $@
}

function off_mr_all_rss {
  DO_SCALE=false
  CAPACITY_PROF_TYPE="profile_rss_peak"
  off_mr_all $@
}

function off_mr_all_es {
  CAPACITY_PROF_TYPE="profile_extent_size_peak"
  off_mr_all $@
}

function off_mr_bw_relative_rss {
  DO_SCALE=false
  CAPACITY_PROF_TYPE="profile_rss_peak"
  off_mr_bw_relative $@
}

function off_mr_bw_relative_es {
  CAPACITY_PROF_TYPE="profile_extent_size_peak"
  off_mr_bw_relative $@
}
