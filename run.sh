#!/bin/bash -l
# First argument is the benchmark name
# Second argument is the benchmark size
# The third argument is the BASH function of the experiment.
# All subsequent arguments are its arguments

source $SCRIPTS_DIR/all/args.sh
source $SCRIPTS_DIR/all/tools.sh
source $SCRIPTS_DIR/all/cfgs/firsttouch.sh
source $SCRIPTS_DIR/all/cfgs/pebs.sh
source $SCRIPTS_DIR/all/cfgs/offline_pebs.sh
source $SCRIPTS_DIR/all/cfgs/offline_mbi.sh
source $SCRIPTS_DIR/all/cfgs/offline_manual.sh
source $SCRIPTS_DIR/all/cfgs/mbi.sh
source $SCRIPTS_DIR/all/cfgs/oneoffs.sh

if [[ ! $BENCH ]]; then
  echo "You didn't specify a benchmark name. Aborting."
  exit 1
fi

if [[ ! $CONFIG ]]; then
  echo "You didn't specify a configuration name. Aborting."
  exit 1
fi

if [[ ! $CONFIG_ARGS ]]; then
  echo "You didn't specify configuration arguments. Aborting."
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

#if [[ $1 == "qmcpack" ]]; then
#  if [[ "$(hostname)" = "JF1121-080209T" ]]; then
#    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/macslayer/spack/opt/spack/linux-fedora27-x86_64/gcc-7.2.0/flang-20180921-lqmxifeyjbpzmay6qajf6e3s2zds44im/lib"
#    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/macslayer/spack/opt/spack/linux-fedora27-x86_64/gcc-7.2.0/llvm-flang-20180921-drt5ldcolcud5ufd3ho5tplaliufhdlm/lib"
#    export LD_PRELOAD="/home/macslayer/spack/opt/spack/linux-fedora27-x86_64/gcc-7.2.0/flang-20180921-lqmxifeyjbpzmay6qajf6e3s2zds44im/lib/libflang.so /home/macslayer/spack/opt/spack/linux-fedora27-x86_64/gcc-7.2.0/flang-20180921-lqmxifeyjbpzmay6qajf6e3s2zds44im/lib/libflangrti.so"
#  else
#    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/macslayer/spack/opt/spack/linux-debian9-x86_64/gcc-7.2.0/flang-20180921-a2g3n2ugv7xdhzkntxfzxainujapch5v/lib"
#    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/macslayer/spack/opt/spack/linux-debian9-x86_64/gcc-7.2.0/llvm-flang-20180921-f2bzfqn5xo223a3y3jputvl7wtx3g4bw/lib"
#  fi
#fi

# Set a function to do arbitrary commands depending on the benchmark
# and benchmark size.
export PRERUN="${BENCH}_${SIZE}_${FULLCONFIG}"

# Create the results directory for this experiment,
# and pass that to the BASH function
DIRECTORY="${RESULTS_DIR}/${BENCH}/${SIZE}/${FULLCONFIG}"
if [[ ! ${CONFIG} == *"manual"* ]]; then
  echo "Removing directory"
  rm -rf ${DIRECTORY}
  mkdir -p ${DIRECTORY}
fi

# Print out information about this run
echo "Running experiment:"
echo "  Benchmark: '${BENCH}'"
echo "  Configuration: '${CONFIG}'"
echo "  Configuration arguments: '${CONFIG_ARGS_SPACES}'"

# Execute the BASH function with arguments
export BASEDIR="${DIRECTORY}"
export COMMAND="${BENCH_COMMAND}"
cd $BENCH_DIR/${BENCH}/run
eval "$CONFIG ${CONFIG_ARGS_SPACES}"
