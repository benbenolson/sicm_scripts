#!/bin/bash

export SMALL="./snap small.txt test.txt"
export MEDIUM="./snap medium.txt test.txt"
export LARGE="./snap large.txt test.txt"

export SMALL_AEP="./snap small_aep.txt test.txt"
export MEDIUM_AEP="./snap medium_aep.txt test.txt"
export LARGE_AEP="./snap large_aep.txt test.txt"
export HUGE_AEP="./snap huge_aep.txt test.txt"

function snap_large_pebs_128 {
  export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:2"
}
