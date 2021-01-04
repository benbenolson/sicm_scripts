#!/bin/bash

SMALL="./qmcpack small.xml"
MEDIUM="./qmcpack medium.xml"
LARGE="./qmcpack large.xml"
OLD="./qmcpack old.xml"

SMALL_AEP=" ./qmcpack small_aep.xml"
MEDIUM_AEP=" ./qmcpack medium_aep.xml"
LARGE_AEP=" ./qmcpack large_aep.xml"
HUGE_AEP=" ./qmcpack huge_aep.xml"

function qmcpack_prerun {
  export SH_MAX_SITES="30400"
}
