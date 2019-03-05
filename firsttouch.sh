#!/bin/bash

bench="lulesh"
size="large"
cfg="firsttouch_exclusive_device"

./run.sh ${bench} ${size} ${cfg} 5 && \
  ./run.sh ${bench} ${size} ${cfg} 10 && \
  ./run.sh ${bench} ${size} ${cfg} 15 && \
  ./run.sh ${bench} ${size} ${cfg} 20 && \
  ./run.sh ${bench} ${size} ${cfg} 25 && \
  ./run.sh ${bench} ${size} ${cfg} 30 && \
  ./run.sh ${bench} ${size} ${cfg} 35 && \
  ./run.sh ${bench} ${size} ${cfg} 40 && \
  ./run.sh ${bench} ${size} ${cfg} 45 && \
  ./run.sh ${bench} ${size} ${cfg} 50
