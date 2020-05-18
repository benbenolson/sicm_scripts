#!/usr/bin/env bash
# Graphs each file as a separate line on the same graph.
# The first file should contain:
#   1. The title of the graph on the first line.
#   1. The X-axis label on the second line.
#   2. The Y-axis label on the third line.
#   3. The maximum X-axis value on the third line.
#   4. The maximum Y-axis value on the fourth line.
#   5. Each subsequent line is a label to use to label the curves in the legend.
# Each subsequent file should contain:
#   1. The name of the curve on the first line.
#   2. All subsequent lines should contain an X and a Y value, separated by spaces.

# First, list out some colors that we can use for the curves
colors=("0.0   0.0   0.0" \
        "1 0.803 0.698" \
        "1 0.705 0.635" \
        "0.898 0.596 0.607" \
        "0.709 0.513 0.552" \
        "0.427 0.407 0.458")

# First, we'll read in the first file
GRAPH_TITLE=$(sed '1q;d' ${1})
X_AXIS_TITLE=$(sed '2q;d' ${1})
Y_AXIS_TITLE=$(sed '3q;d' ${1})
MAX_X_AXIS=$(sed '4q;d' ${1})
MAX_Y_AXIS=$(sed '5q;d' ${1})
X_AXIS_LABELS=()
for line in $(tail -n +6 ${1}); do
  X_AXIS_LABELS+=("${line}")
done
shift

echo "pad 0.1"
echo "newgraph"
echo "legend right"
echo "title : ${GRAPH_TITLE}"

# X axis
echo "xaxis label fontsize 12 : ${X_AXIS_TITLE}"
echo "  min 0 max ${MAX_X_AXIS}"
echo "  size 3"
echo "  no_auto_hash_marks"
echo "  no_auto_hash_labels"
echo "  hash_scale -1.0"
echo "  hash_labels fontsize 12"
index=0
IFS=$(echo -en "\n\b")
for line in $(tail -n +2 ${1}); do
  IFS=$(echo -en " ")
  array=(${line})
  >&2 echo "Label: ${X_AXIS_LABELS[${index}]}, at: ${array[0]}"
  echo "  hash_at ${array[0]}"
  echo "  hash_label at ${array[0]} : ${X_AXIS_LABELS[${index}]}"
  index=$((index+1))
done

echo "yaxis label fontsize 12 : ${Y_AXIS_TITLE}"
echo "  min 0 max ${MAX_Y_AXIS}"
echo "  size 2"
#echo "  no_auto_hash_marks"
#echo "  no_auto_hash_labels"
echo "  hash_labels fontsize 12"

index=0
while test $# -gt 0; do
  >&2 echo "READING FILE: $1"
  # The first line is the title of the curve
  CURVE_TITLE=$(sed '1q;d' ${1})
  echo "newline linethickness 1.5 pts"
  # Iterate over the lines in the file, skipping the first line
  IFS=$(echo -en "\n\b")
  for line in $(tail -n +2 ${1}); do
    IFS=$(echo -en " ")
    array=(${line})
    >&2 echo "${array[0]} ${array[1]}"
    echo "${array[0]} ${array[1]}"
  done
  >&2 echo "TITLE: ${CURVE_TITLE}"
  echo "  label : ${CURVE_TITLE}"
  >&2 echo "  color ${colors[${index}]}"
  echo "  color ${colors[${index}]}"
  
  shift # Next file
  index=$((index+1))
done
