#!/bin/bash

################################################################################
#                    firsttouch_all_exclusive_device                           #
################################################################################
# First argument is results directory
# Second argument is the command to run
# Third argument is node to firsttouch onto
# Fourth argument is the node to use as a lower tier
function firsttouch_all_exclusive_device {
  BASEDIR="$1"
  COMMAND="$2"
  NODE="$3"
  SLOWNODE="$4"

  # User output
  echo "Running experiment:"
  echo "  Config: 'firsttouch_all_exclusive_device'"
  echo "  Upper tier: '${NODE}'"
  echo "  Lower tier: '${SLOWNODE}'"

  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  export SH_DEFAULT_NODE="${NODE}"
  export JE_MALLOC_CONF="oversize_threshold:0"

  eval "${PRERUN}"

  # Run 5 iters
  for i in {0..4}; do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    if [[ "$(hostname)" = "JF1121-080209T" ]]; then
      eval "env time -v numactl --preferred=${NODE} numactl --cpunodebind=1 --membind=${NODE},${SLOWNODE} " "${COMMAND}" &>> ${DIR}/stdout.txt
    else
      eval "env time -v numactl --preferred=${NODE} " "${COMMAND}" &>> ${DIR}/stdout.txt
    fi
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
# Fourth argument is the node to use as a lower tier
function firsttouch_all_default {
  BASEDIR="$1"
  COMMAND="$2"
  NODE="$3"
  SLOWNODE="$4"

  # User output
  echo "Running experiment:"
  echo "  Config: 'firsttouch_all_default'"
  echo "  Upper tier: '${NODE}'"
  echo "  Lower tier: '${SLOWNODE}'"

  export SH_DEFAULT_NODE="${NODE}"
  export JE_MALLOC_CONF="oversize_threshold:0"

  eval "${PRERUN}"

  # Run 5 iters
  for i in {0..4}; do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    numastat -m &>> ${DIR}/numastat_before.txt
    if [[ "$(hostname)" = "JF1121-080209T" ]]; then
      eval "env time -v numactl --preferred=${NODE} numactl --cpunodebind=${NODE} --membind=${NODE},${SLOWNODE}" "${COMMAND}" &>> ${DIR}/stdout.txt
    else
      eval "env time -v numactl --preferred=${NODE}" "${COMMAND}" &>> ${DIR}/stdout.txt
    fi
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
# Fourth argument is the node to use as a lower tier
function firsttouch_all_shared_site {
  BASEDIR="$1"
  COMMAND="$2"
  NODE="$3"
  SLOWNODE="$4"

  # User output
  echo "Running experiment:"
  echo "  Config: 'firsttouch_all_shared_site'"
  echo "  Upper tier: '${NODE}'"
  echo "  Lower tier: '${SLOWNODE}'"

  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_DEFAULT_NODE="${NODE}"
  export JE_MALLOC_CONF="oversize_threshold:0"

  eval "${PRERUN}"

  # Run 5 iters
  for i in {0..4}; do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    if [[ "$(hostname)" = "JF1121-080209T" ]]; then
      eval "env time -v numactl --preferred=${NODE} numactl --cpunodebind=${NODE} --membind==${NODE},${SLOWNODE}" "${COMMAND}" &>> ${DIR}/stdout.txt
    else
      eval "env time -v numactl --preferred=${NODE}" "${COMMAND}" &>> ${DIR}/stdout.txt
    fi
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
# Fourth argument is the NUMA node to use as an upper tier
# Fifth argument is the NUMA node to use as a lower tier
function firsttouch_exclusive_device {
  BASEDIR="$1"
  COMMAND="$2"
  PERCENTAGE="$3"
  NODE="${4}"
  SLOWNODE="${5}"
  # Putting everything on DDR to get the peak RSS of the whole application
  if [[ "$(hostname)" = "JF1121-080209T" ]]; then
    CANARY_CFG="firsttouch_all_exclusive_device_1_3"
  else
    CANARY_CFG="firsttouch_all_exclusive_device_0_0"
  fi
  CANARY_STDOUT="${BASEDIR}/../${CANARY_CFG}/i0/stdout.txt"

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
  echo "  Upper tier: ${NODE}"
  echo "  Lower tier: ${SLOWNODE}"
  echo "  Pages on upper tier: ${NUM_PAGES}"

  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  export SH_DEFAULT_NODE=${NODE}
  export JE_MALLOC_CONF="oversize_threshold:0"

  eval "${PRERUN}"

  # Run 5 iters
  for i in {0..4}; do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches
    memreserve ${DIR} ${NUM_PAGES} ${NODE}
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    if [[ "$(hostname)" = "JF1121-080209T" ]]; then
      eval "env time -v numactl --preferred=${NODE} numactl --cpunodebind=${NODE} --membind=${SLOWNODE},${NODE} " "${COMMAND}" &>> ${DIR}/stdout.txt
    else
      eval "env time -v numactl --preferred=${NODE} " "${COMMAND}" &>> ${DIR}/stdout.txt
    fi
    numastat_kill
    pcm_kill
    memreserve_kill
  done
}

################################################################################
#                                     KNL Cache Mode                           #
################################################################################
# First argument is results directory
# Second argument is the command to run
function cache_mode {
  BASEDIR="$1"
  COMMAND="$2"
  NODE="0"
  SLOWNODE="0"

  # User output
  echo "Running experiment:"
  echo "  Config: 'firsttouch_all_exclusive_device'"
  echo "  Upper tier: '${NODE}'"
  echo "  Lower tier: '${SLOWNODE}'"

  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  export SH_DEFAULT_NODE="${NODE}"
  export JE_MALLOC_CONF="oversize_threshold:0"

  eval "${PRERUN}"

  # Run 5 iters
  for i in {0..4}; do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    if [[ "$(hostname)" = "JF1121-080209T" ]]; then
      eval "env time -v numactl --preferred=${NODE} numactl --cpunodebind=1 --membind=${NODE},${SLOWNODE} " "${COMMAND}" &>> ${DIR}/stdout.txt
    else
      eval "env time -v numactl --preferred=${NODE} " "${COMMAND}" &>> ${DIR}/stdout.txt
    fi
    numastat_kill
    pcm_kill
  done
}
