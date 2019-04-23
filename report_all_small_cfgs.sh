#!/bin/bash

CFGS=(firsttouch_all_exclusive_device_0_0
firsttouch_all_exclusive_device_1_0
firsttouch_all_shared_site_0_0
firsttouch_all_shared_site_1_0
firsttouch_all_default_0_0
firsttouch_all_default_1_0
pebs_128
)
CFGSTR=""
for cfg in ${CFGS[@]}; do
  CFGSTR="${cfg},${CFGSTR}"
done

./report.sh --cfgs="${CFGSTR}" \
            --benches=$1 \
            --sizes=small \
            --metric=$2
