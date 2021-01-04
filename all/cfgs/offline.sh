#!/bin/bash

DO_MEMRESERVE=false
DO_PER_NODE_MAX=false
DO_PER_NODE_MAX_FAKE=false
DO_SCALE=true
CAPACITY_PROF_TYPE=""
VALUE_PROF_TYPE=""
ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
MANUAL=false

function off_base {
  PACKING_ALGO="$1"
  
  CANARY_CFG="ft_def:"
  CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/"
  PEBS_DIR="${PROFILE_DIR}/"
  PEBS_FILE="${PEBS_DIR}/i0/profile.txt"

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
  echo "PEAK_RSS_CANARY=${PEAK_RSS_CANARY}"

  # Get the peak RSS of the profiling run
  PEAK_RSS_PROFILING=`${SCRIPTS_DIR}/all/stat --single="${PEBS_DIR}" --metric=peak_rss_kbytes`
  PEAK_RSS_PROFILING_BYTES=$(echo "${PEAK_RSS_PROFILING} * 1024" | bc)
  echo "PEAK_RSS_PROFILING=${PEAK_RSS_PROFILING}"

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
  HOTSET_ARGS="--capacity=${NUM_BYTES} --node=${SH_UPPER_NODE}"
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
  
  if [ "$MANUAL" = false ]; then
    echo "${HOTSET_ARGS}"
    cat "${PEBS_FILE}" | \
      sicm_hotset ${HOTSET_ARGS} \
      > ${BASEDIR}/guidance.txt
  fi

  # Run the iterations
  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    export SH_PROFILE_OUTPUT_FILE="${DIR}/profile.txt"
    mkdir ${DIR}
    drop_caches_start
    if [ "$DO_MEMRESERVE" = true ]; then
      memreserve ${DIR} ${NUM_PAGES} ${SH_UPPER_NODE}
    fi
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    if [ "$DO_PER_NODE_MAX" = true ]; then
      per_node_max ${NUM_BYTES} real &>> ${DIR}/stdout.txt
    elif [ "$DO_PER_NODE_MAX_FAKE" = true ]; then
      per_node_max ${NUM_BYTES} fake &>> ${DIR}/stdout.txt
    else
      eval "${COMMAND}" &>> ${DIR}/stdout.txt
    fi
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

function off_pnmf {
  RATIO=$(echo "${2}/100" | bc -l)
  CANARY_CFG="ft_def:"
  CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/"

  # This is in kilobytes
  PEAK_RSS=`${SCRIPTS_DIR}/all/stat --single=${CANARY_DIR} --metric=peak_rss_kbytes`
  PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)
  echo "PEAK_RSS=${PEAK_RSS}"

  # How many pages we need to be free on upper tier
  NUM_PAGES=$(echo "${PEAK_RSS} * ${RATIO} / 4" | bc)
  NUM_BYTES_FLOAT=$(echo "${PEAK_RSS} * ${RATIO} * 1024" | bc)
  NUM_BYTES=${NUM_BYTES_FLOAT%.*}
  echo "NUM_BYTES=${NUM_BYTES}"

  export DO_PER_NODE_MAX_FAKE=true
  off_base "$@"
}

function off_mr {
  RATIO=$(echo "${2}/100" | bc -l)
  CANARY_CFG="ft_def:"
  CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/"

  # This is in kilobytes
  PEAK_RSS=`${SCRIPTS_DIR}/all/stat --single=${CANARY_DIR} --metric=peak_rss_kbytes`
  PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)
  echo "PEAK_RSS=${PEAK_RSS}"

  # How many pages we need to be free on upper tier
  NUM_PAGES=$(echo "${PEAK_RSS} * ${RATIO} / 4" | bc)
  NUM_BYTES_FLOAT=$(echo "${PEAK_RSS} * ${RATIO} * 1024" | bc)
  NUM_BYTES=${NUM_BYTES_FLOAT%.*}
  echo "NUM_BYTES=${NUM_BYTES}"

  DO_MEMRESERVE=true
  off_base "$@"
}

function off_pnm {
  RATIO=$(echo "${2}/100" | bc -l)
  CANARY_CFG="ft_def:"
  CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/"

  # This is in kilobytes
  PEAK_RSS=`${SCRIPTS_DIR}/all/stat --single=${CANARY_DIR} --metric=peak_rss_kbytes`
  PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)
  echo "PEAK_RSS=${PEAK_RSS}"

  # How many pages we need to be free on upper tier
  NUM_PAGES=$(echo "${PEAK_RSS} * ${RATIO} / 4" | bc)
  NUM_BYTES_FLOAT=$(echo "${PEAK_RSS} * ${RATIO} * 1024" | bc)
  NUM_BYTES=${NUM_BYTES_FLOAT%.*}
  echo "NUM_BYTES=${NUM_BYTES}"

  DO_PER_NODE_MAX=true
  off_base "$@"
}

function off_all {
  VALUE_PROF_TYPE="profile_all_total"
  off_base $@
}

function off_mr_all {
  VALUE_PROF_TYPE="profile_all_total"
  off_mr $@
}

function off_pnmf_all {
  VALUE_PROF_TYPE="profile_all_total"
  off_pnmf $@
}

function off_pnm_all {
  VALUE_PROF_TYPE="profile_all_total"
  off_pnm $@
}

function off_pnm_bwr {
  VALUE_PROF_TYPE="profile_bw_relative_total"
  off_pnm $@
}

function off_mr_bw_relative {
  VALUE_PROF_TYPE="profile_bw_relative_total"
  off_mr $@
}

function off_mr_all_rss_ed {
  DO_SCALE=false
  CAPACITY_PROF_TYPE="profile_rss_peak"
  ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  off_mr_all $@
}

function off_mr_all_rss_bsl {
  DO_SCALE=false
  CAPACITY_PROF_TYPE="profile_rss_peak"
  ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304"
  off_mr_all $@
}

function off_mr_all_objmap_bsl {
  DO_SCALE=false
  CAPACITY_PROF_TYPE="profile_objmap_peak"
  ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304"
  off_mr_all $@
}

function off_mr_all_objmap_ss {
  DO_SCALE=false
  CAPACITY_PROF_TYPE="profile_objmap_peak"
  ARENA_LAYOUT="SHARED_SITE_ARENAS"
  off_mr_all $@
}

function off_pnm_all_objmap_bsl {
  DO_SCALE=false
  CAPACITY_PROF_TYPE="profile_objmap_peak"
  ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304"
  off_pnm_all $@
}

function off_pnm_bwr_objmap_bsl {
  DO_SCALE=false
  CAPACITY_PROF_TYPE="profile_objmap_peak"
  ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304"
  off_pnm_bwr $@
}

function off_pnm_bwr_objmap_bsl_manual {
  DO_SCALE=false
  CAPACITY_PROF_TYPE="profile_objmap_peak"
  ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304"
  off_pnm_bwr $@
}

function off_pnm_all_objmap_ss {
  DO_SCALE=false
  CAPACITY_PROF_TYPE="profile_objmap_peak"
  ARENA_LAYOUT="SHARED_SITE_ARENAS"
  off_pnm_all $@
}

function off_all_objmap_bsl {
  DO_SCALE=false
  CAPACITY_PROF_TYPE="profile_objmap_peak"
  ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304"
  off_pnmf_all $@
}

function off_all_objmap_ss {
  DO_SCALE=false
  CAPACITY_PROF_TYPE="profile_objmap_peak"
  ARENA_LAYOUT="SHARED_SITE_ARENAS"
  off_pnmf_all $@
}

function off_pnm_all_objmap_bsl_manual {
  DO_SCALE=false
  CAPACITY_PROF_TYPE="profile_objmap_peak"
  ARENA_LAYOUT="BIG_SMALL_ARENAS"
  MANUAL=true
  export SH_BIG_SMALL_THRESHOLD="4194304"
  off_pnm_all $@
}

function off_mr_all_rss_bsl_manual {
  DO_SCALE=false
  CAPACITY_PROF_TYPE="profile_rss_peak"
  ARENA_LAYOUT="BIG_SMALL_ARENAS"
  MANUAL=true
  export SH_BIG_SMALL_THRESHOLD="4194304"
  off_mr_all $@
}

function off_all_objmap_bsl_manual {
  DO_SCALE=false
  CAPACITY_PROF_TYPE="profile_objmap_peak"
  ARENA_LAYOUT="BIG_SMALL_ARENAS"
  MANUAL=true
  export SH_BIG_SMALL_THRESHOLD="4194304"
  off_pnmf_all $@
}

function off_all_objmap_ss_manual {
  DO_SCALE=false
  CAPACITY_PROF_TYPE="profile_objmap_peak"
  ARENA_LAYOUT="SHARED_SITE_ARENAS"
  MANUAL=true
  off_pnmf_all $@
}

function off_on_mr_all_rss_bsl {
  off_mr_all_rss_bsl $@
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
