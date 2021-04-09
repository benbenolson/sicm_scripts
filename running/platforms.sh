#!/bin/bash -l

# This script just sets some variables based on your hostname.
# It's somewhat of a hack so that the scripts work on all of the machines that we do research on.
# That's why I've quarantined this behavior into this separate script...
# Currently, this script sets:
# SH_MAX_THREADS
# OMP_NUM_THREADS
# PLATFORM_COMMAND
# SH_UPPER_NODE
# SH_LOWER_NODE

NUM_NUMA_NODES=$(lscpu | awk '/NUMA node\(s\).*/{print $3;}')

if [[ "$(hostname)" = "canata" ]]; then

  # LANL's Canata machine
  export OMP_NUM_THREADS="48"
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
  
elif [[ "$(hostname)" = "chile" ]]; then

  # Jantz's Chile machine, a CLX machine with AEP 
  export OMP_NUM_THREADS="32"
  if [[ $NUM_NUMA_NODES = 2 ]]; then
    export PLATFORM_COMMAND="sudo -E /usr/bin/time -v numactl --preferred=0 numactl --membind=0,1 "
    export SH_UPPER_NODE="0"
    export SH_LOWER_NODE="1"
  else
    echo "COULDN'T DETECT HARDWARE CONFIGURATION. ABORTING."
    exit
  fi
  
else

  # Not sure
  echo "COULDN'T DETECT HARDWARE CONFIGURATION. ABORTING."
  exit

fi

export SH_MAX_THREADS=`expr ${OMP_NUM_THREADS} + 1`
