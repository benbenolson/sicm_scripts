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

if [[ ! -z "${METRIC}" ]]; then
  STAT_ARGS="${STAT_ARGS} --metric=${METRIC}"
fi
if [[ ! -z "${SIZE}" ]]; then
  STAT_ARGS="${STAT_ARGS} --size=${SIZE}"
fi
if [[ ! -z "${NODE}" ]]; then
  STAT_ARGS="${STAT_ARGS} --node=${NODE}"
fi
for BENCH in ${BENCHES[@]}; do
  STAT_ARGS="${STAT_ARGS} --bench=\"${BENCH}\""
done
for FULL_CONFIG in ${FULL_CONFIGS[@]}; do
  STAT_ARGS="${STAT_ARGS} --config=${FULL_CONFIG}"
done

for GROUPNAME in "${GROUPNAMES[@]}"; do
  STAT_ARGS="${STAT_ARGS} --groupname=\"${GROUPNAME}\""
done

for LABEL in "${LABELS[@]}"; do
  STAT_ARGS="${STAT_ARGS} --label=\"${LABEL}\""
done

if [ "${EPS}" = true ]; then
  echo "ADDING EPS ARG"
  STAT_ARGS="${STAT_ARGS} --eps"
fi
if [[ ! -z ${GRAPH_TITLE} ]]; then
  STAT_ARGS="${STAT_ARGS} --graph_title=\"${GRAPH_TITLE}\""
fi
if [[ ! -z ${FILENAME} ]]; then
  STAT_ARGS="${STAT_ARGS} --filename=\"${FILENAME}\""
fi
if [[ ! -z ${X_LABEL} ]]; then
  STAT_ARGS="${STAT_ARGS} --x_label=\"${X_LABEL}\""
fi
if [[ ! -z "${Y_LABEL}" ]]; then
  STAT_ARGS="${STAT_ARGS} --y_label=\"${Y_LABEL}\""
fi
if [[ ! -z "${GROUPSIZE}" ]]; then
  STAT_ARGS="${STAT_ARGS} --groupsize=${GROUPSIZE}"
fi
if [[ ! -z "${SITE}" ]]; then
  STAT_ARGS="${STAT_ARGS} --site=${SITE}"
fi
STAT_ARGS="${STAT_ARGS} ${RESULTS_DIR}/${BENCH}/${SIZE}"

eval "${SCRIPTS_DIR}/all/stat ${STAT_ARGS}"
