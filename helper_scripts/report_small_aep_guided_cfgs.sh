#!/bin/bash
# Arguments: [bench] [percentage] [metric]
CFGS=(firsttouch_exclusive_device_$2_1_0
offline_pebs_guided_128_small_aep_knapsack_$2_1
offline_pebs_guided_128_small_aep_hotset_$2_1
offline_pebs_guided_128_small_aep_thermos_$2_1
)
CFGSTR=""
for cfg in ${CFGS[@]}; do
  CFGSTR="${cfg},${CFGSTR}"
done

./report.sh --benches=$1 --sizes=small \
  --cfgs=${CFGSTR} \
  --metric=$3
