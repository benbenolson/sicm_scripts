#!/bin/bash

export PATH="$SICM_DIR/deps/bin:$PATH"
export OMP_NUM_THREADS=256

# First arg is directory to write to
function background {
  rm results/$1/numastat.txt
  while true; do
    echo "=======================================" &>> results/$1/numastat.txt
    numastat -m &>> results/$1/numastat.txt
    sleep 2
  done
}

# First argument is node to firsttouch onto
# Second argument is the command to run
function firsttouch {
  # User output
  echo "Running experiment:"
  echo "  Experiment: Firsttouch, 100%"
  echo "  Node: ${1}"
  echo "  Command: '${2}'"

  # Default to the given node
  export SH_DEFAULT_NODE="${1}"

  # Run 5 iters
  rm -rf results/firsttouch_100_node${1}/
  mkdir -p results/firsttouch_100_node${1}/
  for iter in {1..5}; do
    $SICM_DIR/deps/bin/memreserve 1 256 constant 4128116 release prefer # "Clear caches"
		sleep 5
    numastat -m &>> results/firsttouch_100_node${1}/numastat_before.txt
    background "firsttouch_100_node${1}" &
    background_pid=$!
    eval "env time -v numactl --preferred=${1}" "$2" &>> results/firsttouch_100_node${1}/stdout.txt
    kill $background_pid
    wait $background_pid 2>/dev/null
		sleep 5
  done
}
