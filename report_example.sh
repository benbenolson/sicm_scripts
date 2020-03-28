#!/bin/bash

./report.sh --bench=lulesh --size=medium_aep --metric=runtime \
  --config=online_memreserve_ski_debug --args=share,16,1000,20 \
  --config=firsttouch_shared_site --args=- \
  --iters=1
