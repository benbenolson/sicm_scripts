#!/bin/bash

pcm_pid=0
numastat_pid=0
memreserve_pid=0

#############
# drop_caches
#############
function drop_caches {
  echo 3 | sudo tee /proc/sys/vm/drop_caches &>/dev/null
  sleep 5
}

#####################
# numastat_background
#####################
# First arg is directory to write to
function numastat_loop {
  rm -f $1/numastat.txt
  while true; do
    echo "=======================================" &>> $1/numastat.txt
    numastat -m &>> $1/numastat.txt
    sleep 2
  done
}
function numastat_background {
  numastat_loop "$1" &
  numastat_pid="$!"
}
function numastat_kill {
  sudo kill $numastat_pid &>/dev/null
  wait $numastat_pid &>/dev/null
}

############
# pcm_memory
############
# First arg is directory to write to
function pcm_background {
  rm -f $1/pcm-memory.txt
  sudo ${SCRIPTS_DIR}/tools/pcm/pcm-memory.x &> $1/pcm-memory.txt &
  pcm_pid=$!
}
function pcm_kill {
  sudo kill -9 $pcm_pid &>/dev/null
  sudo pkill -9 pcm-memory.x &>/dev/null
  wait $pcm_pid 2>/dev/null
}

############
# memreserve
############
# First arg is the directory to write to
# Second arg is the amount that should be left on the node
# Third arg is the NUMA node to reserve memory on
function memreserve {
    ${SCRIPTS_DIR}/all/memreserve ${3} ${2} \
      &>> $1/memreserve.txt &
    memreserve_pid="$!"

    sleep 60
}

function memreserve_kill {
  if [[ ${memreserve_pid} -ne 0 ]]; then
    kill -9 $memreserve_pid &>/dev/null
    pkill memreserve &>/dev/null
    wait $memreserve 2>/dev/null
    sleep 5
  fi
}
