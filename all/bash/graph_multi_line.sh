#!/usr/bin/env bash
# Graphs each file as a separate line on the same graph.
# The first file should contain:
#   1. The X-axis label on the first line.
#   2. The Y-axis label on the second line.
#   3. The maximum X-axis value on the third line.
#   4. The maximum Y-axis value on the fourth line.
# Each subsequent file should contain:
#   1. The name of the curve on the first line.
#   2. All subsequent lines should contain an X and a Y value, separated by spaces.

echo "newgraph"

# First, we'll read in the first file
X_AXIS_TITLE=$(sed '1q;d' ${1})
Y_AXIS_TITLE=$(sed '2q;d' ${1})
MAX_X_AXIS=$(sed '3q;d' ${1})
MAX_Y_AXIS=$(sed '4q;d' ${1})

# X axis
echo "xaxis label fontsize 16 : ${X_AXIS_TITLE}"
echo "  min 0 max ${MAX_X_AXIS}"
echo "  size 10"
#echo "  no_auto_hash_marks"
#echo "  no_auto_hash_labels"
echo "  hash_scale -1.0"
echo "  hash_labels fontsize 12"
  
echo "yaxis label fontsize 16 : ${Y_AXIS_TITLE}"
echo "  min 0 max ${MAX_Y_AXIS}"
echo "  size 5"
#echo "  no_auto_hash_marks"
#echo "  no_auto_hash_labels"
echo "  hash_labels fontsize 8"

#echo "newline"
#echo "pts"
#index=0
#for bandwidth in $(cat ${bandwidth_table_f}); do 
#  x=${X_POSITIONS[index]}
#  echo "  ${x} ${bandwidth}"
#  index=$((index+1))
#done
