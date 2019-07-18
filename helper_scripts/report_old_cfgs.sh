#!/bin/bash

CFGS=(pebs_128
      firsttouch_all_exclusive_device_0
      firsttouch_all_exclusive_device_1
      firsttouch_exclusive_device_12.5
      offline_pebs_guided_128_old_knapsack_12.5
      offline_pebs_guided_128_old_thermos_12.5
      firsttouch_exclusive_device_25
      offline_pebs_guided_128_old_knapsack_25
      offline_pebs_guided_128_old_thermos_25
      firsttouch_exclusive_device_50
      offline_pebs_guided_128_old_knapsack_50
      offline_pebs_guided_128_old_thermos_50
)
CFGSTR=""
for cfg in ${CFGS[@]}; do
  CFGSTR="${cfg},${CFGSTR}"
done

./report.sh --cfgs="${CFGSTR}" \
            --benches=$1 \
            --sizes=old \
            --metric=runtime
