#!/bin/bash

export SMALL="./lulesh2.0 -s 220 -i 12 -r 11 -b 0 -c 64 -p"
export MEDIUM="./lulesh2.0 -s 340 -i 12 -r 11 -b 0 -c 64 -p"
export LARGE="./lulesh2.0 -s 420 -i 12 -r 11 -b 0 -c 64 -p"
export OLD="./lulesh2.0 -s 220 -i 5 -r 11 -b 0 -c 64 -p"

function lulesh_old_pebs_128 {
  echo "Setting special parameters for this size and config."
  export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
}
