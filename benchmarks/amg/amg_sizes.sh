#!/bin/bash

OLD="./amg -problem 2 -n 120 120 120"
SMALL="./amg -problem 2 -n 120 120 120"
MEDIUM="./amg -problem 2 -n 220 220 220"
LARGE="./amg -problem 2 -n 270 270 270"

function amg_large {
  export JE_MALLOC_CONF="oversize_threshold:2147483648,background_thread:true,max_background_threads:4"
}
