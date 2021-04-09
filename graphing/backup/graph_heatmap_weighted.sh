#!/usr/bin/env bash

### INPUT FORMAT #######################################################
#
# Header: Allocation site IDs.
# Each column: One allocation site.
# Each line:   Space separated floats indicating the hotness of
#              each allocation site on one interval.
#
# Example:
#              3    5   9
#              0.1  0.3 7.5
#              0.0  4.1 1.24
#              12.4 4.4 9.3
#              3.3  0.0 5.5
#
#              Site 5 had heat value 4.4 on interval 3.
#              Site 9 had heat value 5.5 on interval 4.
#
# First argument: name of the heatmap file.
# Second argument: name of the weight ratio file.
# Third argument: title of the graph.
# Fourth argument: If "relative", the redness of a particular cell is based on
#                  only that interval's max and min hotness. Otherwise, use
#                  hotness from the whole run.
#
########################################################################


heatmap_f="$1"
weight_ratios_f="$2"
title="$3"
relative="$4"

if [[ "$heatmap_f" == "" ]]; then
    echo "usage: graph_heatmap.sh FILE"
    exit 1
fi

if ! [ -f "$heatmap_f" ]; then
    echo "No such file '${f}'"
    exit 1
fi

N_INTERVALS=$(wc "$heatmap_f" | awk ' { print $1 - 1; } ')
N_SITES=$(head -n 1 "$heatmap_f" | awk '{ print NF; }')
SITES=$(head -n 1 "$heatmap_f")
>&2 echo "N_SITES: ${N_SITES}"
>&2 echo "N_INTERVALS: ${N_INTERVALS}"
>&2 echo "SITES: ${SITES}"

awk_print_max_of_row='{
    for (i=1; i<=NF; i++) {
        if ($i > max) {
            max=$i;
        }
    }
    print max;
    max=0;
}'

#          get max value on each row   | sort    | get the max
MAX_HEAT=$(tail -n +2 "$heatmap_f" | awk "$awk_print_max_of_row" | sort -n | tail -n 1)

# jgraph
echo "newgraph"
echo "xaxis label : Time (intervals)"
echo "    min 0 max ${N_INTERVALS}"
echo "    size 5"
echo "    no_draw_hash_marks"
echo "    no_auto_hash_labels"
echo "yaxis label : Allocation Site"
#echo "    min 0.5 max $(echo ${N_SITES} | awk "{ print \$1+0.5 }" )"
echo "    min 0 max 100"
echo "    size 5"
echo "    no_auto_hash_marks"
echo "    no_auto_hash_labels"

i=1
total_height=0
for site in $(head -n 1 "$heatmap_f"); do
  cur_weight_ratio=$(tail -n +2 "$weight_ratios_f" | awk '{ print $'$i'; }')
  cur_half_height=$(echo "$cur_weight_ratio / 2" | bc -l)
  cur_midpoint=$(echo "$total_height + $cur_half_height" | bc -l)
  total_height=$(echo "$total_height + $cur_weight_ratio" | bc -l)
  >&2 echo "    hash_at ${cur_midpoint}"
  echo "    hash_at ${cur_midpoint}"
  i=$(echo "$i + 1" | bc)
done
echo "    hash_labels fontsize 5"

echo "title : ${title}"

i=1
total_height=0
for site in $(head -n 1 "$heatmap_f"); do
  cur_weight_ratio=$(tail -n +2 "$weight_ratios_f" | awk '{ print $'$i'; }')
  cur_half_height=$(echo "$cur_weight_ratio / 2" | bc -l)
  cur_midpoint=$(echo "$total_height + $cur_half_height" | bc -l)
  total_height=$(echo "$total_height + $cur_weight_ratio" | bc -l)
  >&2 echo "$site, $cur_half_height"
  if [ "$relative" = "relative" ]; then
    awk_prg="{
      max=0;
      min=100000000000000;
      for (j=1; j<=NF; j++) {
          if (\$j > max) {
              max=\$j;
          }
          if (\$j < min) {
              min=\$j;
          }
      }
      ratio = 1.0
      if (max > 0.0) {
          ratio -= (\$$i-min)/(max-min);
      }
      printf(\"newline linethickness 0.0 poly color 1.0 %f %f pcfill 1.0 %f %f pts %d %f %d %f %d %f %d %f\n\", ratio, ratio, ratio, ratio, NR-1, $cur_midpoint-$cur_half_height, NR, $cur_midpoint-$cur_half_height, NR, $cur_midpoint+$cur_half_height, NR-1, $cur_midpoint+$cur_half_height);
    }"
#      printf(\"newline linethickness 0.0 poly color 1.0 %f %f pcfill 1.0 %f %f pts %d %f %d %f %d %f %d %f\n\", ratio, ratio, ratio, ratio, NR-1, $i-0.5, NR, $i-0.5, NR, $i+0.5, NR-1, $i+0.5);
  else
    awk_prg="{
      ratio=1.0 - ((\$$i)/$MAX_HEAT);
      printf(\"newline linethickness 0.0 poly color 1.0 %f %f pcfill 1.0 %f %f pts %d %f %d %f %d %f %d %f\n\", ratio, ratio, ratio, ratio, NR-1, $i-0.5, NR, $i-0.5, NR, $i+0.5, NR-1, $i+0.5);
    }"
  fi

  tail -n +2 "$heatmap_f" | awk "${awk_prg}"
  echo ""
  i=$(echo "$i + 1" | bc)
done
