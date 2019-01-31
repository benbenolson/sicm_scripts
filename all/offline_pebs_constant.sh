#!/bin/bash

export PATH="$SICM_DIR/deps/bin:$PATH"
export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
export SH_DEFAULT_NODE="0"
export OMP_NUM_THREADS="256"

# First arg is directory to write to
function background {
  rm results/$1/numastat.txt
  while true; do
    echo "=======================================" &>> results/$1/numastat.txt
    numastat -m &>> results/$1/numastat.txt
    sleep 2
  done
}

# First argument is the frequency of PEBS sampling to use
# Second argument is the number of GB that should be available on the MCDRAM
# Third argument is the packing strategy
# Fourth argument is the command to run
function pebs {
  # This file is used for the profiling information
  if [ ! -r results/pebs_${1}/stdout.txt ]; then
    echo "ERROR: The file 'results/pebs_${1}/stdout.txt doesn't exist yet. Aborting."
    exit
  fi

  # This file is used to get the peak RSS
  if [ ! -r results/firsttouch_100_node0_exclusive_device/stdout.txt ]; then
    echo "ERROR: The file 'results/firsttouch_100_node0_exclusive_device/stdout.txt doesn't exist yet. Aborting."
    exit
  fi

  CONSTANTBYTES=$(echo "${2}/1024/1024/1024" | bc -l)
	DIR="results/offline_pebs_${1}_${2}GB_${3}"

  # User output
  echo "Running experiment:"
  echo "  Experiment: Offline PEBS-Guided"
  echo "  Profiling Frequency: '${1}'"
  echo "  Capacity: '${2}'"
  echo "  Packing algo: '${3}'"
  echo "  Command: '${4}'"
  
  rm -rf $DIR/
  mkdir -p $DIR/
  cat results/pebs_${1}/stdout.txt | $SICM_DIR/deps/bin/hotset pebs ${3} ratio ${RATIO} 1 > $DIR/guidance.txt
  export SH_GUIDANCE_FILE="$DIR/guidance.txt"
  for iter in {1..5}; do
    $SICM_DIR/deps/bin/memreserve 1 256 constant 4128116 release prefer # "Clear caches"
		sleep 5
    cat results/firsttouch_100_node0_exclusive_device/stdout.txt | $SICM_DIR/deps/bin/memreserve 1 256 ratio ${RATIO} hold bind &
    sleep 5
    numastat -m &>> $DIR/numastat_before.txt
    background "offline_pebs_${1}_${2}GB_${3}" &
    background_pid=$!
    eval "env time -v " "${4}" &>> $DIR/stdout.txt
    kill $background_pid
    wait $background_pid 2>/dev/null
    pkill memreserve
    sleep 5
  done
}
