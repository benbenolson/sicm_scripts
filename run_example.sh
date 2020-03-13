#!/bin/bash

# Example firsttouch
#./run.sh --bench=lulesh --size=medium_aep --iters=1 \
#  --config=firsttouch_exclusive_device --args=- \
#  --config=firsttouch_shared_site --args=- \

# Example firsttouch memreserve
#./run.sh --bench=lulesh --size=medium_aep --iters=1 \
#  --config=firsttouch_memreserve_shared_site --args=20 \

# Example profiling
#./run.sh --bench=lulesh --size=medium_aep --iters=1 \
#  --config=profile_all_and_extent_size_intervals --args=16,1000,1 \
#  --config=profile_all_and_extent_size_intervals --args=16,10,1

# Example offline
#./run.sh --bench=lulesh --size=medium_aep --iters=1 \
#  --config=offline_memreserve_extent_size --args=hotset,20 \
#  --profile="${HOME}/results/lulesh/medium_aep/profile_all_and_extent_size_intervals:16_1000_1/i0"

# Example online
#./run.sh --bench=amg --size=medium_aep --iters=3 \
#  --config=online_memreserve_extent_size_orig_debug --args=share,16,1000,1,1,20,0.075,0

#./run.sh --bench=access-count --size=small_aep --iters=1 \
#  --config=profile_cache_miss_and_extent_size_intervals --args=16,10,1

./run.sh --bench=lulesh --size=small_aep --iters=1 \
  --config=firsttouch_exclusive_device --args=- \
