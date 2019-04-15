#!/bin/bash -l
# First argument is the benchmark name
# Second argument is the benchmark size
# The third argument is the BASH function of the experiment.
# All subsequent arguments are its arguments

source $SCRIPTS_DIR/all/tools.sh
source $SCRIPTS_DIR/all/firsttouch.sh
source $SCRIPTS_DIR/all/pebs.sh
source $SCRIPTS_DIR/all/offline_pebs.sh
source $SCRIPTS_DIR/all/mbi.sh

# For the PCM tools
sudo modprobe msr

if [[ "$(hostname)" = "JF1121-080209T" ]]; then
  module load sicm-high-develop-gcc-7.2.0-3z2gouy
else
  module load sicm-high-develop-gcc-7.2.0-ajlq464
fi

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
elif [[ $2 == "small_aep" ]]; then
  COMMAND="$SMALL_AEP"
elif [[ $2 == "medium_aep" ]]; then
  COMMAND="$MEDIUM_AEP"
elif [[ $2 == "large_aep" ]]; then
  COMMAND="$LARGE_AEP"
elif [[ $2 == "huge_aep" ]]; then
  COMMAND="$HUGE_AEP"
else
  echo "Unknown benchmark size. Aborting."
  exit 1
fi

# Set OMP_NUM_THREADS
if [[ "$(hostname)" = "JF1121-080209T" ]]; then
  if [[ "$3" = "pebs_128" ]]; then
    export OMP_NUM_THREADS=46
  else
    export OMP_NUM_THREADS=48
  fi
else
  if [[ "$3" = "pebs_128" ]]; then
    export OMP_NUM_THREADS=270
  else
    export OMP_NUM_THREADS=272
  fi
fi

# Construct a string of the arguments to the BASH function.
# This is used to generate the results directory.
CONFIG="${3}"
for arg in ${@:4}; do
  CONFIG="${CONFIG}_$arg"
done

# Set a function to do arbitrary commands depending on the benchmark
# and benchmark size.
export PRERUN="${1}_${2}_${CONFIG}"

# Create the results directory for this experiment,
# and pass that to the BASH function
DIRECTORY="${RESULTS_DIR}/${1}/${2}/${CONFIG}"
rm -rf ${DIRECTORY}
mkdir -p ${DIRECTORY}

# Execute the BASH function with arguments
# $3 contains the BASH function name
# ${DIRECTORY} contains the directory that we want to write results into
# ${COMMAND} contains the command to run the benchmark
# ${@:4} contains the arguments to pass to the BASH function
cd $BENCH_DIR/${1}/run
eval "$3 '${DIRECTORY}' '${COMMAND}' ${@:4}"
