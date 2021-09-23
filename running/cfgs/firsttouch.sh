#!/bin/bash

DO_PER_NODE_MAX=false

function ft {
  eval "${PRERUN}"

  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    export SH_PROFILE_OUTPUT_FILE="${DIR}/profile.txt"
    mkdir ${DIR}
    drop_caches_start
    pcm_background "${DIR}"
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    if [ "$DO_PER_NODE_MAX" = true ]; then
      per_node_max ${NUM_BYTES} &> ${DIR}/stdout.txt
    else
      per_node_max max &> ${DIR}/stdout.txt
    fi
    numastat_kill
    pcm_kill
    drop_caches_end
  done
}

function ft_def {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  ft $@
}

function ft_def_15th {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 1`
  ft $@
}

function ft_ed {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

function ft_ss {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  ft $@
}

function ft_bsl_15th {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304" # 4MB threshold
  export SH_MAX_SITES_PER_ARENA="5000"
  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 1`
  ft $@
}

function ft_bsl {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304" # 4MB threshold
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

function ft_bsl_nodalloc {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304" # 4MB threshold
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

function ft_bsl_mm {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304" # 4MB threshold
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

function ft_bsl_mm_newpcm {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304" # 4MB threshold
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

function ft_bsl_mm_thp {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304" # 4MB threshold
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

function ft_bsl_mm_ht {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304" # 4MB threshold
  export SH_MAX_SITES_PER_ARENA="5000"
  ft $@
}

############################################################
# PER_NODE_MAX
# These limit the size of the upper tier using a kernel
# patch that I called PER_NODE_MAX, implemented in `cgroups`.
# The requirement, though, is that you have a previous
# run of the application.
############################################################

function ft_pnm_base {
  RATIO=$(echo "${1}/100" | bc -l)
  CANARY_CFG="ft_def"
  CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/"
  DO_PER_NODE_MAX=true

  # NOTE: here, we'll call the `stat` program, which is needed to get the peak RSS
  # of the previous run.
  PEAK_RSS=`${SCRIPTS_DIR}/reporting/report --single="${CANARY_DIR}" --metric=peak_rss_kbytes`
  PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)
  NUM_BYTES_FLOAT=$(echo "${PEAK_RSS} * ${RATIO} * 1024" | bc)
  NUM_BYTES=${NUM_BYTES_FLOAT%.*}
  
  ft $@
}

function ft_pnm_bsl {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304" # 4MB threshold
  export SH_MAX_SITES_PER_ARENA="5000"
  ft_pnm_base $@
}

function ft_pnm_def {
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  ft_pnm_base $@
}
