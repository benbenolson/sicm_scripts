#!/bin/bash
source ./all/vars.sh

bench="lulesh"
#for bench in lulesh amg snap qmcpack cam-se; do
  # Heatmap with online
#  ./all/stat --graph_title='' --metric=graph_heatmap_top100 --filename=graphs/${bench}/${bench}_medium_heatmap_online_1000_top100.png ~/results/${bench}/medium_aep/online_memreserve_extent_size_con\:share_16_1000_1_1_20_0.075_0/i0/
  # Heatmap with online nobind
  #./all/stat --graph_title='' --metric=graph_heatmap_top100 --filename=graphs/${bench}_medium_heatmap_online_nobind_${online_interval_time}_top100.png ~/results/${bench}/medium_aep/online_memreserve_extent_size_nobind\:share_16_${online_interval_time}_1_1_20/i0/
  # Heatmap with offline
#  ./all/stat --graph_title='' --metric=graph_heatmap_top100 --filename=graphs/${bench}/${bench}_medium_heatmap_offline_1000_top100.png ~/results/${bench}/medium_aep/profile_all_and_extent_size_intervals\:16_1000_1/i0/
  #./all/stat --graph_title='' --metric=graph_heatmap_top100 --filename=graphs/${bench}_medium_heatmap_offline_10_top100.png ~/results/${bench}/medium_aep/profile_all_and_extent_size_intervals\:16_10_1/i0/
#done

#for bench in lulesh amg snap qmcpack cam-se; do
#  ./all/stat --graph_title='' --metric=graph_hotset_diff_top100 --filename=graphs/${bench}/${bench}_medium_hotset_diff_1000_top100.png ~/results/${bench}/medium_aep/online_memreserve_extent_size_con\:share_16_1000_1_1_20_0.075_0/i0/
#done

# Proposal
#bench="lulesh"
#./all/stat --eps --graph_title='' --metric=graph_heatmap_proposal --filename=graphs/${bench}/${bench}_medium_heatmap_proposal.eps ~/results/${bench}/medium_aep/profile_all_and_extent_size_intervals\:16_1000_1/i0/
#./all/stat --graph_title='' --metric=graph_heatmap_proposal --filename=graphs/${bench}/${bench}_medium_heatmap_proposal.png ~/results/${bench}/medium_aep/profile_all_and_extent_size_intervals\:16_1000_1/i0/
#bench="amg"
#./all/stat --eps --graph_title='' --metric=graph_heatmap_proposal --filename=graphs/${bench}/${bench}_medium_heatmap_proposal.eps ~/results/${bench}/medium_aep/profile_all_and_extent_size_intervals\:16_1000_1/i0/
#./all/stat --graph_title='' --metric=graph_heatmap_proposal --filename=graphs/${bench}/${bench}_medium_heatmap_proposal.png ~/results/${bench}/medium_aep/profile_all_and_extent_size_intervals\:16_1000_1/i0/

#./all/stat --eps --graph_title='' --metric=graph_heatmap_top100 --filename=graphs/${bench}/${bench}_medium_heatmap_top100_ski20.eps ~/results/${bench}/medium_aep/online_memreserve_ski_debug\:share_16_1000_20/i0/
#./all/stat --graph_title='' --metric=graph_heatmap_top100 --filename=graphs/${bench}/${bench}_medium_heatmap_top100_ski20.png ~/results/${bench}/medium_aep/online_memreserve_ski_debug\:share_16_1000_20/i0/

./all/stat --graph_title='' --metric=graph_online_bandwidth --filename=graphs/${bench}/${bench}_online_bandwidth_i0.png ~/results/${bench}/medium_aep/online_mr_ski_bw_relative_lat_rss_test:thermos_16_100_10_100_20/i0/
