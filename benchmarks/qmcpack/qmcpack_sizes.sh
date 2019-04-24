#!/bin/bash

SMALL="./qmcpack small.xml"
MEDIUM="./qmcpack medium.xml"
LARGE="./qmcpack large.xml"
OLD="./qmcpack old.xml"

function qmcpack_old_pebs_128 {
  export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:4"
}
