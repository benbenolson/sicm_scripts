#!/bin/bash
# Arguments: [bench] [size] [metric]

CFGS=(pebs_128
offline_all_pebs_guided_128_$2_thermos_1_3
firsttouch_all_exclusive_device_1_3
firsttouch_all_exclusive_device_1_1
)
CFGSTR=""
for cfg in ${CFGS[@]}; do
  CFGSTR="${cfg},${CFGSTR}"
done

./report.sh --benches=$1 --sizes=$2 \
  --cfgs=${CFGSTR} \
  --metric=$3
