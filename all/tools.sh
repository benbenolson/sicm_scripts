#!/bin/bash

pcm_pid=0
numastat_pid=0

################################################################################
#                                drop_caches                                   #
################################################################################
function drop_caches {
  echo 3 | sudo tee /proc/sys/vm/drop_caches
  sleep 5
}

################################################################################
#                        numastat_background                                   #
################################################################################
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
  sudo kill $numastat_pid
  wait $numastat_pid 2>/dev/null
  sleep 5
}

################################################################################
#                             pcm_background                                   #
################################################################################
# First arg is directory to write to
function pcm_background {
  rm -f $1/pcm-memory.txt
  sudo ${SCRIPTS_DIR}/tools/pcm/pcm-memory.x &> $1/pcm-memory.txt &
  pcm_pid=$!
}
function pcm_kill {
  sudo kill $pcm_pid
  wait $pcm_pid 2>/dev/null
  sleep 5
}
