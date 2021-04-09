#!/bin/bash

# First argument is the PEBS frequency
# Second is the sampling rate
function prof_all_base {
  FREQ="$1"
  RATE="$2"

  export SH_MAX_SITES_PER_ARENA="5000"
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 1`

  # Value profiling
  export SH_PROFILE_ALL="1"
  export SH_MAX_SAMPLE_PAGES="2048"
  export SH_SAMPLE_FREQ="${FREQ}"
  export SH_PROFILE_RATE_NSECONDS=$(echo "${RATE} * 1000000" | bc)
  export SH_PROFILE_ALL_EVENTS="MEM_LOAD_UOPS_LLC_MISS_RETIRED:LOCAL_DRAM,MEM_LOAD_UOPS_RETIRED:LOCAL_PMM"
  
  # Bandwidth, too.
  export SH_PROFILE_BW="1"
  export SH_PROFILE_BW_EVENTS="UNC_M_CAS_COUNT:RD"
  export SH_PROFILE_BW_SKIP_INTERVALS="1"
  export SH_PROFILE_BW_RELATIVE="1"
  export SH_PROFILE_IMC="skx_unc_imc0,skx_unc_imc1,skx_unc_imc2,skx_unc_imc3,skx_unc_imc4,skx_unc_imc5"
  
  eval "${PRERUN}"

  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    export SH_PROFILE_OUTPUT_FILE="${DIR}/profile.txt"
    mkdir ${DIR}
    echo 1 | sudo tee /proc/sys/kernel/perf_event_paranoid
    drop_caches_start
    per_node_max max &> ${DIR}/stdout.txt
    drop_caches_end
  done
}

function prof_bsl {
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304"
  export SH_PROFILE_OBJMAP="1"
  export SH_PROFILE_OBJMAP_SKIP_INTERVALS="$3"
  export SH_PRINT_PROFILE_INTERVALS="1"
  
  prof_all_base $@
}

function prof_bsl_large {
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="33554432"
  export SH_PROFILE_OBJMAP="1"
  export SH_PROFILE_OBJMAP_SKIP_INTERVALS="$3"
  export SH_PRINT_PROFILE_INTERVALS="1"
  
  prof_all_base $@
}
