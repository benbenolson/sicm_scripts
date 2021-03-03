#!/bin/bash

DO_MEMRESERVE=false
DO_PER_NODE_MAX=false
DO_PER_NODE_MAX_FAKE=false

function ft {
  eval "${PRERUN}"

  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    export SH_PROFILE_OUTPUT_FILE="${DIR}/profile.txt"
    mkdir ${DIR}
    drop_caches_start
    if [ "$DO_MEMRESERVE" = true ]; then
      memreserve ${DIR} ${NUM_PAGES} ${SH_UPPER_NODE}
    fi
    pcm_background "${DIR}"
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    if [ "$DO_PER_NODE_MAX" = true ]; then
      per_node_max ${NUM_BYTES} real &> ${DIR}/stdout.txt
    elif [ "$DO_PER_NODE_MAX_FAKE" = true ]; then
      per_node_max ${NUM_BYTES} fake &> ${DIR}/stdout.txt
    else
      eval "${COMMAND}" &> ${DIR}/stdout.txt
    fi
    numastat_kill
    pcm_kill
    if [ "$DO_MEMRESERVE" = true ]; then
      memreserve_kill
    fi
    drop_caches_end
  done
}

function ft_def {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  ft $@
}

function ft_def2 {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  ft $@
}

function ft_low_ed {
  export SH_DEFAULT_NODE="${SH_LOWER_NODE}"
  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

function ft_ed {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

function ft_e {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="EXCLUSIVE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

function ft_one {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="ONE_ARENA"
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

function ft_e_debug {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="EXCLUSIVE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

function ft_4ed {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="EXCLUSIVE_FOUR_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

function ft_8ed {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="EXCLUSIVE_EIGHT_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

function ft_32ed {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="EXCLUSIVE_THIRTYTWO_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

function ft_64ed {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="EXCLUSIVE_SIXTYFOUR_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

function ft_low_ss {
  export SH_DEFAULT_NODE="${SH_LOWER_NODE}"
  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  ft $@
}

function ft_ss {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  ft $@
}

function ft_bsl {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304" # 4MB threshold
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

function ft_bsl_large {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="33554432" # 32MB threshold
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

function ft_bsl_objmap {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304" # 4MB threshold
  export SH_MAX_SITES_PER_ARENA="5000"
  
  ft $@
}

function ft_bsh {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="536870912" # 16MB threshold
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

function ft_bshh {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="1073741824" # 16MB threshold
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

function ft_bsl_debug {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304" # 4MB threshold
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

function ft_bss {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="1048576" # 4KB threshold
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

function ft_bss_debug {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="1048576" # 4KB threshold
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

function ft_mr_ss {
  # This just takes a percentage that should be left available on the upper tier
  RATIO=$(echo "${1}/100" | bc -l)
  CANARY_CFG="ft_def:"
  CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/"

  # This is in kilobytes
  PEAK_RSS=`${SCRIPTS_DIR}/all/stat --single="${CANARY_DIR}" --metric=peak_rss_kbytes`
  PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)

  # How many pages we need to be free on upper tier
  NUM_PAGES=$(echo "${PEAK_RSS} * ${RATIO} / 4" | bc)
  NUM_BYTES_FLOAT=$(echo "${PEAK_RSS} * ${RATIO} * 1024" | bc)
  NUM_BYTES=${NUM_BYTES_FLOAT%.*}

  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  DO_MEMRESERVE=true
  ft $@
}

function ft_mr_ed {
  # This just takes a percentage that should be left available on the upper tier
  RATIO=$(echo "${1}/100" | bc -l)
  CANARY_CFG="ft_def:"
  CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/"

  # This is in kilobytes
  PEAK_RSS=`${SCRIPTS_DIR}/all/stat --single="${CANARY_DIR}" --metric=peak_rss_kbytes`
  PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)

  # How many pages we need to be free on upper tier
  NUM_PAGES=$(echo "${PEAK_RSS} * ${RATIO} / 4" | bc)
  NUM_BYTES_FLOAT=$(echo "${PEAK_RSS} * ${RATIO} * 1024" | bc)
  NUM_BYTES=${NUM_BYTES_FLOAT%.*}

  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  DO_MEMRESERVE=true
  ft $@
}

function ft_mr_bsl {
  # This just takes a percentage that should be left available on the upper tier
  RATIO=$(echo "${1}/100" | bc -l)
  CANARY_CFG="ft_def:"
  CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/"

  # How many pages we need to be free on upper tier
  PEAK_RSS=`${SCRIPTS_DIR}/all/stat --single="${CANARY_DIR}" --metric=peak_rss_kbytes`
  PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)
  NUM_PAGES=$(echo "${PEAK_RSS} * ${RATIO} / 4" | bc)
  NUM_BYTES_FLOAT=$(echo "${PEAK_RSS} * ${RATIO} * 1024" | bc)
  NUM_BYTES=${NUM_BYTES_FLOAT%.*}

  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304" # 4MB threshold
  export SH_MAX_SITES_PER_ARENA="5000"
  DO_MEMRESERVE=true
  ft $@
}

function ft_pnm_bsl {
  # This just takes a percentage that should be left available on the upper tier
  RATIO=$(echo "${1}/100" | bc -l)
  CANARY_CFG="ft_def:"
  CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/"

  # How many pages we need to be free on upper tier
  PEAK_RSS=`${SCRIPTS_DIR}/all/stat --single="${CANARY_DIR}" --metric=peak_rss_kbytes`
  PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)
  NUM_PAGES=$(echo "${PEAK_RSS} * ${RATIO} / 4" | bc)
  NUM_BYTES_FLOAT=$(echo "${PEAK_RSS} * ${RATIO} * 1024" | bc)
  NUM_BYTES=${NUM_BYTES_FLOAT%.*}

  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304" # 4MB threshold
  export SH_MAX_SITES_PER_ARENA="5000"
  DO_PER_NODE_MAX=true
  ft $@
}

function ft_pnm_bsl_objmap {
  # This just takes a percentage that should be left available on the upper tier
  RATIO=$(echo "${1}/100" | bc -l)
  CANARY_CFG="ft_def:"
  CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/"

  # How many pages we need to be free on upper tier
  PEAK_RSS=`${SCRIPTS_DIR}/all/stat --single="${CANARY_DIR}" --metric=peak_rss_kbytes`
  PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)
  NUM_PAGES=$(echo "${PEAK_RSS} * ${RATIO} / 4" | bc)
  NUM_BYTES_FLOAT=$(echo "${PEAK_RSS} * ${RATIO} * 1024" | bc)
  NUM_BYTES=${NUM_BYTES_FLOAT%.*}

  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304" # 4MB threshold
  export SH_MAX_SITES_PER_ARENA="5000"
  
  # Enable OBJMAP profiling
  export SH_PROFILE_OBJMAP="1"
  export SH_PROFILE_OBJMAP_SKIP_INTERVALS="$3"
  export SH_PRINT_PROFILE_INTERVALS="1"
  export SH_MAX_SITES_PER_ARENA="5000"
  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 1`
  export SH_PROFILE_RATE_NSECONDS=$(echo "${2} * 1000000" | bc)
  
  DO_PER_NODE_MAX=true
  ft $@
}

function ft_mr_def {
  # This just takes a percentage that should be left available on the upper tier
  RATIO=$(echo "${1}/100" | bc -l)
  CANARY_CFG="ft_def:"
  CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/"

  # This is in kilobytes
  PEAK_RSS=`${SCRIPTS_DIR}/all/stat --single="${CANARY_DIR}" --metric=peak_rss_kbytes`
  PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)

  # How many pages we need to be free on upper tier
  NUM_PAGES=$(echo "${PEAK_RSS} * ${RATIO} / 4" | bc)
  NUM_BYTES_FLOAT=$(echo "${PEAK_RSS} * ${RATIO} * 1024" | bc)
  NUM_BYTES=${NUM_BYTES_FLOAT%.*}

  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  DO_MEMRESERVE=true
  ft $@
}
