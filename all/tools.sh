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

  # Get the amount of free memory on the node, in pages
  numastat -m &> $1/numastat_noreserve.txt
  NODE_FREE_MBYTES=$(${SCRIPTS_DIR}/all/stat \
    --metric=memfree --node=${3} $1/numastat_noreserve.txt)
  NODE_FREE_PAGES=$(echo "$NODE_FREE_MBYTES * 1024 / 4" | bc)

  if [[ ${NODE_FREE_PAGES} -gt ${2} ]]; then
    # Get how much to reserve to get the requested amount
    RESERVE=$(echo "$NODE_FREE_PAGES - $2" | bc)
    echo "Reserving ${RESERVE} pages."
    
    sicm_memreserve ${3} 64 ${RESERVE} hold bind \
      &>> $1/memreserve.txt &
    memreserve_pid="$!"

    sleep 60
  fi
}

function memreserve_kill {
  if [[ ${memreserve_pid} -ne 0 ]]; then
    kill -9 $memreserve_pid &>/dev/null
    pkill memreserve &>/dev/null
    wait $memreserve 2>/dev/null
    sleep 5
  fi
}
