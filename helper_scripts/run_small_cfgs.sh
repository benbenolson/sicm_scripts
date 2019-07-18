#!/bin/bash

./run.sh $1 small firsttouch_all_exclusive_device 0 0
./run.sh $1 small firsttouch_all_exclusive_device 1 0

./run.sh $1 small firsttouch_all_default 0 0
./run.sh $1 small firsttouch_all_default 1 0

./run.sh $1 small firsttouch_all_shared_site 0 0
./run.sh $1 small firsttouch_all_shared_site 1 0

./run.sh $1 small pebs 128
#./run.sh $1 small mbi

./run.sh $1 small firsttouch_exclusive_device 5 1 0
./run.sh $1 small firsttouch_exclusive_device 10 1 0
./run.sh $1 small firsttouch_exclusive_device 15 1 0
./run.sh $1 small firsttouch_exclusive_device 20 1 0
./run.sh $1 small firsttouch_exclusive_device 25 1 0
./run.sh $1 small firsttouch_exclusive_device 30 1 0
./run.sh $1 small firsttouch_exclusive_device 35 1 0
./run.sh $1 small firsttouch_exclusive_device 40 1 0
./run.sh $1 small firsttouch_exclusive_device 45 1 0
./run.sh $1 small firsttouch_exclusive_device 50 1 0

./run.sh $1 small offline_pebs_guided 128 small knapsack 5 1
./run.sh $1 small offline_pebs_guided 128 small knapsack 10 1
./run.sh $1 small offline_pebs_guided 128 small knapsack 15 1
./run.sh $1 small offline_pebs_guided 128 small knapsack 20 1
./run.sh $1 small offline_pebs_guided 128 small knapsack 25 1
./run.sh $1 small offline_pebs_guided 128 small knapsack 30 1
./run.sh $1 small offline_pebs_guided 128 small knapsack 35 1
./run.sh $1 small offline_pebs_guided 128 small knapsack 40 1
./run.sh $1 small offline_pebs_guided 128 small knapsack 45 1
./run.sh $1 small offline_pebs_guided 128 small knapsack 50 1

./run.sh $1 small offline_pebs_guided 128 small hotset 5 1
./run.sh $1 small offline_pebs_guided 128 small hotset 10 1
./run.sh $1 small offline_pebs_guided 128 small hotset 15 1
./run.sh $1 small offline_pebs_guided 128 small hotset 20 1
./run.sh $1 small offline_pebs_guided 128 small hotset 25 1
./run.sh $1 small offline_pebs_guided 128 small hotset 30 1
./run.sh $1 small offline_pebs_guided 128 small hotset 35 1
./run.sh $1 small offline_pebs_guided 128 small hotset 40 1
./run.sh $1 small offline_pebs_guided 128 small hotset 45 1
./run.sh $1 small offline_pebs_guided 128 small hotset 50 1

./run.sh $1 small offline_pebs_guided 128 small thermos 5 1
./run.sh $1 small offline_pebs_guided 128 small thermos 10 1
./run.sh $1 small offline_pebs_guided 128 small thermos 15 1
./run.sh $1 small offline_pebs_guided 128 small thermos 20 1
./run.sh $1 small offline_pebs_guided 128 small thermos 25 1
./run.sh $1 small offline_pebs_guided 128 small thermos 30 1
./run.sh $1 small offline_pebs_guided 128 small thermos 35 1
./run.sh $1 small offline_pebs_guided 128 small thermos 40 1
./run.sh $1 small offline_pebs_guided 128 small thermos 45 1
./run.sh $1 small offline_pebs_guided 128 small thermos 50 1

./run.sh $1 small offline_mbi_guided small knapsack 5 1
./run.sh $1 small offline_mbi_guided small knapsack 10 1
./run.sh $1 small offline_mbi_guided small knapsack 15 1
./run.sh $1 small offline_mbi_guided small knapsack 20 1
./run.sh $1 small offline_mbi_guided small knapsack 25 1
./run.sh $1 small offline_mbi_guided small knapsack 30 1
./run.sh $1 small offline_mbi_guided small knapsack 35 1
./run.sh $1 small offline_mbi_guided small knapsack 40 1
./run.sh $1 small offline_mbi_guided small knapsack 45 1
./run.sh $1 small offline_mbi_guided small knapsack 50 1

./run.sh $1 small offline_mbi_guided small hotset 5 1
./run.sh $1 small offline_mbi_guided small hotset 10 1
./run.sh $1 small offline_mbi_guided small hotset 15 1
./run.sh $1 small offline_mbi_guided small hotset 20 1
./run.sh $1 small offline_mbi_guided small hotset 25 1
./run.sh $1 small offline_mbi_guided small hotset 30 1
./run.sh $1 small offline_mbi_guided small hotset 35 1
./run.sh $1 small offline_mbi_guided small hotset 40 1
./run.sh $1 small offline_mbi_guided small hotset 45 1
./run.sh $1 small offline_mbi_guided small hotset 50 1

./run.sh $1 small offline_mbi_guided small thermos 5 1
./run.sh $1 small offline_mbi_guided small thermos 10 1
./run.sh $1 small offline_mbi_guided small thermos 15 1
./run.sh $1 small offline_mbi_guided small thermos 20 1
./run.sh $1 small offline_mbi_guided small thermos 25 1
./run.sh $1 small offline_mbi_guided small thermos 30 1
./run.sh $1 small offline_mbi_guided small thermos 35 1
./run.sh $1 small offline_mbi_guided small thermos 40 1
./run.sh $1 small offline_mbi_guided small thermos 45 1
./run.sh $1 small offline_mbi_guided small thermos 50 1
