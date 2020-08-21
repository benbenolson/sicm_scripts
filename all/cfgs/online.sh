#!/bin/bash

DO_MEMRESERVE=false
DO_DEBUG=false
MEMRESERVE_RATIO=""

function on_base {
  PACKING_ALGO="$1"
  FREQ="$2"
  RATE="$3"
  CAPACITY_SKIP_INTERVALS="$4"
  ONLINE_SKIP_INTERVALS="$5"

  # First, get ready to do memreserve if applicable
  if [ "${DO_MEMRESERVE}" = true ]; then
    RATIO=$(echo "${MEMRESERVE_RATIO}/100" | bc -l)
    CANARY_CFG="firsttouch_exclusive_device:"
    CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/i0/"

    # This file is used to get the peak RSS
    if [ ! -r "${CANARY_DIR}" ]; then
      echo "ERROR: The file '${CANARY_DIR}' doesn't exist yet. Aborting."
      exit
    fi

    # This is in kilobytes
    PEAK_RSS=`${SCRIPTS_DIR}/all/stat --single --metric=peak_rss_kbytes ${CANARY_DIR}`
    PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)

    # How many pages we need to be free on upper tier
    NUM_PAGES=$(echo "${PEAK_RSS} * ${RATIO} / 4" | bc)
    NUM_BYTES_FLOAT=$(echo "${PEAK_RSS} * ${RATIO} * 1024" | bc)
    NUM_BYTES=${NUM_BYTES_FLOAT%.*}
    echo "Reserving $NUM_PAGES pages."
  fi

  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
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
      export SH_PROFILE_ONLINE_RESERVED_BYTES="${RESERVED_BYTES}"
    fi
    drop_caches_start
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    #pcm_background "${DIR}"
    eval "${COMMAND}" &>> ${DIR}/stdout.txt
    numastat_kill
    #pcm_kill
    if [ "$DO_MEMRESERVE" = true ]; then
      memreserve_kill
    fi
    drop_caches_end
  done
}

#
# MEMRESERVE
#
function on_mr {
  MEMRESERVE_RATIO="$6"
  on_base $@
}

#
# ONLINE ALGO
#
function on_mr_ski {
  export SH_PROFILE_ONLINE_STRAT_SKI="1"
  on_mr $@
}

# PROFILE_ALL with RSS
function on_mr_ski_all_rss {
  export SH_PROFILE_ONLINE_VALUE="profile_all_total"
  export SH_PROFILE_ONLINE_WEIGHT="profile_rss_peak"
  export SH_PROFILE_RSS="1"
  on_mr_ski $@
}
function on_mr_ski_all_rss_debug {
  DO_DEBUG=true
  on_mr_ski_all_rss_debug $@
}

# PROFILE_ALL with ES
function on_mr_ski_all_es {
  export SH_PROFILE_ONLINE_VALUE="profile_all_total"
  export SH_PROFILE_ONLINE_WEIGHT="profile_extent_size_peak"
  export SH_PROFILE_EXTENT_SIZE="1"
  on_mr_ski $@
}
function on_mr_ski_all_es_debug {
  DO_DEBUG=true
  on_mr_ski_all_es $@
}

# PROFILE_ALL with latency and RSS
function on_mr_ski_all_lat_rss {
  export SH_PROFILE_ONLINE_VALUE="profile_all_total"
  export SH_PROFILE_ONLINE_WEIGHT="profile_rss_peak"
  export SH_PROFILE_RSS="1"
  
  # Use latency
  export SH_PROFILE_LATENCY_SET_MULTIPLIERS="1"
  export SH_PROFILE_LATENCY="1"
  export SH_PROFILE_LATENCY_CLOCKTICK_EVENT="UNC_M_DCLOCKTICKS"
  export SH_PROFILE_LATENCY_EVENTS="UNC_M_RPQ_INSERTS,UNC_M_RPQ_OCCUPANCY,UNC_M_WPQ_INSERTS,UNC_M_WPQ_OCCUPANCY,UNC_M_PMM_RPQ_INSERTS,UNC_M_PMM_RPQ_OCCUPANCY:DEFAULT,UNC_M_PMM_WPQ_INSERTS,UNC_M_PMM_WPQ_OCCUPANCY:DEFAULT"
  export SH_PROFILE_LATENCY_SKIP_INTERVALS="1"
  
  on_mr_ski $@
}
function on_mr_ski_all_lat_rss_debug {
  DO_DEBUG=true
  on_mr_ski_all_lat_rss $@
}

# PROFILE_ALL with latency and ES
function on_mr_ski_all_lat_es {
  export SH_PROFILE_ONLINE_VALUE="profile_all_total"
  export SH_PROFILE_ONLINE_WEIGHT="profile_extent_size_peak"
  export SH_PROFILE_EXTENT_SIZE="1"
  
  # Use latency
  export SH_PROFILE_LATENCY_SET_MULTIPLIERS="1"
  export SH_PROFILE_LATENCY="1"
  export SH_PROFILE_LATENCY_CLOCKTICK_EVENT="UNC_M_DCLOCKTICKS"
  export SH_PROFILE_LATENCY_EVENTS="UNC_M_RPQ_INSERTS,UNC_M_RPQ_OCCUPANCY,UNC_M_WPQ_INSERTS,UNC_M_WPQ_OCCUPANCY,UNC_M_PMM_RPQ_INSERTS,UNC_M_PMM_RPQ_OCCUPANCY:DEFAULT,UNC_M_PMM_WPQ_INSERTS,UNC_M_PMM_WPQ_OCCUPANCY:DEFAULT"
  export SH_PROFILE_LATENCY_SKIP_INTERVALS="1"
  on_mr_ski $@
}
function on_mr_ski_all_lat_es_debug {
  DO_DEBUG=true
  on_mr_ski_all_lat_es $@
}

# BWREL with RSS
function on_mr_ski_bwrel_rss {
  export SH_PROFILE_BW="1"
  export SH_PROFILE_BW_EVENTS="UNC_M_CAS_COUNT:RD"
  export SH_PROFILE_BW_SKIP_INTERVALS="1"
  export SH_PROFILE_BW_RELATIVE="1"
  export SH_PROFILE_ONLINE_VALUE="profile_bw_relative_total"
  export SH_PROFILE_ONLINE_WEIGHT="profile_rss_peak"
  export SH_PROFILE_RSS="1"
  on_mr_ski $@
}
function on_mr_ski_bwrel_rss_debug {
  DO_DEBUG=true
  on_mr_ski_bwrel_rss $@
}

# BWREL with ES
function on_mr_ski_bwrel_es {
  export SH_PROFILE_BW="1"
  export SH_PROFILE_BW_EVENTS="UNC_M_CAS_COUNT:RD"
  export SH_PROFILE_BW_SKIP_INTERVALS="1"
  export SH_PROFILE_BW_RELATIVE="1"
  export SH_PROFILE_ONLINE_VALUE="profile_bw_relative_total"
  export SH_PROFILE_ONLINE_WEIGHT="profile_extent_size_peak"
  export SH_PROFILE_EXTENT_SIZE="1"
  on_mr_ski $@
}
function on_mr_ski_bwrel_es_debug {
  DO_DEBUG=true
  on_mr_ski_bwrel_es $@
}

# BWREL with lat and RSS
function on_mr_ski_bwrel_lat_rss {
  export SH_PROFILE_BW="1"
  export SH_PROFILE_BW_EVENTS="UNC_M_CAS_COUNT:RD"
  export SH_PROFILE_BW_SKIP_INTERVALS="1"
  export SH_PROFILE_BW_RELATIVE="1"
  export SH_PROFILE_ONLINE_VALUE="profile_bw_relative_total"
  export SH_PROFILE_ONLINE_WEIGHT="profile_rss_peak"
  export SH_PROFILE_RSS="1"
  
  # Use latency
  export SH_PROFILE_LATENCY_SET_MULTIPLIERS="1"
  export SH_PROFILE_LATENCY="1"
  export SH_PROFILE_LATENCY_CLOCKTICK_EVENT="UNC_M_DCLOCKTICKS"
  export SH_PROFILE_LATENCY_EVENTS="UNC_M_RPQ_INSERTS,UNC_M_RPQ_OCCUPANCY,UNC_M_WPQ_INSERTS,UNC_M_WPQ_OCCUPANCY,UNC_M_PMM_RPQ_INSERTS,UNC_M_PMM_RPQ_OCCUPANCY:DEFAULT,UNC_M_PMM_WPQ_INSERTS,UNC_M_PMM_WPQ_OCCUPANCY:DEFAULT"
  export SH_PROFILE_LATENCY_SKIP_INTERVALS="1"
  
  on_mr_ski $@
}
function on_mr_ski_bwrel_lat_rss_debug {
  DO_DEBUG=true
  on_mr_ski_bwrel_lat_rss $@
}
  
# BWREL with lat and ES
function on_mr_ski_bwrel_lat_es {
  export SH_PROFILE_BW="1"
  export SH_PROFILE_BW_EVENTS="UNC_M_CAS_COUNT:RD"
  export SH_PROFILE_BW_SKIP_INTERVALS="1"
  export SH_PROFILE_BW_RELATIVE="1"
  export SH_PROFILE_ONLINE_VALUE="profile_bw_relative_total"
  export SH_PROFILE_ONLINE_WEIGHT="profile_extent_size_peak"
  export SH_PROFILE_EXTENT_SIZE="1"
  
  # Use latency
  export SH_PROFILE_LATENCY_SET_MULTIPLIERS="1"
  export SH_PROFILE_LATENCY="1"
  export SH_PROFILE_LATENCY_CLOCKTICK_EVENT="UNC_M_DCLOCKTICKS"
  export SH_PROFILE_LATENCY_EVENTS="UNC_M_RPQ_INSERTS,UNC_M_RPQ_OCCUPANCY,UNC_M_WPQ_INSERTS,UNC_M_WPQ_OCCUPANCY,UNC_M_PMM_RPQ_INSERTS,UNC_M_PMM_RPQ_OCCUPANCY:DEFAULT,UNC_M_PMM_WPQ_INSERTS,UNC_M_PMM_WPQ_OCCUPANCY:DEFAULT"
  export SH_PROFILE_LATENCY_SKIP_INTERVALS="1"
  
  on_mr_ski $@
}
function on_mr_ski_bwrel_lat_es_debug {
  DO_DEBUG=true
  on_mr_ski_bwrel_lat_es $@
}
