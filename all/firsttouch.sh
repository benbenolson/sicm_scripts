#!/bin/bash

################################################################################
#                    firsttouch_all_exclusive_device                           #
################################################################################
# First argument is results directory
# Second argument is the command to run
# Third argument is node to firsttouch onto
function firsttouch_all_exclusive_device {
  RESULTS_DIR="$1"
  COMMAND="$2"
  NODE="$3"

  # User output
  echo "Running experiment:"
  echo "  Experiment: Firsttouch Exclusive Device, 100%"
  echo "  Node: ${NODE}"
  echo "  Command: '${COMMAND}'"
  echo "  Results directory: ${RESULTS_DIR}"

  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  export OMP_NUM_THREADS=64
  export SH_DEFAULT_NODE="${NODE}"

  # Run 5 iters
  for iter in {1..1}; do
    drop_caches
    numastat -m &>> ${RESULTS_DIR}/numastat_before.txt
    numastat_background "${RESULTS_DIR}"
    pcm_background "${RESULTS_DIR}"
    eval "env time -v numactl --preferred=${NODE}" "${COMMAND}" &>> ${RESULTS_DIR}/stdout.txt
    numastat_kill
    pcm_kill
  done
}

################################################################################
#                        firsttouch_all_default                                #
################################################################################
# First argument is the results directory
# Second argument is the command to run
# Third argument is the node to firsttouch to
function firsttouch_all_default {
  RESULTS_DIR="$1"
  COMMAND="$2"
  NODE="$3"

  # User output
  echo "Running experiment:"
  echo "  Experiment: Firsttouch Default Layout, 100%"
  echo "  Node: ${NODE}"
  echo "  Command: '${COMMAND}'"
  echo "  Results directory: ${RESULTS_DIR}"

  export OMP_NUM_THREADS=64
  export SH_DEFAULT_NODE="${NODE}"

  # Run 5 iters
  for iter in {1..1}; do
    drop_caches
    numastat_background "${RESULTS_DIR}"
    pcm_background "${RESULTS_DIR}"
    numastat -m &>> ${RESULTS_DIR}/numastat_before.txt
    eval "env time -v numactl --preferred=${NODE}" "${COMMAND}" &>> ${RESULTS_DIR}/stdout.txt
    numastat_kill
    pcm_kill
  done
}


################################################################################
#                    firsttouch_all_shared_site                                #
################################################################################
# First argument is the results directory
# Second argument is the command to run
# Third argument is node to firsttouch onto
function firsttouch_all_shared_site {
  RESULTS_DIR="$1"
  COMMAND="$2"
  NODE="$3"

  # User output
  echo "Running experiment:"
  echo "  Experiment: Firsttouch Shared Site, 100%"
  echo "  Node: ${NODE}"
  echo "  Command: '${COMMAND}'"
  echo "  Results directory: ${RESULTS_DIR}"

  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export OMP_NUM_THREADS=64
  export SH_DEFAULT_NODE="${NODE}"

  # Run 5 iters
  for iter in {1..2}; do
    drop_caches
    numastat -m &>> ${RESULTS_DIR}/numastat_before.txt
    numastat_background "${RESULTS_DIR}"
    pcm_background "${RESULTS_DIR}"
    eval "env time -v numactl --preferred=${NODE}" "${COMMAND}" &>> ${RESULTS_DIR}/stdout.txt
    numastat_kill
    pcm_kill
  done
}

################################################################################
#                   firsttouch_exclusive_device                                #
################################################################################
# First argument is the results directory
# Second argument is the command to run
# Third argument is the percentage to reserve on the upper tier
function firsttouch_exclusive_device {
  RESULTS_DIR="$1"
  COMMAND="$2"
  PERCENTAGE="$3"
  # Putting everything on DDR to get the peak RSS of the whole application
  CANARY_CFG="firsttouch_all_exclusive_device_0"

  if [ ! -r ${RESULTS_DIR}/../${CANARY_CFG}/stdout.txt ]; then
    echo "ERROR: The file '${CANARY_CFG}/stdout.txt doesn't exist yet. Aborting."
    exit
  fi

  RATIO=$(echo "${PERCENTAGE}/100" | bc -l)

  # User output
  echo "Running experiment:"
  echo "  Experiment: Firsttouch Exclusive Device"
  echo "  Ratio: ${RATIO}"
  echo "  Canary config: ${CANARY_CFG}"
  echo "  Command: '${COMMAND}'"

  # Run 5 iters
  for iter in {1..2}; do
    drop_caches
    cat ${RESULTS_DIR}/../${CANARY_CFG}/stdout.txt | sicm_memreserve 1 64 ratio ${RATIO} hold bind &>> ${RESULTS_DIR}/memreserve.txt &
    sleep 5
    numastat -m &>> ${RESULTS_DIR}/numastat_before.txt
    numastat_background "${RESULTS_DIR}"
    pcm_background "${RESULTS_DIR}"
    eval "env time -v numactl --preferred=1 " "${COMMAND}" &>> ${RESULTS_DIR}/stdout.txt
    numastat_kill
    pcm_kill
    pkill memreserve
    sleep 5
  done
}
