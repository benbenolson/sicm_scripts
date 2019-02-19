#!/bin/bash
# First argument is the benchmark name
# Second argument is the benchmark size
# The third argument is the BASH function of the experiment.
# All subsequent arguments are its arguments

source $SCRIPTS_DIR/all/firsttouch.sh

echo "Loading Spack module of SICM..."
. $SPACK_DIR/share/spack/setup-env.sh
module use "$(spack location -r)/share/spack/modules/cray-cnl6-sandybridge"
spack load sicm-high
spack load time@1.9

echo "Running $1"
echo "  Size: $2"
echo "  Experiment: $3"
echo "  Arguments: ${@:4}"

# Set $COMMAND to the command that runs the benchmark
source $SCRIPTS_DIR/benchmarks/${1}/${1}_sizes.sh
COMMAND=""
if [[ $2 == "small" ]]; then
  COMMAND="$SMALL"
elif [[ $2 == "large" ]]; then
  COMMAND="$LARGE"
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
echo "USING COMMAND: '${COMMAND}'"
cd $BENCH_DIR/${1}/run
eval "$3 '${DIRECTORY}' '${COMMAND}' ${@:4}"
