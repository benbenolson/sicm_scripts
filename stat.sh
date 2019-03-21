#!/bin/bash -l

export PERLLIB="$(readlink -f ${SCRIPTS_DIR}/all):$PERLLIB"

${SCRIPTS_DIR}/all/stat.pl "$@"
