#!/bin/bash -l

# Set all per-platform options, based on the hostname
if [[ "$(hostname)" = "JF1121-080209T" ]]; then
  # Old CLX machine
  export OMP_NUM_THREADS="48"
elif [[ "$(hostname)" = "ben-clx0" ]]; then
  # New CLX machine
  export OMP_NUM_THREADS="40"
else
  # KNL
  export OMP_NUM_THREADS="256"
fi
export SH_MAX_THREADS=`expr ${OMP_NUM_THREADS} + 1`

source $SCRIPTS_DIR/all/args.sh
source $SCRIPTS_DIR/all/tools.sh
source $SCRIPTS_DIR/all/cfgs/firsttouch.sh
source $SCRIPTS_DIR/all/cfgs/profile.sh
source $SCRIPTS_DIR/all/cfgs/offline.sh
source $SCRIPTS_DIR/all/cfgs/online.sh
source $SCRIPTS_DIR/all/cfgs/multi_iter.sh

if [[ "$(hostname)" = "JF1121-080209T" ]]; then

  # Old CLX machine
  if [[ $NUM_NUMA_NODES = 4 ]]; then
    export PLATFORM_COMMAND="sudo -E env time -v numactl --preferred=1 numactl --cpunodebind=1 --membind=1,3"
    export SH_UPPER_NODE="1"
    export SH_LOWER_NODE="3"
  elif [[ $NUM_NUMA_NODES = 2 ]]; then
    export PLATFORM_COMMAND="sudo -E env time -v numactl --preferred=1 numactl --cpunodebind=1 --membind=1"
    export SH_UPPER_NODE="1"
    export SH_LOWER_NODE="1"
  else
    echo "COULDN'T DETECT HARDWARE CONFIGURATION. ABORTING."
    exit
  fi

elif [[ "$(hostname)" = "cce-clx-9.jf.intel.com" ]]; then

  echo "It's the new Intel machine"

  # New CLX machine
  if [[ $NUM_NUMA_NODES = 4 ]]; then
    export PLATFORM_COMMAND="sudo -E env time -v numactl --preferred=1 numactl --cpunodebind=1 --membind=1,3"
    export SH_UPPER_NODE="1"
    export SH_LOWER_NODE="3"
  elif [[ $NUM_NUMA_NODES = 2 ]]; then
    export PLATFORM_COMMAND="sudo -E env time -v numactl --preferred=1 numactl --cpunodebind=1 --membind=1"
    export SH_UPPER_NODE="1"
    export SH_LOWER_NODE="1"
  else
    echo "COULDN'T DETECT HARDWARE CONFIGURATION. ABORTING."
    exit
  fi

else

  # KNL
  if [[ $NUM_NUMA_NODES = 2 ]]; then
    export PLATFORM_COMMAND="sudo -E env time -v numactl --preferred=1"
    export SH_UPPER_NODE="1"
    export SH_LOWER_NODE="0"
  elif [[ $NUM_NUMA_NODES = 1 ]]; then
    export PLATFORM_COMMAND="sudo -E env time -v"
    export SH_UPPER_NODE="0"
    export SH_LOWER_NODE="0"
  else
    echo "COULDN'T DETECT HARDWARE CONFIGURATION. ABORTING."
    exit
  fi

fi

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
    export SETUP="${BENCH}_setup"

    # Create the results directory for this experiment,
    # and pass that to the BASH function
    DIRECTORY="${RESULTS_DIR}/${BENCH}/${SIZE}/${FULL_CONFIG}"
    if [[ ! ${CONFIG} == *"manual"* ]]; then
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
    export COMMAND="${PLATFORM_COMMAND} ${BENCH_COMMAND}"

    cd $BENCH_DIR/${BENCH}
    eval "${SETUP}"
    cd $BENCH_DIR/${BENCH}/run
    ( eval "$CONFIG ${ARGS_SPACES}" )

  done
done
