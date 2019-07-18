#!/bin/bash

./run.sh $1 medium firsttouch_all_exclusive_device 0 0
./run.sh $1 medium firsttouch_all_exclusive_device 1 0
./run.sh $1 medium firsttouch_all_shared_site 0 0
./run.sh $1 medium firsttouch_all_shared_site 1 0
./run.sh $1 medium firsttouch_all_default 0 0
./run.sh $1 medium firsttouch_all_default 1 0
./run.sh $1 medium pebs 128

# PEBS-guided
./run.sh $1 medium offline_all_pebs_guided 128 small knapsack 1 0
./run.sh $1 medium offline_all_pebs_guided 128 small hotset 1 0
./run.sh $1 medium offline_all_pebs_guided 128 small thermos 1 0
./run.sh $1 medium offline_all_pebs_guided 128 medium knapsack 1 0
./run.sh $1 medium offline_all_pebs_guided 128 medium hotset 1 0
./run.sh $1 medium offline_all_pebs_guided 128 medium thermos 1 0

# MBI-guided
./run.sh $1 medium offline_all_mbi_guided small knapsack 1 0
./run.sh $1 medium offline_all_mbi_guided small hotset 1 0
./run.sh $1 medium offline_all_mbi_guided small thermos 1 0

./run.sh $1 large firsttouch_all_exclusive_device 0 0
./run.sh $1 large firsttouch_all_exclusive_device 1 0
./run.sh $1 large firsttouch_all_shared_site 0 0
./run.sh $1 large firsttouch_all_shared_site 1 0
./run.sh $1 large firsttouch_all_default 0 0
./run.sh $1 large firsttouch_all_default 1 0
./run.sh $1 large pebs 128

# PEBS-guided
./run.sh $1 large offline_all_pebs_guided 128 small knapsack 1 0
./run.sh $1 large offline_all_pebs_guided 128 small hotset 1 0
./run.sh $1 large offline_all_pebs_guided 128 small thermos 1 0
./run.sh $1 large offline_all_pebs_guided 128 medium knapsack 1 0
./run.sh $1 large offline_all_pebs_guided 128 medium hotset 1 0
./run.sh $1 large offline_all_pebs_guided 128 medium thermos 1 0
./run.sh $1 large offline_all_pebs_guided 128 large knapsack 1 0
./run.sh $1 large offline_all_pebs_guided 128 large hotset 1 0
./run.sh $1 large offline_all_pebs_guided 128 large thermos 1 0

# MBI-guided
./run.sh $1 large offline_all_mbi_guided small knapsack 1 0
./run.sh $1 large offline_all_mbi_guided small hotset 1 0
./run.sh $1 large offline_all_mbi_guided small thermos 1 0
