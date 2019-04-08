#!/bin/bash

./run.sh $1 old pebs 128

./run.sh $1 old firsttouch_all_exclusive_device 0
./run.sh $1 old firsttouch_all_exclusive_device 1

./run.sh $1 old firsttouch_exclusive_device 12.5
./run.sh $1 old firsttouch_exclusive_device 25
./run.sh $1 old firsttouch_exclusive_device 50

./run.sh $1 old offline_pebs_guided 128 old knapsack 12.5
./run.sh $1 old offline_pebs_guided 128 old knapsack 25
./run.sh $1 old offline_pebs_guided 128 old knapsack 50

./run.sh $1 old offline_pebs_guided 128 old thermos 12.5
./run.sh $1 old offline_pebs_guided 128 old thermos 25
./run.sh $1 old offline_pebs_guided 128 old thermos 50
