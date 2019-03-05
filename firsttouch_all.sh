#!/bin/bash

bench="lulesh"
size="large"

./run.sh ${bench} ${size} firsttouch_all_exclusive_device 0 && \
  ./run.sh ${bench} ${size} firsttouch_all_exclusive_device 1
