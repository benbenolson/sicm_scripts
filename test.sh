#!/bin/bash

./run.sh $1 small cache_mode_pebs 128
./run.sh $1 small cache_mode_shared_site

./run.sh $1 medium cache_mode_pebs 128
./run.sh $1 medium cache_mode_shared_site

./run.sh $1 large cache_mode_pebs 128
./run.sh $1 large cache_mode_shared_site
