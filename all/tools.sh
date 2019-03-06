#!/bin/bash

################################################################################
#                        numastat_background                                   #
################################################################################
# First arg is directory to write to
function numastat_background {
  rm -f $1/numastat.txt
  rm -f $1/pcm-memory.txt
  sudo ${SCRIPTS_DIR}/tools/pcm/pcm-memory.x &> $1/pcm-memory.txt
  while true; do
    echo "=======================================" &>> $1/numastat.txt
    numastat -m &>> $1/numastat.txt
    sleep 2
  done
}
