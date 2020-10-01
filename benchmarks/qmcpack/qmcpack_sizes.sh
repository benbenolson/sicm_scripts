#!/bin/bash

SMALL="./qmcpack small.xml"
MEDIUM="./qmcpack medium.xml"
LARGE="./qmcpack large.xml"
OLD="./qmcpack old.xml"

SMALL_AEP="${SICM_ENV} ./qmcpack small_aep.xml"
MEDIUM_AEP="${SICM_ENV} ./qmcpack medium_aep.xml"
LARGE_AEP="${SICM_ENV} ./qmcpack large_aep.xml"
HUGE_AEP="${SICM_ENV} ./qmcpack huge_aep.xml"

function qmcpack_prerun {
  export SH_MAX_SITES="30000"
}
