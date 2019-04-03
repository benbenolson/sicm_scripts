#!/bin/bash

################################################################################
#                    firsttouch_all_exclusive_device                           #
################################################################################
# First argument is results directory
# Second argument is the command to run
# Third argument is node to firsttouch onto
function firsttouch_all_exclusive_device {
  BASEDIR="$1"
  COMMAND="$2"
  NODE="$3"

  # User output
  echo "Running experiment:"
  echo "  Config: 'firsttouch_all_exclusive_device'"
  echo "  Node: '${NODE}'"

  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  export OMP_NUM_THREADS=272
  export SH_DEFAULT_NODE="${NODE}"
  #export JE_MALLOC_CONF="oversize_threshold:42949672960,background_thread:true"
  export JE_MALLOC_CONF="oversize_threshold:42949672960"

  # Run 5 iters
  for i in {0..0}; do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    eval "env time -v numactl --preferred=${NODE}" "${COMMAND}" &>> ${DIR}/stdout.txt
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
  BASEDIR="$1"
  COMMAND="$2"
  NODE="$3"

  # User output
  echo "Running experiment:"
  echo "  Config: 'firsttouch_all_default'"
  echo "  Node: '${NODE}'"

  export OMP_NUM_THREADS=272
  export SH_DEFAULT_NODE="${NODE}"
  export JE_MALLOC_CONF="oversize_threshold:2147483648,background_thread:true"

  # Run 5 iters
  for i in {0..1}; do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    numastat -m &>> ${DIR}/numastat_before.txt
    eval "env time -v numactl --preferred=${NODE}" "${COMMAND}" &>> ${DIR}/stdout.txt
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
  BASEDIR="$1"
  COMMAND="$2"
  NODE="$3"

  # User output
  echo "Running experiment:"
  echo "  Config: 'firsttouch_all_shared_site'"
  echo "  Node: '${NODE}'"

  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export OMP_NUM_THREADS=272
  export SH_DEFAULT_NODE="${NODE}"
  export JE_MALLOC_CONF="oversize_threshold:2147483648,background_thread:true"

  # Run 5 iters
  for i in {0..1}; do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    eval "env time -v numactl --preferred=${NODE}" "${COMMAND}" &>> ${DIR}/stdout.txt
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
  BASEDIR="$1"
  COMMAND="$2"
  PERCENTAGE="$3"
  # Putting everything on DDR to get the peak RSS of the whole application
  CANARY_CFG="firsttouch_all_exclusive_device_0"
  CANARY_STDOUT="${BASEDIR}/../${CANARY_CFG}/stdout.txt"

  if [ ! -r ${CANARY_STDOUT} ]; then
    echo "ERROR: The file '${CANARY_STDOUT} doesn't exist yet. Aborting."
    exit
  fi

  # This is in kilobytes
  PEAK_RSS=$(${SCRIPTS_DIR}/stat.sh ${CANARY_STDOUT} rss_kbytes)
  RATIO=$(echo "${PERCENTAGE}/100" | bc -l)
  # How many pages we need to be free on MCDRAM
  NUM_PAGES=$(echo "${PEAK_RSS} * ${RATIO} / 4" | bc)

  # User output
  echo "Running experiment:"
  echo "  Experiment: Firsttouch Exclusive Device"
  echo "  Percentage: ${PERCENTAGE}"

  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  export OMP_NUM_THREADS=272
  export SH_DEFAULT_NODE="${NODE}"
  export JE_MALLOC_CONF="oversize_threshold:2147483648,background_thread:true"

  # Run 5 iters
  for i in {0..1}; do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches
    memreserve ${DIR} ${NUM_PAGES}
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    eval "env time -v numactl --preferred=1 " "${COMMAND}" &>> ${DIR}/stdout.txt
    numastat_kill
    pcm_kill
    memreserve_kill
  done
}
