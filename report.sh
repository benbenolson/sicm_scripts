#!/bin/bash
# By default, averages across iterations.
source ./all/vars.sh
source $SCRIPTS_DIR/all/args.sh

function get_avg_val {
  local FULL_CONFIG="$1"
  local BENCH="$2"
  local STAT_ARGS="$3"
  DIR="${RESULTS_DIR}/${BENCH}/${SIZE}/${FULL_CONFIG}"

  # Iterate over the iterations
  local CTR=0
  local VALS=()
  while true; do
    if [[ -d "${DIR}/i${CTR}" ]]; then
      # If this iteration exists, grab the stat from its output
      VAL=$(${SCRIPTS_DIR}/all/stat ${STAT_ARGS} "${DIR}/i${CTR}/")
      VALS+=($VAL)
    else
      break
    fi
    CTR=$(echo "$CTR + 1" | bc)
  done

  local SUM=0
  for VAL in ${VALS[@]}; do
    SUM=$(echo "$SUM + $VAL" | bc -l)
  done
  SUM=$(echo "$SUM / $CTR" | bc -l)
  echo ${SUM}
}

if [[ ${METRIC} = "" ]]; then
  echo "You didn't specify a metric. Aborting."
  exit 1
fi

if [[ ${SIZE} = "" ]]; then
  echo "You didn't specify a size. Aborting."
  exit 1
fi

if [[ ${#BENCHES[@]} = 0 ]]; then
  echo "You didn't specify any benchmarks. Aborting."
  exit 1
fi

STAT_ARGS="--metric=${METRIC}"
if [[ ! -z "${NODE}" ]]; then
  STAT_ARGS="${STAT_ARGS} --node=${NODE}"
fi

# Get first column size
MAX_CONFIG_LENGTH=0
for CONFIG in ${FULL_CONFIGS[@]}; do
  LENGTH=$(expr length $CONFIG)
  if [[ $LENGTH -gt $MAX_CONFIG_LENGTH ]]; then
    MAX_CONFIG_LENGTH=$LENGTH
  fi
done
MAX_CONFIG_LENGTH=$(echo "$MAX_CONFIG_LENGTH + 2" | bc)

# Get column size
MAX_BENCH_LENGTH=0
for BENCH in ${BENCHES[@]}; do
  LENGTH=$(expr length $BENCH)
  if [[ $LENGTH -gt $MAX_BENCH_LENGTH ]]; then
    MAX_BENCH_LENGTH=$LENGTH
  fi
done
MAX_BENCH_LENGTH=$(echo "$MAX_BENCH_LENGTH + 2" | bc)
MAX_BENCH_LENGTH=20

# Get the value for the baseconfig first
BASECONFIG_VALS=()
if [ ! -z ${FULL_BASECONFIG} ]; then
  for BENCH in ${BENCHES[@]}; do
    VAL=$(get_avg_val ${FULL_BASECONFIG} "${BENCH}" "${STAT_ARGS}")
    BASECONFIG_VALS+=(${VAL})
  done
fi

printf "%-${MAX_CONFIG_LENGTH}s" " "
for BENCH in ${BENCHES[@]}; do
  printf "%-${MAX_BENCH_LENGTH}s" $BENCH
done
printf "\n"

for FULL_CONFIG in ${FULL_CONFIGS[@]}; do
  printf "%-${MAX_CONFIG_LENGTH}s" $FULL_CONFIG
  INDEX=0
  for BENCH in ${BENCHES[@]}; do
    VAL=$(get_avg_val "${FULL_CONFIG}" "${BENCH}" "${STAT_ARGS}")
    if [ ! -z ${FULL_BASECONFIG} ]; then
      VAL=$(echo "${VAL} / ${BASECONFIG_VALS[INDEX]}" | bc -l)
    fi
    printf "%-${MAX_BENCH_LENGTH}.5f" ${VAL}
    INDEX=$(echo "$INDEX + 1" | bc)
  done
  printf "\n"
done
