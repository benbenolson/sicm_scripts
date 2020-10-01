#!/bin/bash

#./run.sh --size=ref --bench=bwaves --bench=cactubssn --bench=lbm --bench=wrf --bench=cam4 --bench=pop2 --bench=imagick --bench=nab --bench=fotonik3d \
#  --config=on_mr_ski_all_rss_bsl_debug --args=128,100,100,100,hotset,50
  
            
./run.sh --size=medium_aep --bench=qmcpack \
  --config=on_mr_ski_all_rss_bsl_debug --args=128,100,100,100,hotset,10 \
  --config=on_mr_ski_all_rss_bsl_debug --args=128,100,100,100,hotset,20 \
  --config=on_mr_ski_all_rss_bsl_debug --args=128,100,100,100,hotset,30 \
  --config=on_mr_ski_all_rss_bsl_debug --args=128,100,100,100,hotset,40 \
  --config=on_mr_ski_all_rss_bsl_debug --args=128,100,100,100,hotset,50
