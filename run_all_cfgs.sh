#!/bin/bash

./run.sh $1 small firsttouch_all_exclusive_device 0
./run.sh $1 small firsttouch_all_shared_site 0
./run.sh $1 small firsttouch_all_exclusive_device 1
./run.sh $1 small pebs 128
./run.sh $1 small offline_all_pebs_guided 128 small knapsack
./run.sh $1 small offline_all_pebs_guided 128 small thermos

./run.sh $1 medium firsttouch_all_exclusive_device 0
./run.sh $1 medium firsttouch_all_shared_site 0
./run.sh $1 medium firsttouch_all_exclusive_device 1
./run.sh $1 medium pebs 128
./run.sh $1 medium offline_all_pebs_guided 128 small knapsack
./run.sh $1 medium offline_all_pebs_guided 128 small thermos
./run.sh $1 medium offline_all_pebs_guided 128 medium knapsack
./run.sh $1 medium offline_all_pebs_guided 128 medium thermos

./run.sh $1 large firsttouch_all_exclusive_device 0
./run.sh $1 large firsttouch_all_shared_site 0
./run.sh $1 large firsttouch_all_exclusive_device 1
./run.sh $1 large pebs 128
./run.sh $1 large offline_all_pebs_guided 128 small knapsack
./run.sh $1 large offline_all_pebs_guided 128 small thermos
./run.sh $1 large offline_all_pebs_guided 128 medium knapsack
./run.sh $1 large offline_all_pebs_guided 128 medium thermos
./run.sh $1 large offline_all_pebs_guided 128 large knapsack
./run.sh $1 large offline_all_pebs_guided 128 large thermos
