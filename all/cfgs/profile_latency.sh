#!/bin/bash

export DEFAULT_PROFILE_NODE="${SH_UPPER_NODE}"
export DRAM_OR_PMM="DRAM"

# First is the sampling rate
function profile_latency {
  RATE="$1"

  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  export SH_DEFAULT_NODE="${DEFAULT_PROFILE_NODE}"
  
  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 1`

  export SH_PROFILE_RATE_NSECONDS=$(echo "${RATE} * 1000000" | bc)
  
  export SH_PROFILE_LATENCY="1"
  export SH_PROFILE_IMC="skx_unc_imc0,skx_unc_imc1,skx_unc_imc2,skx_unc_imc3,skx_unc_imc4,skx_unc_imc5"
  export SH_PROFILE_LATENCY_CLOCKTICK_EVENT="UNC_M_DCLOCKTICKS"
  if [ "$DRAM_OR_PMM" = "DRAM" ]; then
    export SH_PROFILE_LATENCY_EVENTS="UNC_M_RPQ_INSERTS,UNC_M_RPQ_OCCUPANCY,UNC_M_WPQ_INSERTS,UNC_M_WPQ_OCCUPANCY"
  else
    export SH_PROFILE_LATENCY_EVENTS="UNC_M_PMM_RPQ_INSERTS,UNC_M_PMM_RPQ_OCCUPANCY:DEFAULT,UNC_M_PMM_WPQ_INSERTS,UNC_M_PMM_WPQ_OCCUPANCY:DEFAULT"
  fi
  export SH_PROFILE_LATENCY_SKIP_INTERVALS="1"
  export SH_PRINT_PROFILE_INTERVALS="1"

  eval "${PRERUN}"

  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    export SH_PROFILE_OUTPUT_FILE="${DIR}/profile.txt"
    mkdir ${DIR}
    echo 1 | sudo tee /proc/sys/kernel/perf_event_paranoid
    drop_caches_start
    eval "${COMMAND}" &>> ${DIR}/stdout.txt
    drop_caches_end
  done
}

function profile_latency_lower {
  export DEFAULT_PROFILE_NODE="${SH_LOWER_NODE}"
  profile_latency $@
}

function profile_latency_upper {
  export DEFAULT_PROFILE_NODE="${SH_UPPER_NODE}"
  profile_latency "$@"
}

function profile_pmm_latency_lower {
  export DEFAULT_PROFILE_NODE="${SH_LOWER_NODE}"
  export DRAM_OR_PMM="PMM"
  profile_latency $@
}

function profile_pmm_latency_upper {
  export DEFAULT_PROFILE_NODE="${SH_UPPER_NODE}"
  export DRAM_OR_PMM="PMM"
  profile_latency "$@"
}
