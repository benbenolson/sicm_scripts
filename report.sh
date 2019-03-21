#!/bin/bash -l

module load sicm-high-develop-gcc-7.2.0-yqtlckm
export PERLLIB="$(readlink -f ./all):$PERLLIB"

${SCRIPTS_DIR}/all/report.pl "$@"
