#!/bin/bash

# One MB each node, two gigabytes, each stride is 64 bytes
export SMALL_AEP="${SICM_ENV} ./access_count 2048 1048576 16384 1"

function acess-count_prerun {
}
