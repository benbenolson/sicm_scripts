#!/bin/bash

################################################################################
#                        numastat_background                                   #
################################################################################
# First arg is directory to write to
function numastat_background {
  rm $1/numastat.txt
  while true; do
    echo "=======================================" &>> $1/numastat.txt
    numastat -m &>> $1/numastat.txt
    sleep 2
  done
}

################################################################################
#                        firsttouch_exclusive_device                           #
################################################################################
# First argument is node to firsttouch onto
# Second argument is the command to run
function firsttouch_exclusive_device {
  # User output
  echo "Running experiment:"
  echo "  Experiment: Firsttouch Exclusive Device, 100%"
  echo "  Node: ${1}"
  echo "  Command: '${2}'"

  DIRECTORY="results/firsttouch_exclusive_device_100%"
  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export OMP_NUM_THREADS=256
  export SH_DEFAULT_NODE="${1}"

  # Run 5 iters
  rm -rf $DIRECTORY
  mkdir -p $DIRECTORY
  for iter in {1..5}; do
    sicm_memreserve 1 256 constant 4128116 release prefer # "Clear caches"
		sleep 5
    numastat -m &>> $DIRECTORY/numastat_before.txt
    numastat_background "$DIRECTORY" &
    background_pid=$!
    eval "env time -v numactl --preferred=${1}" "$2" &>> $DIRECTORY/stdout.txt
    kill $background_pid
    wait $background_pid 2>/dev/null
		sleep 5
  done
}


################################################################################
#                        firsttouch_default                                    #
################################################################################
# First argument is node to firsttouch onto
# Second argument is the command to run
function firsttouch_default {
  # User output
  echo "Running experiment:"
  echo "  Experiment: Firsttouch Default, 100%"
  echo "  Node: ${1}"
  echo "  Command: '${2}'"

  # Variables
  DIRECTORY="results/firsttouch_default_100%"
  export SH_DEFAULT_NODE="${1}"
  export OMP_NUM_THREADS=256

  # Run 5 iters
  rm -rf $DIRECTORY
  mkdir -p $DIRECTORY
  for iter in {1..5}; do
    sicm_memreserve 1 256 constant 4128116 release prefer # "Clear caches"
		sleep 5
    numastat -m &>> $DIRECTORY/numastat_before.txt
    numastat_background "$DIRECTORY" &
    background_pid=$!
    eval "env time -v numactl --preferred=${1}" "$2" &>> $DIRECTORY/stdout.txt
    kill $background_pid
    wait $background_pid 2>/dev/null
		sleep 5
  done
}


################################################################################
#                        firsttouch_shared_site                                #
################################################################################
# First argument is node to firsttouch onto
# Second argument is the command to run
function firsttouch_shared_site {
  # User output
  echo "Running experiment:"
  echo "  Experiment: Firsttouch Shared Site, 100%"
  echo "  Node: ${1}"
  echo "  Command: '${2}'"

  # Variables
  DIRECTORY="results/firsttouch_shared_site_100%"
  export SH_DEFAULT_NODE="${1}"
  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export OMP_NUM_THREADS=256

  # Run 5 iters
  rm -rf $DIRECTORY
  mkdir -p $DIRECTORY
  for iter in {1..5}; do
    numastat -m &>> $DIRECTORY/numastat_before.txt
    numastat_background "$DIRECTORY" &
    background_pid=$!
    sicm_memreserve 1 256 constant 4128116 release prefer # "Clear caches"
		sleep 5
    eval "env time -v numactl --preferred=${1}" "$2" &>> $DIRECTORY/stdout.txt
    kill $background_pid
    wait $background_pid 2>/dev/null
		sleep 5
  done
}


################################################################################
#                        firsttouch_constant                                   #
################################################################################
# Takes a constant in GB
# Second argument is the command to run
function firsttouch_constant_exclusive_device {

  # User output
  echo "Running experiment:"
  echo "  Experiment: Firsttouch"
  echo "  Capacity: ${1}GB"
  echo "  Command: '${2}'"

  DIRECTORY="results/firsttouch_constant_exclusive_device"
  CONSTANTBYTES=$(echo "${1}*1024*1024*1024" | bc -l)
  export OMP_NUM_THREADS=256
  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_DEFAULT_NODE="1"

  # Run 5 iters
  rm -rf $DIRECTORY
  mkdir -p $DIRECTORY
  for iter in {1..5}; do
    sicm_memreserve 1 256 constant 4128116 release prefer # "Clear caches"
		sleep 5
    sicm_memreserve 1 256 ratio ${CONSTANTBYTES} hold bind &>> $DIRECTORY/memreserve.txt &
    sleep 5
    numastat -m &>> $DIRECTORY/numastat_before.txt
    numastat_background "$DIRECTORY" &
    background_pid=$!
    eval "env time -v numactl --preferred=1 " "$2" &>> $DIRECTORY/stdout.txt
    kill $background_pid
    wait $background_pid 2>/dev/null
    pkill sicm_memreserve
    sleep 5
  done
}
