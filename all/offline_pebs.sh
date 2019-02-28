#!/bin/bash

################################################################################
#                        numastat_background                                   #
################################################################################
# First arg is directory to write to
function numastat_background {
  rm $1/numastat.txt
  while true; do
    echo "=======================================" &>> $1/numastat.txt
    numastat -m &>> $1/numastat.txt
    sleep 2
  done
}

################################################################################
#                        offline_pebs_guided_percent                           #
################################################################################
# First argument is results directory
# Second argument is the command to run
# Third argument is the frequency of PEBS sampling to use
# Fourth argument is the percentage of the peak RSS that should be available on the MCDRAM
# Fifth argument is the packing strategy
function offline_pebs_guided_percent {
  RESULTS_DIR="$1"
  COMMAND="$2"
  FREQ="$3"
  RATIO=$(echo "${4}/100" | bc -l)
  PACK_ALGO="$5"
  PEAK_RSS_CFG="firsttouch_all_exclusive_device_0"
  PEBS_CFG="pebs_${1}"

  # This file is used for the profiling information
  if [ ! -r ${RESULTS_DIR}/../${PEBS_CFG}/stdout.txt ]; then
    echo "ERROR: The file '${RESULTS_DIR}/../${PEBS_CFG}/stdout.txt doesn't exist yet. Aborting."
    exit
  fi

  # This file is used to get the peak RSS
  if [ ! -r ${RESULTS_DIR}/../${PEAK_RSS_CFG}/stdout.txt ]; then
    echo "ERROR: The file '${RESULTS_DIR}/../${PEAK_RSS_CFG}/stdout.txt doesn't exist yet. Aborting."
    exit
  fi

  # User output
  echo "Running experiment:"
  echo "  Experiment: Offline PEBS-Guided"
  echo "  Profiling Frequency: '${FREQ}'"
  echo "  Ratio: '${RATIO}'"
  echo "  Packing algo: '${PACK_ALGO}'"
  echo "  Command: '${COMMAND}'"

  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_DEFAULT_NODE="0"
  export OMP_NUM_THREADS="64"
  
  # Generate the hotset/knapsack/thermos
  cat ${RESULTS_DIR}/../${PEBS_CFG}/stdout.txt | \
    sicm_hotset pebs ${PACK_ALGO} ratio ${RATIO} 1 > \
    ${RESULTS_DIR}/guidance.txt
  for iter in {1..2}; do
    echo 3 | sudo tee /proc/sys/vm/drop_caches
		sleep 5
    cat ${RESULTS_DIR}/../${PEAK_RSS_CFG}/stdout.txt | \
      sicm_memreserve 1 64 ratio ${RATIO} hold bind &
    sleep 5
    numastat -m &>> ${RESULTS_DIR}/numastat_before.txt
    background "${RESULTS_DIR}" &
    background_pid=$!
    eval "env time -v " "${COMMAND}" &>> ${RESULTS_DIR}/stdout.txt
    kill $background_pid
    wait $background_pid 2>/dev/null
    pkill sicm_memreserve
    sleep 5
  done
}

################################################################################
#                        offline_pebs_guided                                   #
################################################################################
# First argument is results directory
# Second argument is the command to run
# Third argument is the frequency of PEBS sampling to use
# Fourth argument is the packing strategy
function offline_pebs_guided_percent {
  RESULTS_DIR="$1"
  COMMAND="$2"
  FREQ="$3"
  PACK_ALGO="$4"
  PEBS_CFG="pebs_${1}"

  # This file is used for the profiling information
  if [ ! -r ${RESULTS_DIR}/../${PEBS_CFG}/stdout.txt ]; then
    echo "ERROR: The file '${RESULTS_DIR}/../${PEBS_CFG}/stdout.txt doesn't exist yet. Aborting."
    exit
  fi

  # User output
  echo "Running experiment:"
  echo "  Experiment: Offline PEBS-Guided"
  echo "  Profiling Frequency: '${FREQ}'"
  echo "  Packing algo: '${PACK_ALGO}'"
  echo "  Command: '${COMMAND}'"

  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_DEFAULT_NODE="0"
  export OMP_NUM_THREADS="64"
  
  # Generate the hotset/knapsack/thermos
  cat ${RESULTS_DIR}/../${PEBS_CFG}/stdout.txt | \
    sicm_hotset pebs ${PACK_ALGO} ratio ${RATIO} 1 > \
    ${RESULTS_DIR}/guidance.txt
  for iter in {1..2}; do
    echo 3 | sudo tee /proc/sys/vm/drop_caches
		sleep 5
    numastat -m &>> ${RESULTS_DIR}/numastat_before.txt
    background "${RESULTS_DIR}" &
    background_pid=$!
    eval "env time -v " "${COMMAND}" &>> ${RESULTS_DIR}/stdout.txt
    kill $background_pid
    wait $background_pid 2>/dev/null
    pkill sicm_memreserve
    sleep 5
  done
}
