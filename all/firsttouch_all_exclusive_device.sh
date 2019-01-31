#!/bin/bash

export PATH="$SICM_DIR/deps/bin:$PATH"
export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
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
  echo "  Experiment: Firsttouch Exclusive Device, 100%"
  echo "  Node: ${1}"
  echo "  Command: '${2}'"

  # Default to the given node
  export SH_DEFAULT_NODE="${1}"
	export MALLOC_CONF="retain:false"

  # Run 5 iters
  rm -rf results/firsttouch_100_node${1}_exclusive_device/
  mkdir -p results/firsttouch_100_node${1}_exclusive_device/
  for iter in {1..5}; do
    $SICM_DIR/deps/bin/memreserve 1 256 constant 4128116 release prefer # "Clear caches"
		sleep 5
    numastat -m &>> results/firsttouch_100_node${1}_exclusive_device/numastat_before.txt
    background "firsttouch_100_node${1}_exclusive_device" &
    background_pid=$!
    eval "env time -v numactl --preferred=${1}" "$2" &>> results/firsttouch_100_node${1}_exclusive_device/stdout.txt
    kill $background_pid
    wait $background_pid 2>/dev/null
		sleep 5
  done
}
