#!/bin/bash

export SMALL="./snap small.txt test.txt"
export MEDIUM="./snap medium.txt test.txt"
export LARGE="./snap large.txt test.txt"

function snap_large_pebs_128 {
  export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:2"
}
