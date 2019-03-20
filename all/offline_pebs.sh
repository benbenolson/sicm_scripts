#!/bin/bash

################################################################################
#                        offline_pebs_guided_percent                           #
################################################################################
# First argument is results directory
# Second argument is the command to run
# Third argument is the frequency of PEBS sampling to use
# Fourth argument is the size of the PEBS sampling to use
# Fifth argument is the packing strategy
# Sixth argument is the percentage of the peak RSS that should be available on the MCDRAM
function offline_pebs_guided_percent {
  RESULTS_DIR="$1"
  COMMAND="$2"
  PEBS_FREQ="$3"
  PEBS_SIZE="$4"
  PACK_ALGO="$5"
  RATIO=$(echo "${6}/100" | bc -l)
  PEAK_RSS_FILE="${RESULTS_DIR}/../firsttouch_all_exclusive_device_0/stdout.txt"
  PEBS_FILE="${RESULTS_DIR}/../../${PEBS_SIZE}/pebs_${PEBS_FREQ}/stdout.txt"

  # This file is used for the profiling information
  if [ ! -r "${PEBS_FILE}" ]; then
    echo "ERROR: The file '${PEBS_FILE}' doesn't exist yet. Aborting."
    exit
  fi

  # This file is used to get the peak RSS
  if [ ! -r "${PEAK_RSS_FILE}" ]; then
    echo "ERROR: The file '${PEAK_RSS_FILE}' doesn't exist yet. Aborting."
    exit
  fi

  # User output
  echo "Running experiment:"
  echo "  Experiment: Offline PEBS-Guided"
  echo "  Profiling Frequency: '${PEBS_FREQ}'"
  echo "  Profiling size: '${PEBS_SIZE}'"
  echo "  Ratio: '${RATIO}'"
  echo "  Packing algo: '${PACK_ALGO}'"
  echo "  Command: '${COMMAND}'"

  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_DEFAULT_NODE="0"
  export SH_GUIDANCE_FILE="${RESULTS_DIR}/guidance.txt"
  export OMP_NUM_THREADS="272"
  
  # Generate the hotset/knapsack/thermos
  cat "${PEBS_FILE}" | \
    sicm_hotset pebs ${PACK_ALGO} ratio ${RATIO} 1 > \
      ${RESULTS_DIR}/guidance.txt
  for iter in {1..2}; do
    drop_caches
    cat "${PEAK_RSS_FILE}" | \
      sicm_memreserve 1 64 ratio ${RATIO} hold bind &
    sleep 5
    numastat -m &>> ${RESULTS_DIR}/numastat_before.txt
    numastat_background "${RESULTS_DIR}"
    pcm_background "${RESULTS_DIR}"
    eval "env time -v " "${COMMAND}" &>> ${RESULTS_DIR}/stdout.txt
    numastat_kill
    pcm_kill
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
# Fourth argument is the size of PEBS profiling run to use
# Fifth argument is the packing strategy
function offline_pebs_guided {
  RESULTS_DIR="$1"
  COMMAND="$2"
  PEBS_FREQ="$3"
  PEBS_SIZE="$4"
  PACK_ALGO="$5"
  PEAK_RSS_FILE="${RESULTS_DIR}/../firsttouch_all_exclusive_device_0/stdout.txt"
  PEBS_FILE="${RESULTS_DIR}/../../${PEBS_SIZE}/pebs_${PEBS_FREQ}/stdout.txt"

  # This file is used for the profiling information
  if [ ! -r "${PEBS_FILE}" ]; then
    echo "ERROR: The file '${PEBS_FILE}' doesn't exist yet. Aborting."
    exit
  fi

  # This file is used to get the peak RSS
  if [ ! -r "${PEAK_RSS_FILE}" ]; then
    echo "ERROR: The file '${PEAK_RSS_FILE}' doesn't exist yet. Aborting."
    exit
  fi

  # Figure out which percentage the 16GB MCDRAM is of the peak RSS
  PEAK_RSS="$(cat "${PEAK_RSS_FILE}" | awk '/Maximum resident set size/ {printf "%d * 1024\n", $6; exit;}' | bc)"
  MCDRAM_SIZE="$(numastat -m | awk '/MemTotal/ {printf "%d * 1024 * 1024\n", $3}' | bc)"
  RATIO="$(echo "${MCDRAM_SIZE} / ${PEAK_RSS}" | bc -l)"

  # User output
  echo "Running experiment:"
  echo "  Experiment: Offline PEBS-Guided"
  echo "  Profiling Frequency: '${PEBS_FREQ}'"
  echo "  Profiling size: '${PEBS_SIZE}'"
  echo "  Packing algo: '${PACK_ALGO}'"
  echo "  Ratio of peak RSS to fit in MCDRAM: '${RATIO}'"
  echo "  Command: '${COMMAND}'"

  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="4096"
  export SH_DEFAULT_NODE="0"
  export SH_GUIDANCE_FILE="${RESULTS_DIR}/guidance.txt"
  export OMP_NUM_THREADS="272"
  
  cat "${PEBS_FILE}" | \
    sicm_hotset pebs ${PACK_ALGO} ratio ${RATIO} 1 > \
    ${RESULTS_DIR}/guidance.txt
  for iter in {1..2}; do
    drop_caches
    numastat -m &>> ${RESULTS_DIR}/numastat_before.txt
    numastat_background "${RESULTS_DIR}"
    pcm_background "${RESULTS_DIR}"
    eval "env time -v " "${COMMAND}" &>> ${RESULTS_DIR}/stdout.txt
    numastat_kill
    pcm_kill
    sleep 5
  done
}
