#!/bin/bash

sizes=(small medium large);

for size in "${sizes[@]}"; do
  ./run.sh $1 $size firsttouch_exclusive_device 5
  ./run.sh $1 $size firsttouch_exclusive_device 10
  ./run.sh $1 $size firsttouch_exclusive_device 15
  ./run.sh $1 $size firsttouch_exclusive_device 20
  ./run.sh $1 $size firsttouch_exclusive_device 25
  ./run.sh $1 $size firsttouch_exclusive_device 30
  ./run.sh $1 $size firsttouch_exclusive_device 35
  ./run.sh $1 $size firsttouch_exclusive_device 40
  ./run.sh $1 $size firsttouch_exclusive_device 45
  ./run.sh $1 $size firsttouch_exclusive_device 50

  ./run.sh $1 $size offline_pebs_guided 128 $size knapsack 5
  ./run.sh $1 $size offline_pebs_guided 128 $size knapsack 10
  ./run.sh $1 $size offline_pebs_guided 128 $size knapsack 15
  ./run.sh $1 $size offline_pebs_guided 128 $size knapsack 20
  ./run.sh $1 $size offline_pebs_guided 128 $size knapsack 25
  ./run.sh $1 $size offline_pebs_guided 128 $size knapsack 30
  ./run.sh $1 $size offline_pebs_guided 128 $size knapsack 35
  ./run.sh $1 $size offline_pebs_guided 128 $size knapsack 40
  ./run.sh $1 $size offline_pebs_guided 128 $size knapsack 45
  ./run.sh $1 $size offline_pebs_guided 128 $size knapsack 50

  ./run.sh $1 $size offline_pebs_guided 128 $size thermos 5
  ./run.sh $1 $size offline_pebs_guided 128 $size thermos 10
  ./run.sh $1 $size offline_pebs_guided 128 $size thermos 15
  ./run.sh $1 $size offline_pebs_guided 128 $size thermos 20
  ./run.sh $1 $size offline_pebs_guided 128 $size thermos 25
  ./run.sh $1 $size offline_pebs_guided 128 $size thermos 30
  ./run.sh $1 $size offline_pebs_guided 128 $size thermos 35
  ./run.sh $1 $size offline_pebs_guided 128 $size thermos 40
  ./run.sh $1 $size offline_pebs_guided 128 $size thermos 45
  ./run.sh $1 $size offline_pebs_guided 128 $size thermos 50
done
