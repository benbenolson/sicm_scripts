#!/bin/bash
# Arguments: [bench] [size] [metric]

CFGS=(firsttouch_all_exclusive_device_1_1
firsttouch_all_exclusive_device_1_3
offline_all_pebs_guided_128_huge_aep_thermos_1_3
offline_all_pebs_guided_128_large_aep_thermos_1_3
offline_all_pebs_guided_128_medium_aep_thermos_1_3
offline_all_pebs_guided_128_small_aep_thermos_1_3
offline_all_pebs_guided_128_huge_aep_hotset_1_3
offline_all_pebs_guided_128_large_aep_hotset_1_3
offline_all_pebs_guided_128_medium_aep_hotset_1_3
offline_all_pebs_guided_128_small_aep_hotset_1_3
offline_all_pebs_guided_128_huge_aep_knapsack_1_3
offline_all_pebs_guided_128_large_aep_knapsack_1_3
offline_all_pebs_guided_128_medium_aep_knapsack_1_3
offline_all_pebs_guided_128_small_aep_knapsack_1_3
pebs_128
)
CFGSTR=""
for cfg in ${CFGS[@]}; do
  CFGSTR="${cfg},${CFGSTR}"
done

./report.sh --benches=$1 --sizes=$2 \
  --cfgs=${CFGSTR} \
  --metric=$3
