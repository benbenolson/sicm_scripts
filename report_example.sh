#!/bin/bash

#./report.sh --node=1 --bench="$1" --size=medium_aep --metric="$2" \
#  --config=online_mr_ski_bw_relative_lat_rss_test --args=thermos,16,100,10,100,10 \
#  --config=online_mr_ski_bw_relative_lat_rss_test --args=thermos,16,100,10,100,20 \
#  --config=online_mr_ski_bw_relative_lat_rss_test --args=thermos,16,100,10,100,30 \
#  --config=online_mr_ski_bw_relative_lat_rss_test --args=thermos,16,100,10,100,40 \
#  --config=online_mr_ski_bw_relative_lat_rss_test --args=thermos,16,100,10,100,50 \
#  --config=offline_mr_all_rss --args=thermos,10 \
#  --config=offline_mr_all_rss --args=thermos,20 \
#  --config=offline_mr_all_rss --args=thermos,30 \
#  --config=offline_mr_all_rss --args=thermos,40 \
#  --config=offline_mr_all_rss --args=thermos,50 \
#  --config=firsttouch_memreserve_shared_site --args=10 \
#  --config=firsttouch_memreserve_shared_site --args=20 \
#  --config=firsttouch_memreserve_shared_site --args=30 \
#  --config=firsttouch_memreserve_shared_site --args=40 \
#  --config=firsttouch_memreserve_shared_site --args=50

./report.sh --node=1 --bench=lulesh --size=medium_aep --metric="$1" \
  --config=online_mr_ski_bw_relative_lat_es_test --args=thermos,16,100,10,100,20 \
  --config=online_mr_ski_bw_relative_lat_es_test --args=thermos,16,100,100,100,20 \
  --config=online_mr_ski_bw_relative_lat_rss_test --args=thermos,16,100,10,100,20 \
  --config=online_mr_ski_bw_relative_lat_rss_test --args=thermos,16,100,100,100,20 \
  --config=profile_all_rss_int --args=16,10,10 \
  --config=profile_all_rss_int --args=16,10,100 \
  --config=profile_all_es_int --args=16,10,10 \
  --config=profile_all_es_int --args=16,10,100
  
./report.sh --node=1 --bench=amg --size=medium_aep --metric="$1" \
  --config=online_mr_ski_bw_relative_lat_rss_test --args=thermos,16,100,10,100,20 \
  --config=online_mr_ski_bw_relative_lat_rss_test --args=thermos,16,100,100,100,20
