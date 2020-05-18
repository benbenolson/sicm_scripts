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

#./run.sh --bench=lulesh --size=medium_aep --iters=5 \
#  --config=online_memreserve_ski_debug --args=share,128,10,20

#./run.sh --bench=lulesh --size=medium_aep --iters=1 \
#  --config=profile_all_and_extent_size_intervals --args=16,10,1 \
  
#./run.sh --bench=lulesh --size=medium_aep --iters=1 \
#  --config=offline_memreserve_extent_size --args=hotset,20 \
#  --profile="${HOME}/results/lulesh/medium_aep/profile_all_and_extent_size_intervals:16_10_1/i0"

#./run.sh --bench=lulesh --size=medium_aep --iters=1 \
#  --config=offline_memreserve_extent_size --args=hotset,20 \
#  --profile="${HOME}/results/lulesh/medium_aep/online_memreserve_ski_debug:share_128_10_20/i0/"

#./run.sh --bench=lulesh --size=medium_aep --iters=5 \
#  --config=firsttouch_exclusive_device --args=-
  
#./run.sh --bench=lulesh --size=medium_aep --iters=5 \
#  --config=firsttouch_shared_site --args=-
  
#./run.sh --bench=lulesh --size=medium_aep --iters=1 \
#  --config=profile_all_and_extent_size_intervals --args=128,10,1

#./run.sh --bench=lulesh --size=medium_aep --iters=5 \
#  --config=online_memreserve_ski_debug --args=share,128,10,20
  
#./run.sh --bench=lulesh --size=medium_aep --iters=5 \
#  --config=offline_memreserve_extent_size --args=hotset,20 \
#  --profile="${HOME}/results/lulesh/medium_aep/profile_all_and_extent_size_intervals:128_10_1/i0"

#./run.sh --bench=lulesh --size=medium_aep --iters=5 \
#  --config=offline_mr_all_rss --args=thermos,10 \
#  --config=offline_mr_all_rss --args=thermos,20 \
#  --config=offline_mr_all_rss --args=thermos,40 \
#  --config=offline_mr_all_rss --args=thermos,50 \
#  --profile="${HOME}/results/lulesh/medium_aep/profile_all_rss_es_int:16_10_100/i0/"

#./run.sh --bench=lulesh --size=medium_aep --iters=5 \
#  --config=online_mr_ski_bw_relative_rss --args=thermos,16,100,10,100,50 \
#  --config=online_mr_ski_bw_relative_es --args=thermos,16,100,10,100,50
#  --config=online_mr_ski_bw_relative_rss_tmp --args=thermos,16,100,10,100,20 \
#  --config=online_mr_ski_bw_relative_rss_tmp --args=thermos,16,100,10,100,40 \
#  --config=online_mr_ski_bw_relative_rss_tmp --args=thermos,16,100,10,100,50

./run.sh --bench=qmcpack --size=medium_aep --iters=1 \
  --config=firsttouch_shared_site --args=-

./run.sh --bench=qmcpack --size=medium_aep --iters=1 \
  --config=firsttouch_memreserve_shared_site --args=10 \
  --config=firsttouch_memreserve_shared_site --args=20 \
  --config=firsttouch_memreserve_shared_site --args=30 \
  --config=firsttouch_memreserve_shared_site --args=40 \
  --config=firsttouch_memreserve_shared_site --args=50
  
#./run.sh --bench=amg --size=medium_aep --iters=5 \
#  --config=offline_mr_all_rss --args=thermos,10 \
#  --config=offline_mr_all_rss --args=thermos,20 \
#  --config=offline_mr_all_rss --args=thermos,30 \
#  --config=offline_mr_all_rss --args=thermos,40 \
#  --config=offline_mr_all_rss --args=thermos,50

#./run.sh --bench=lulesh --size=medium_aep --iters=1 \
#  --config=profile_all_and_extent_size_intervals --args=16,10,1

#./run.sh --bench=lulesh --size=medium_aep --iters=5 \
#  --config=online_memreserve_rss_ski_debug --args=thermos,16,10,1000,100,share,30 \
#  --config=online_memreserve_rss_ski_debug --args=hotset,16,10,1000,100,share,30
