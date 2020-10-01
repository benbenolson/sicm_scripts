#!/bin/bash

OLD="./amg -problem 2 -n 120 120 120"
SMALL="./amg -problem 2 -n 120 120 120"
MEDIUM="./amg -problem 2 -n 220 220 220"
LARGE="./amg -problem 2 -n 270 270 270"

SMALL_AEP="${SICM_ENV} ./amg -problem 2 -n 180 180 180"
MEDIUM_AEP="${SICM_ENV} ./amg -problem 2 -n 340 340 340"
LARGE_AEP="${SICM_ENV} ./amg -problem 2 -n 520 520 520"
HUGE_AEP="${SICM_ENV} ./amg -problem 2 -n 600 600 600"

function amg_prerun {
  export SH_MAX_SITES="8800"
}
