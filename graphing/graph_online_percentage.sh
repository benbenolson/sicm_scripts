#!/usr/bin/env bash

# Input tables. One column per interval for each, only one row per table.
bandwidth_table_f="$1"
reconfigure_table_f="$2"
phase_change_table_f="$3"
interval_time_table_f="$4"

# Interval stuff
NUM_INTERVALS=$(wc ${bandwidth_table_f} | awk '{ print $2; }')
LAST_INTERVAL=$(echo "${NUM_INTERVALS} - 1" | bc)

# Runtime stuff
TOTAL_INTERVAL_RUNTIME=$(awk 'BEGIN{ sum = 0; } { for(i = 1; i <= NF; i++){sum += $i;} } END{ print sum; }' ${interval_time_table_f})
X_SIZE=$(echo "${TOTAL_INTERVAL_RUNTIME} / 26.4" | bc -l)

# X-axis ticks, proportional to the time that the interval took.
# Using points 0-1,000,000, we calculate the portion of that 1,000,000 points
# that the interval took up, then divide it by 2 (to put a tick mark halfway through the interval),
# and increment START_POSITION by the amount of space that the interval took up.
X_POSITIONS=()
START_POSITION="0"
index=0
for interval_runtime in $(cat ${interval_time_table_f}); do 
  PERMILLE_INTERVAL_RUNTIME=$(echo "${interval_runtime} / ${TOTAL_INTERVAL_RUNTIME} * 1000000" | bc -l)
  INTERVAL_POSITION=$(echo "(${PERMILLE_INTERVAL_RUNTIME} / 2) + ${START_POSITION}" | bc -l)
  START_POSITION=$(echo "${START_POSITION} + ${PERMILLE_INTERVAL_RUNTIME}" | bc -l)
  X_POSITIONS+=( "${INTERVAL_POSITION}" )
  index=$((index+1))
done

echo "newgraph"

# X axis
echo "xaxis label fontsize 16 : Runtime"
echo "  min 0 max 1000000"
echo "  size ${X_SIZE}"
echo "  no_auto_hash_marks"
echo "  no_auto_hash_labels"
echo "  hash_scale -1.0"
echo "  hash_labels fontsize 12"
  
index=0
for x in "${X_POSITIONS[@]}"; do
  echo "  hash_at ${x}"
  index=$((index+1))
done

echo "yaxis label fontsize 16 : Bandwidth (Cache Lines / Second)"
echo "  min 0 max 100"
echo "  size 5"
echo "  no_auto_hash_marks"
echo "  no_auto_hash_labels"
echo "  hash_labels fontsize 8"

echo "newline"
echo "pts"
index=0
for bandwidth in $(cat ${bandwidth_table_f}); do 
  x=${X_POSITIONS[index]}
  echo "  ${x} ${bandwidth}"
  index=$((index+1))
done

echo "newcurve linetype none marktype circle color 1 0 0"
echo "pts"
index=0
for phase_change in $(cat ${phase_change_table_f}); do 
  if [ "${phase_change}" = "1" ]; then
    x=${X_POSITIONS[index]}
    echo "  ${x} 0"
  fi
  index=$((index+1))
done

echo "newcurve linetype none marktype box color 0 0 1"
echo "pts"
index=0
for reconfigure in $(cat ${reconfigure_table_f}); do 
  if [ "${reconfigure}" = "1" ]; then
    x=${X_POSITIONS[index]}
    echo "  ${x} 0"
  fi
  index=$((index+1))
done
