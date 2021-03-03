#!/usr/bin/env bash

### INPUT FORMAT #######################################################
#
# First argument: name of the hotset diff file.
# Second argument: name of the weight ratio file.
# Third argument: title of the graph.
#
########################################################################


hotset_diff_f="$1"
weight_ratios_f="$2"
title="$3"

if [[ "$hotset_diff_f" == "" ]]; then
    echo "usage: graph_hotset_diff.sh FILE"
    exit 1
fi

if ! [ -f "$hotset_diff_f" ]; then
    echo "No such file '${f}'"
    exit 1
fi

# We'll use this file to keep track of what we've put in the legend already
> /tmp/legend

N_INTERVALS=$(wc "$hotset_diff_f" | awk ' { print $1 - 1; } ')
N_SITES=$(head -n 1 "$hotset_diff_f" | awk '{ print NF; }')
SITES=$(head -n 1 "$hotset_diff_f")
>&2 echo "N_SITES: ${N_SITES}"
>&2 echo "N_INTERVALS: ${N_INTERVALS}"
>&2 echo "SITES: ${SITES}"

# jgraph
echo "newgraph"
echo "xaxis label : Time (intervals)"
echo "    min 0 max ${N_INTERVALS}"
echo "    size 5"
echo "    no_draw_hash_marks"
echo "    no_auto_hash_labels"
echo "yaxis label : Allocation Site"
echo "    min 0 max ${N_SITES}"
echo "    size 5"
echo "    no_auto_hash_marks"
echo "    no_auto_hash_labels"
echo "    hash_scale -0.5"
echo "    hash_labels fontsize 5"

cur_midpoint="0.5"
total_height=0
for site in $(head -n 1 "$hotset_diff_f"); do
  echo "    hash_at ${cur_midpoint}"
  echo "    hash_label at ${cur_midpoint} : ${site}"
  cur_midpoint=$(echo "$cur_midpoint + 1" | bc)
done

echo "title : ${title}"
echo "legend defaults hjc vjb columns 2 linelength 4.0 linethickness 4.0"

cur_midpoint="0.5"
cur_half_height=$(echo "0.5")
total_height=0
i=1
for site in $(head -n 1 "$hotset_diff_f"); do

  # This awk program runs once per line.
  awk_prg="{
    state = \$$i + 0; # Forces into numeric context
    red = 0.0;
    green = 0.0;
    blue = 0.0;
    label = \"foo\";

    # Lighter color is bound to AEP
    if(state == 0) {
      # Agree cold
      red = 0.0; green = 0.0; blue = 1.0;
      label = \"AEP, online cold, offline cold\";
    } else if(state == 1) {
      # Only offline
      red = 0.5; green = 0.25; blue = 1.0;
      label = \"AEP, online cold, offline hot\";
    } else if(state == 2) {
      # Only online
      red = 0.5; green = 0.5; blue = 1.0;
      label = \"AEP, online hot, offline cold\";
    } else if(state == 3) {
      # Agree hot
      red = 0.25; green = 0.25; blue = 1.0;
      label = \"AEP, online hot, offline hot\";
    # Darker color is bound to DRAM
    } else if(state == 4) {
      # Agree cold
      red = 1.0; green = 0.25; blue = 0.25;
      label = \"DRAM, online cold, offline cold\";
    } else if(state == 5) {
      # Only offline
      red = 1.0; green = 0.5; blue = 0.5;
      label = \"DRAM, online cold, offline hot\";
    } else if(state == 6) {
      # Only online
      red = 1.0; green = 0.25; blue = 0.5;
      label = \"DRAM, online hot, offline cold\";
    } else if(state == 7) {
      # Agree hot
      red = 1.0; green = 0.0; blue = 0.0;
      label = \"DRAM, online hot, offline hot\";
    }

    # Search through the /tmp/legend file and find if this label has already been written
    found = 0;
    while(getline line<\"/tmp/legend\") {
      if(label == line) {
        found = 1;
      }
    }
    close(\"/tmp/legend\");

    if(found == 0) {
      printf \"%s\n\", label >> \"/tmp/legend\";
      close(\"/tmp/legend\");
      printf(\"newline linethickness 0.0 poly color %f %f %f pcfill %f %f %f label : %s\n  pts %d %f %d %f %d %f %d %f\n\", red, green, blue, red, green, blue, label, NR-1, $cur_midpoint-$cur_half_height, NR, $cur_midpoint-$cur_half_height, NR, $cur_midpoint+$cur_half_height, NR-1, $cur_midpoint+$cur_half_height);
    } else {
      printf(\"newline linethickness 0.0 poly color %f %f %f pcfill %f %f %f\n  pts %d %f %d %f %d %f %d %f\n\", red, green, blue, red, green, blue, NR-1, $cur_midpoint-$cur_half_height, NR, $cur_midpoint-$cur_half_height, NR, $cur_midpoint+$cur_half_height, NR-1, $cur_midpoint+$cur_half_height);
    }
  }"

  tail -n +2 "$hotset_diff_f" | awk "${awk_prg}"
  echo ""
  cur_midpoint=$(echo "${cur_midpoint} + 1" | bc)
  i=$(echo "${i} + 1" | bc)
done

echo "copygraph"
echo "xaxis nodraw"
echo "yaxis label : Site Weight Percentage"
echo "    hash_scale +0.5"
cur_weight_total="0"
cur_midpoint="0.5"
total_height=0
i=1
for site in $(head -n 1 "$hotset_diff_f"); do
  cur_weight_ratio=$(tail -n +2 "$weight_ratios_f" | awk '{ print $'$i'; }')
  cur_weight_total=$(echo "${cur_weight_ratio} + ${cur_weight_total}" | bc)
  echo "    hash_at ${cur_midpoint}"
  printf "    hash_label at ${cur_midpoint} : %.2f\n" "${cur_weight_total}"
  cur_midpoint=$(echo "$cur_midpoint + 1" | bc)
  i=$(echo "${i} + 1" | bc)
done
