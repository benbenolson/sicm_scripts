#!/bin/bash
# Arguments: [bench] [percentage] [metric]
CFGS=(firsttouch_exclusive_device_$2_1_0
offline_pebs_guided_128_small_knapsack_$2_1
offline_pebs_guided_128_small_hotset_$2_1
offline_pebs_guided_128_small_thermos_$2_1
offline_mbi_guided_small_knapsack_$2_1
offline_mbi_guided_small_hotset_$2_1
offline_mbi_guided_small_thermos_$2_1
)
CFGSTR=""
for cfg in ${CFGS[@]}; do
  CFGSTR="${cfg},${CFGSTR}"
done

./report.sh --benches=$1 --sizes=small \
  --cfgs=${CFGSTR} \
  --metric=$3
