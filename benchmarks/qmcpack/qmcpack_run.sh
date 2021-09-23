#!/bin/bash

SMALL=" ./qmcpack small_aep.xml"
MEDIUM=" ./qmcpack medium_aep.xml"
LARGE=" ./qmcpack large.xml"
HUGE=" ./qmcpack huge_aep.xml"

function qmcpack_prerun {
  export SH_MAX_SITES="30400"
}
