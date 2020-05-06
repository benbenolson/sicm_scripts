#!/bin/bash
export REPORT=true
source ./all/vars.sh
source $SCRIPTS_DIR/all/args.sh

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

for BENCH in ${BENCHES[@]}; do
  STAT_ARGS="${STAT_ARGS} --bench=${BENCH}"
done

for FULL_CONFIG in ${FULL_CONFIGS[@]}; do
  STAT_ARGS="${STAT_ARGS} --config=${FULL_CONFIG}"
done

for GROUPNAME in "${GROUPNAMES[@]}"; do
  STAT_ARGS="${STAT_ARGS} --groupname=${GROUPNAME}"
done

STAT_ARGS="${STAT_ARGS} --groupsize=${GROUPSIZE}"
STAT_ARGS="${STAT_ARGS} ${RESULTS_DIR}/${BENCH}/${SIZE}"

echo ${SCRIPTS_DIR}/all/stat ${STAT_ARGS}
${SCRIPTS_DIR}/all/stat ${STAT_ARGS}
