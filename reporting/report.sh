#!/bin/bash -l
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${DIR}/../vars.sh

${SCRIPTS_DIR}/reporting/report $@
