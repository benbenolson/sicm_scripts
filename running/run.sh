#!/bin/bash -l
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${DIR}/../vars.sh

source ${SCRIPTS_DIR}/running/platforms.sh
source ${SCRIPTS_DIR}/running/run_utils.sh
source ${SCRIPTS_DIR}/running/tools.sh

# Each configuration is just a BASH function in one of these files
source ${SCRIPTS_DIR}/running/cfgs/firsttouch.sh
source ${SCRIPTS_DIR}/running/cfgs/profile.sh
source ${SCRIPTS_DIR}/running/cfgs/offline.sh
source ${SCRIPTS_DIR}/running/cfgs/online.sh

# Get SICM stuff into the environment
export PATH="${SICM_PREFIX}/bin:${PATH}"
export LD_LIBRARY_PATH_TMP="${SICM_PREFIX}/lib:${SICM_PREFIX}/lib/clang/7.1.0/lib/:${LD_LIBRARY_PATH}"
export LD_PRELOAD_TMP="${SICM_PREFIX}/lib/libsicm_overrides.so ${SICM_PREFIX}/lib/libsicm_runtime.so ${SICM_PREFIX}/lib/libjemalloc.so"
export SICM_ENV="env LD_LIBRARY_PATH='${LD_LIBRARY_PATH_TMP}' LD_PRELOAD='${LD_PRELOAD_TMP}'"
export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"

for BENCH_INDEX in ${!BENCHES[*]}; do
  for CONFIG_INDEX in ${!CONFIGS[*]}; do
    BENCH="${BENCHES[${BENCH_INDEX}]}"
    BENCH_COMMAND="${BENCH_COMMANDS[${BENCH_INDEX}]}"
    CONFIG="${CONFIGS[${CONFIG_INDEX}]}"
    CONFIG_NAME=$( get_config_name ${CONFIG} )
    CONFIG_ARGS=$( get_config_args ${CONFIG} )

    # Set a function to do arbitrary commands depending on the benchmark
    # and benchmark size.
    export PRERUN="${BENCH}_prerun"
    export SETUP="${BENCH}_setup"

    # Create the results directory for this experiment,
    # and pass that to the BASH function
    DIRECTORY="${RESULTS_DIR}/${BENCH}/${SIZE}/${CONFIG}"
    if [[ ! ${CONFIG} == *"manual"* ]]; then
      rm -rf ${DIRECTORY}
    fi
    mkdir -p ${DIRECTORY}

    # We want SICM to output its configuration for debugging
    export SH_LOG_FILE="${DIRECTORY}/config.txt"
    ulimit -c unlimited
    ulimit -s unlimited
    ulimit -S -s unlimited

    # Print out information about this run
    echo "Running experiment:"
    echo "  Benchmark: '${BENCH}'"
    echo "  Configuration: '${CONFIG}'"

    # Execute the BASH function with arguments
    export BASEDIR="${DIRECTORY}"
    export COMMAND="${PLATFORM_COMMAND} ${SICM_ENV} ${BENCH_COMMAND}"

    cd $BENCH_DIR/${BENCH}
    eval "${SETUP}"
    cd $BENCH_DIR/${BENCH}/run
    ( eval "$CONFIG_NAME ${CONFIG_ARGS}" )

  done
done
