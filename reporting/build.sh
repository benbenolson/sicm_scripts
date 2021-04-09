#!/bin/bash -l
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${DIR}/../vars.sh

INCLUDE="-I${SICM_PREFIX}/include"
cd ${SCRIPTS_DIR}/reporting
gcc -g report.c ${INCLUDE} -o report -lm
