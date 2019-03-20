#!/bin/bash -l
# First argument is the benchmark name
# Second argument is the benchmark size
# The third argument is the BASH function of the experiment.
# All subsequent arguments are its arguments

source $SCRIPTS_DIR/all/tools.sh
source $SCRIPTS_DIR/all/firsttouch.sh
source $SCRIPTS_DIR/all/pebs.sh
source $SCRIPTS_DIR/all/offline_pebs.sh

# For the PCM tools
sudo modprobe msr

module load sicm-high-develop-gcc-7.2.0-yqtlckm

if [[ $1 == "qmcpack" ]]; then
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/macslayer/spack/opt/spack/linux-debian9-x86_64/gcc-7.2.0/flang-20180921-a2g3n2ugv7xdhzkntxfzxainujapch5v/lib"
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/macslayer/spack/opt/spack/linux-debian9-x86_64/gcc-7.2.0/llvm-flang-20180921-f2bzfqn5xo223a3y3jputvl7wtx3g4bw/lib"
fi

# Set $COMMAND to the command that runs the benchmark
source $SCRIPTS_DIR/benchmarks/${1}/${1}_sizes.sh
COMMAND=""
if [[ $2 == "small" ]]; then
  COMMAND="$SMALL"
elif [[ $2 == "medium" ]]; then
  COMMAND="$MEDIUM"
elif [[ $2 == "large" ]]; then
  COMMAND="$LARGE"
elif [[ $2 == "old" ]]; then
  COMMAND="$OLD"
else
  echo "Unknown benchmark size. Aborting."
  exit 1
fi

# Construct a string of the arguments to the BASH function.
# This is used to generate the results directory.
CONFIG="${3}"
for arg in ${@:4}; do
  CONFIG="${CONFIG}_$arg"
done

# Create the results directory for this experiment,
# and pass that to the BASH function
DIRECTORY="${BENCH_DIR}/${1}/run/results/${2}/${CONFIG}"
rm -rf ${DIRECTORY}
mkdir -p ${DIRECTORY}

# Execute the BASH function with arguments
# $3 contains the BASH function name
# ${DIRECTORY} contains the directory that we want to write results into
# ${COMMAND} contains the command to run the benchmark
# ${@:4} contains the arguments to pass to the BASH function
cd $BENCH_DIR/${1}/run
eval "$3 '${DIRECTORY}' '${COMMAND}' ${@:4}"
