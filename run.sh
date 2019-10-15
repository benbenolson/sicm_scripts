#!/bin/bash -l

# Set all per-platform options, based on the hostname
if [[ "$(hostname)" = "JF1121-080209T" ]]; then
  # Old CLX machine
  export PLATFORM_COMMAND="env time -v numactl --preferred=1 numactl --cpunodebind=1 --membind=1,3"
  export SH_UPPER_NODE="1"
  export SH_LOWER_NODE="3"
  export OMP_NUM_THREADS="48"
elif [[ "$(hostname)" = "ben-clx0" ]]; then
  # New CLX machine
  export PLATFORM_COMMAND="env time -v numactl --preferred=1 numactl --cpunodebind=1 --membind=1,3"
  export SH_UPPER_NODE="1"
  export SH_LOWER_NODE="3"
  export OMP_NUM_THREADS="40"
else
  # KNL
  export PLATFORM_COMMAND="env time -v numactl --preferred=1"
  export SH_UPPER_NODE="1"
  export SH_LOWER_NODE="0"
  export OMP_NUM_THREADS="256"
fi
export SH_MAX_THREADS=`expr ${OMP_NUM_THREADS} + 1`

source $SCRIPTS_DIR/all/args.sh
source $SCRIPTS_DIR/all/tools.sh
source $SCRIPTS_DIR/all/cfgs/firsttouch.sh
source $SCRIPTS_DIR/all/cfgs/pebs.sh
source $SCRIPTS_DIR/all/cfgs/offline_pebs.sh
source $SCRIPTS_DIR/all/cfgs/offline_mbi.sh
source $SCRIPTS_DIR/all/cfgs/offline_manual.sh
source $SCRIPTS_DIR/all/cfgs/mbi.sh
source $SCRIPTS_DIR/all/cfgs/oneoffs.sh
source $SCRIPTS_DIR/all/cfgs/online.sh

if [[ ${#BENCHES[@]} = 0 ]]; then
  echo "You didn't specify a benchmark name. Aborting."
  exit 1
fi

if [[ ${#CONFIGS[@]} = 0 ]]; then
  echo "You didn't specify a configuration name. Aborting."
  exit 1
fi

if [[ ! $SIZE ]]; then
  echo "You didn't specify a size. Aborting."
  exit 1
fi

# For the PCM tools
sudo modprobe msr

. $SPACK_DIR/share/spack/setup-env.sh
spack load $SICM@develop%gcc@7.2.0

# We need this for QMCPACK because otherwise it will link to an unpatched Flang, which will
# cause subtle issues due to their inexplicably overriding lots of NUMA functions to do nothing.
# It shouldn't adversely affect any other benchmarks.
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$(spack location -i flang-patched)/lib"

for BENCH_INDEX in ${!BENCHES[*]}; do
  for CONFIG_INDEX in ${!CONFIGS[*]}; do 
    BENCH="${BENCHES[${BENCH_INDEX}]}"
    BENCH_COMMAND="${BENCH_COMMANDS[${BENCH_INDEX}]}"
    CONFIG="${CONFIGS[${CONFIG_INDEX}]}"
    ARGS_SPACES="${CONFIG_ARGS[$CONFIG_INDEX]}"
    FULL_CONFIG="${FULL_CONFIGS[${CONFIG_INDEX}]}"

    # Set a function to do arbitrary commands depending on the benchmark
    # and benchmark size.
    export PRERUN="${BENCH}_prerun"

    # Create the results directory for this experiment,
    # and pass that to the BASH function
    DIRECTORY="${RESULTS_DIR}/${BENCH}/${SIZE}/${FULL_CONFIG}"
    if [[ ! ${CONFIG} == *"manual"* ]]; then
      echo "Removing directory"
      rm -rf ${DIRECTORY}
      mkdir -p ${DIRECTORY}
    fi

    # We want SICM to output its configuration for debugging
    export SH_LOG_FILE="${DIRECTORY}/config.txt"
    ulimit -c unlimited

    # Print out information about this run
    echo "Running experiment:"
    echo "  Benchmark: '${BENCH}'"
    echo "  Configuration: '${CONFIG}'"
    echo "  Configuration arguments: '${ARGS_SPACES}'"

    # Execute the BASH function with arguments
    export BASEDIR="${DIRECTORY}"
    export BENCH_COMMAND_ENV="LD_PRELOAD='$(spack location -i sicm-high)/lib/libsicm_overrides.so'"
    export COMMAND="${PLATFORM_COMMAND} env ${BENCH_COMMAND_ENV} ${BENCH_COMMAND}"

    cd $BENCH_DIR/${BENCH}/run
    ( eval "$CONFIG ${ARGS_SPACES}" )

  done
done
