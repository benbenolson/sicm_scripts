#!/bin/bash

DO_MEMRESERVE=false
DO_DEBUG=false
MEMRESERVE_RATIO=""
DO_PER_NODE_MAX=false

function on_base {
  FREQ="$1"
  RATE="$2"
  CAPACITY_SKIP_INTERVALS="$3"
  ONLINE_SKIP_INTERVALS="$4"
  PACKING_ALGO="$5"
  
  # This whole bit is only necessary if we're going to artificially limit
  # one of the memory tiers
  if [ "$DO_MEMRESERVE" = true ] || [ "$DO_PER_NODE_MAX" = true ]; then
    RATIO=$(echo "${MEMRESERVE_RATIO}/100" | bc -l)
    CANARY_CFG="ft_def:"
    CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/"
  
    # This file is used to get the peak RSS
    if [ ! -r "${CANARY_DIR}" ]; then
      echo "ERROR: The file '${CANARY_DIR}' doesn't exist yet. Aborting."
      exit
    fi
  
    # This is in kilobytes
    PEAK_RSS=`${SCRIPTS_DIR}/all/stat --single=${CANARY_DIR} --metric=peak_rss_kbytes`
    PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)
  
    # How many pages we need to be free on upper tier
    NUM_PAGES=$(echo "${PEAK_RSS} * ${RATIO} / 4" | bc)
    NUM_BYTES_FLOAT=$(echo "${PEAK_RSS} * ${RATIO} * 1024" | bc)
    NUM_BYTES=${NUM_BYTES_FLOAT%.*}
  fi

  export SH_MAX_SITES_PER_ARENA="5000"
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"

  # Value profiling
  export SH_PROFILE_ALL="1"
  export SH_MAX_SAMPLE_PAGES="2048"
  export SH_SAMPLE_FREQ="${FREQ}"
  export SH_PROFILE_RATE_NSECONDS=$(echo "${RATE} * 1000000" | bc)
  export SH_PROFILE_ALL_EVENTS="MEM_LOAD_UOPS_LLC_MISS_RETIRED:LOCAL_DRAM,MEM_LOAD_UOPS_RETIRED:LOCAL_PMM"
  
  export SH_PROFILE_IMC="skx_unc_imc0,skx_unc_imc1,skx_unc_imc2,skx_unc_imc3,skx_unc_imc4,skx_unc_imc5"
  export SH_PROFILE_EXTENT_SIZE_SKIP_INTERVALS="${CAPACITY_SKIP_INTERVALS}"
  export SH_PROFILE_RSS_SKIP_INTERVALS="${CAPACITY_SKIP_INTERVALS}"
  export SH_PROFILE_OBJMAP_SKIP_INTERVALS="${CAPACITY_SKIP_INTERVALS}"

  # Turn on online
  export SH_PROFILE_ONLINE="1"
  export SH_PROFILE_ONLINE_SKIP_INTERVALS="${ONLINE_SKIP_INTERVALS}"
  export SH_PROFILE_ONLINE_SORT="value_per_weight"
  export SH_PROFILE_ONLINE_PACKING_ALGO="${PACKING_ALGO}"
  
  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 1`

  eval "${PRERUN}"

  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    if [ "$DO_DEBUG" = true ]; then
      export SH_PROFILE_ONLINE_DEBUG_FILE="${DIR}/online.txt"
      export SH_PRINT_PROFILE_INTERVALS="1"
    fi
    export SH_PROFILE_OUTPUT_FILE="${DIR}/profile.txt"
    drop_caches_start
    if [ "$DO_MEMRESERVE" = true ]; then
      memreserve ${DIR} ${NUM_PAGES} ${SH_UPPER_NODE}
    fi
    drop_caches_start
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    if [ "$DO_PER_NODE_MAX" = true ]; then
      per_node_max ${NUM_BYTES} &>> ${DIR}/stdout.txt
    else
      per_node_max max &>> ${DIR}/stdout.txt
    fi
    numastat_kill
    pcm_kill
    if [ "$DO_MEMRESERVE" = true ]; then
      memreserve_kill
    fi
    drop_caches_end
  done
}

function on_pnm {
  MEMRESERVE_RATIO="$6"
  export DO_PER_NODE_MAX=true
  on_base $@
}

function on_pnm_ski {
  export SH_PROFILE_ONLINE_STRAT_SKI="1"
  on_pnm $@
}

function on_ski {
  export SH_PROFILE_ONLINE_STRAT_SKI="1"
  on_base $@
}

# PROFILE_ALL with objmap
function on_pnm_ski_all_objmap_bsl {
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304"
  export SH_PROFILE_ONLINE_VALUE="profile_all_total"
  export SH_PROFILE_ONLINE_WEIGHT="profile_rss_peak"
  export SH_PROFILE_OBJMAP="1"
  on_pnm_ski $@
}
function on_mr_ski_all_rss_bsl_debug {
  DO_DEBUG=true
  on_pnm_ski_all_objmap_bsl $@
}

# BWREL with objmap
function on_pnm_ski_bwr_objmap_bsl {
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304"
  export SH_PROFILE_BW="1"
  export SH_PROFILE_BW_EVENTS="UNC_M_CAS_COUNT:RD"
  export SH_PROFILE_BW_SKIP_INTERVALS="1"
  export SH_PROFILE_BW_RELATIVE="1"
  export SH_PROFILE_ONLINE_VALUE="profile_bw_relative_total"
  export SH_PROFILE_ONLINE_WEIGHT="profile_objmap_peak"
  export SH_PROFILE_OBJMAP="1"
  on_pnm_ski $@
}
function on_ski_bwr_objmap_bsl {
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304"
  export SH_PROFILE_BW="1"
  export SH_PROFILE_BW_EVENTS="UNC_M_CAS_COUNT:RD"
  export SH_PROFILE_BW_SKIP_INTERVALS="1"
  export SH_PROFILE_BW_RELATIVE="1"
  export SH_PROFILE_ONLINE_VALUE="profile_bw_relative_total"
  export SH_PROFILE_ONLINE_WEIGHT="profile_objmap_peak"
  export SH_PROFILE_OBJMAP="1"
  on_ski $@
}
function on_pnm_ski_bwr_objmap_bsl_lazy {
  DO_DEBUG=true
  export SH_LAZY_MIGRATION="1"
  on_pnm_ski_bwr_objmap_bsl $@
}
function on_pnm_ski_bwr_objmap_bsl_nolazy {
  DO_DEBUG=true
  on_pnm_ski_bwr_objmap_bsl $@
}
function on_pnm_ski_bwr_objmap_bsl_lazyfixed {
  DO_DEBUG=true
  export SH_LAZY_MIGRATION="1"
  on_pnm_ski_bwr_objmap_bsl $@
}
function on_pnm_ski_bwr_objmap_bsl_nolazyfixed {
  DO_DEBUG=true
  on_pnm_ski_bwr_objmap_bsl $@
}
function on_ski_bwr_objmap_bsl_debug {
  DO_DEBUG=true
  on_ski_bwr_objmap_bsl $@
}
function on_pnm_ski_bwr_objmap_ss {
  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_PROFILE_BW="1"
  export SH_PROFILE_BW_EVENTS="UNC_M_CAS_COUNT:RD"
  export SH_PROFILE_BW_SKIP_INTERVALS="1"
  export SH_PROFILE_BW_RELATIVE="1"
  export SH_PROFILE_ONLINE_VALUE="profile_bw_relative_total"
  export SH_PROFILE_ONLINE_WEIGHT="profile_objmap_peak"
  export SH_PROFILE_OBJMAP="1"
  on_pnm_ski $@
}
function on_pnm_ski_bwr_objmap_ss_debug {
  DO_DEBUG=true
  on_pnm_ski_bwr_objmap_ss $@
}
