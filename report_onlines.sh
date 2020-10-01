#!/bin/bash

metric="$1"

# ./all/stat  --bench=bwaves --bench=cactubssn --bench=lbm --bench=wrf --bench=cam4 --bench=pop2 --bench=imagick --bench=nab --bench=fotonik3d \
#             --metric="$metric" --size=ref --node=1 --relative \
#             --config=ft_bsl: \
#             --config=ft_mr_bsl:10 \
#             --config=off_mr_all_rss_bsl:hotset_10 \
#             --config=on_mr_ski_all_rss_bsl_debug:128_100_100_100_hotset_10 \
#             --config=ft_mr_bsl:20 \
#             --config=off_mr_all_rss_bsl:hotset_20 \
#             --config=on_mr_ski_all_rss_bsl_debug:128_100_100_100_hotset_20 \
#             --config=ft_mr_bsl:30 \
#             --config=off_mr_all_rss_bsl:hotset_30 \
#             --config=on_mr_ski_all_rss_bsl_debug:128_100_100_100_hotset_30 \
#             --config=ft_mr_bsl:40 \
#             --config=off_mr_all_rss_bsl:hotset_40 \
#             --config=on_mr_ski_all_rss_bsl_debug:128_100_100_100_hotset_40 \
#             --config=ft_mr_bsl:50 \
#             --config=off_mr_all_rss_bsl:hotset_50 \
#             --config=on_mr_ski_all_rss_bsl_debug:128_100_100_100_hotset_50
            
./all/stat  --bench=lulesh --bench=amg --bench=snap --bench=qmcpack \
            --metric="$metric" --size=medium_aep --node=1 \
            --config=ft_bsl: \
            --config=ft_mr_bsl:10 \
            --config=off_mr_all_rss_bsl:hotset_10 \
            --config=on_mr_ski_all_rss_bsl_debug:128_100_100_100_hotset_10 \
            --config=ft_mr_bsl:20 \
            --config=off_mr_all_rss_bsl:hotset_20 \
            --config=on_mr_ski_all_rss_bsl_debug:128_100_100_100_hotset_20 \
            --config=ft_mr_bsl:30 \
            --config=off_mr_all_rss_bsl:hotset_30 \
            --config=on_mr_ski_all_rss_bsl_debug:128_100_100_100_hotset_30 \
            --config=ft_mr_bsl:40 \
            --config=off_mr_all_rss_bsl:hotset_40 \
            --config=on_mr_ski_all_rss_bsl_debug:128_100_100_100_hotset_40 \
            --config=ft_mr_bsl:50 \
            --config=off_mr_all_rss_bsl:hotset_50 \
            --config=on_mr_ski_all_rss_bsl_debug:128_100_100_100_hotset_50
