#!/bin/bash

export PERLLIB="$(readlink -f ./all):$PERLLIB"

${SCRIPTS_DIR}/all/report.pl "$@"
