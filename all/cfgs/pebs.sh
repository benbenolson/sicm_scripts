#!/bin/bash

################################################################################
#                                   pebs                                       #
################################################################################
# Third argument is the PEBS frequency
function pebs {
  FREQ="$1"

  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="4"

  # Enable profiling
  #export SH_PROFILE_ALL="1"
  #export SH_PROFILE_ALL_EVENTS="MEM_LOAD_UOPS_RETIRED:L3_MISS"
  export SH_PROFILE_PERF="1"
  export SH_PROFILE_PERF_EVENTS="MEM_LOAD_UOPS_RETIRED:L3_MISS"
  #export SH_PROFILE_PERF_EVENTS="MEM_TRANS_RETIRED:LOAD_LATENCY"
  export SH_PROFILE_RATE_NSECONDS="1000000000"
  export SH_MAX_SAMPLE_PAGES="512"
  export SH_PROFILE_RSS="1"
  export SH_PROFILE_RSS_SKIP_INTERVALS="10"

  # Bind to the fast node
  export SH_DEFAULT_NODE="1"
  export SH_SAMPLE_FREQ="${FREQ}"
  export JE_MALLOC_CONF="oversize_threshold:0"
  export OMP_NUM_THREADS="45"
  if [ "$BENCH" == "654.roms_s" ]; then
    export OMP_NUM_THREADS="48"
  fi

  eval "${PRERUN}"

  DIR="${BASEDIR}/i0"
  mkdir ${DIR}
  echo 1 | sudo tee /proc/sys/kernel/perf_event_paranoid
  drop_caches
  if [[ "$(hostname)" = "JF1121-080209T" ]]; then
    eval "env time -v numactl --preferred=1 " "${COMMAND}" &>> ${DIR}/stdout.txt
    #eval "env time -v numactl --cpunodebind=1 --preferred=1 " "${COMMAND}" &>> ${DIR}/stdout.txt
  else
    eval "env time -v numactl --preferred=1" "${COMMAND}" &>> ${DIR}/stdout.txt
  fi

  if [ $CPU2017_BENCH ]; then
    source $SCRIPTS_DIR/benchmarks/cpu2017/${BENCH}/${BENCH}_sizes.sh
    if [ $SIZE == "ref" ]; then
      for file in "${REF_OUTPUT[@]}"; do
        cp $file "${DIR}/"
      done
    elif [ $SIZE == "train" ]; then
      for file in "${TRAIN_OUTPUT[@]}"; do
        cp $file "${DIR}/"
      done
    elif [ $SIZE == "test" ]; then
      for file in "${TEST_OUTPUT[@]}"; do
        cp $file "${DIR}/"
      done
    fi
  fi
}
