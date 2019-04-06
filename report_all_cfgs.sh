#!/bin/bash

CFGS=(pebs_128
      firsttouch_all_shared_site_0
      firsttouch_all_exclusive_device_0
      firsttouch_all_exclusive_device_1
      offline_all_pebs_guided_128_small_knapsack
      offline_all_pebs_guided_128_medium_knapsack
      offline_all_pebs_guided_128_large_knapsack
      offline_all_pebs_guided_128_small_thermos
      offline_all_pebs_guided_128_medium_thermos
      offline_all_pebs_guided_128_large_thermos)
CFGSTR=""
for cfg in ${CFGS[@]}; do
  CFGSTR="${cfg},${CFGSTR}"
done

./report.sh --cfgs="${CFGSTR}" \
            --benches=$1 \
            --sizes=small,medium,large \
            --metric=runtime
