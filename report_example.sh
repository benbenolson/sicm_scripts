#!/bin/bash

./report.sh --bench=lulesh --bench=amg --size=medium_aep --metric=runtime \
  --config=offline_memreserve_extent_size --args=hotset,20 \
  --config=online_memreserve_extent_size_con --args=share,16,1000,1,1,20,0.075,0
