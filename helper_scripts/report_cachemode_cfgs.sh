#!/bin/bash
# Arguments: [bench] [metric]

CFGS=(cache_mode)
CFGSTR=""
for cfg in ${CFGS[@]}; do
  CFGSTR="${cfg},${CFGSTR}"
done

./report.sh --benches=$1 --sizes=small,medium,large \
  --cfgs=${CFGSTR} \
  --metric=$2
