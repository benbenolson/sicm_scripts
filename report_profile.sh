#!/bin/bash

./all/stat --relative --metric="$1" --size=ref --bench=bwaves --bench=cactubssn --bench=lbm --bench=wrf --bench=cam4 --bench=pop2 --bench=imagick --bench=nab --bench=fotonik3d \
  --config=ft_bsl\: \
  --config=prof_all_bsl\:128_100_100 \
  --config=prof_all_bsl\:128_100_10 \
  --config=prof_all_bsl_rss\:128_100_100 \
  --config=prof_all_bsl_rss\:128_100_10 \
  --config=prof_all_bsl_nopoll\:128_100_100 \
  --config=prof_all_bsl_nopoll\:128_100_10 \
  --config=prof_all_bsl_rss_nopoll\:128_100_100 \
  --config=prof_all_bsl_rss_nopoll\:128_100_10 \
  --config=prof_all_bsl_rss_debug\:128_100_100 \
  --config=prof_all_bsl_rss_debug\:128_100_10

./all/stat --relative --metric="$1" --size=medium_aep --bench=lulesh --bench=amg --bench=snap --bench=qmcpack \
  --config=ft_bsl\: \
  --config=prof_all_bsl\:128_100_100 \
  --config=prof_all_bsl\:128_100_10 \
  --config=prof_all_bsl_rss\:128_100_100 \
  --config=prof_all_bsl_rss\:128_100_10 \
  --config=prof_all_bsl_nopoll\:128_100_100 \
  --config=prof_all_bsl_nopoll\:128_100_10 \
  --config=prof_all_bsl_rss_nopoll\:128_100_100 \
  --config=prof_all_bsl_rss_nopoll\:128_100_10 \
  --config=prof_all_bsl_rss_debug\:128_100_100 \
  --config=prof_all_bsl_rss_debug\:128_100_10
