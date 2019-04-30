#!/bin/bash
# Arguments: [bench] [metric]

CFGS=(firsttouch_all_exclusive_device_0_0
firsttouch_all_exclusive_device_1_0
firsttouch_all_shared_site_0_0
firsttouch_all_shared_site_1_0
firsttouch_all_default_0_0
firsttouch_all_default_1_0
pebs_128
offline_all_pebs_guided_128_small_knapsack_1_0
offline_all_pebs_guided_128_small_hotset_1_0
offline_all_pebs_guided_128_small_thermos_1_0
offline_all_pebs_guided_128_medium_knapsack_1_0
offline_all_pebs_guided_128_medium_hotset_1_0
offline_all_pebs_guided_128_medium_thermos_1_0
offline_all_pebs_guided_128_large_knapsack_1_0
offline_all_pebs_guided_128_large_hotset_1_0
offline_all_pebs_guided_128_large_thermos_1_0
)
CFGSTR=""
for cfg in ${CFGS[@]}; do
  CFGSTR="${cfg},${CFGSTR}"
done

./report.sh --benches=$1 --sizes=medium,large \
  --cfgs=${CFGSTR} \
  --metric=$2
