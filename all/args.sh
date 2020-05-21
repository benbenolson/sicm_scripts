#!/bin/bash

source ./all/vars.sh

# Arguments
GETOPT_OUTPUT=`getopt -o ebcsagumipnrtlxyfG --long site:,eps,bench:,config:,graph_title:,size:,args:,x_label:,y_label:,groupsize:,groupname:,label:,metric:,iters:,profile:,node:,baseconfig:,base_args:,filename: -n 'args.sh' -- "$@"`
if [ $? != 0 ] ; then echo "'getopt' failed. Aborting." >&2 ; exit 1 ; fi
eval set -- "$GETOPT_OUTPUT"

# Handle arguments
NODE=""
BENCHES=()
CONFIGS=()
GROUPSIZE="0"
BASECONFIG=""
BASECONFIG_ARGS_STR=""
SIZE=""
CONFIG_ARGS_STRS=()
ITERS="3"
METRIC=""
PROFILE_DIR=""
X_LABEL=""
Y_LABEL=""
FILENAME=""
GRAPH_TITLE=""
GROUPNAMES=()
LABELS=()
SITE=""
EPS=false
while true; do
  case "$1" in
    -b | --bench ) BENCHES+=("$2"); shift 2;;
    -c | --config ) CONFIGS+=("$2"); shift 2;;
    -x | --x_label ) X_LABEL="$2"; shift 2;;
    -y | --y_label ) Y_LABEL="$2"; shift 2;;
    -g | --groupsize ) GROUPSIZE="$2"; shift 2;;
    -u | --groupname ) GROUPNAMES+=("$2"); shift 2;;
    -l | --label ) LABELS+=("$2"); shift 2;;
    -a | --args ) CONFIG_ARGS_STRS+=("$2"); shift 2;;
    -r | --baseconfig ) BASECONFIG="$2"; shift 2;;
    -t | --base_args ) BASECONFIG_ARGS_STR="$2"; shift 2;;
    -s | --size ) SIZE="$2"; shift 2;;
    -m | --metric ) METRIC="$2"; shift 2;;
    -i | --iters ) ITERS="$2"; shift 2;;
    -p | --profile ) PROFILE_DIR="$2"; shift 2;;
    -n | --node ) NODE="$2"; shift 2;;
    -f | --filename ) FILENAME="$2"; shift 2;;
    -G | --graph_title ) GRAPH_TITLE="$2"; shift 2;;
    -e | --eps ) EPS=true; shift 1;;
    -z | --site ) SITE="$2"; shift 2;;
    -- ) shift; break;;
    * ) break;;
  esac
done

MAX_ITER=$(echo "$ITERS - 1" | bc)

export SICM="sicm-high"

# Get the number of NUMA nodes on the system
export NUM_NUMA_NODES=$(lscpu | awk '/NUMA node\(s\).*/{print $3;}')

# CONFIG_ARGS is an array of strings.
# Each string contains a space-delimited list of arguments.
CONFIG_ARGS=()
CONFIG_ARGS_UNDERSCORES=()
for args in ${CONFIG_ARGS_STRS[@]}; do
  if [[ ${args} = "-" ]]; then
    CONFIG_ARGS+=(" ")
    CONFIG_ARGS_UNDERSCORES+=(" ")
    continue
  fi
  CONFIG_ARGS+=("${args//,/ }")
  CONFIG_ARGS_UNDERSCORES+=(${args//,/_})
done

# BASECONFIG ARGS
BASECONFIG_ARGS=""
BASECONFIG_ARGS_UNDERSCORES=""
if [[ ${BASECONFIG_ARGS_STR} = "-" ]]; then
  BASECONFIG_ARGS=" "
  BASECONFIG_ARGS_UNDERSCORES=" "
else
  BASECONFIG_ARGS="${BASECONFIG_ARGS_STR//,/ }"
  BASECONFIG_ARGS_UNDERSCORES=${BASECONFIG_ARGS_STR//,/_}
fi

# Each member of the FULL_CONFIGS array is a full configuration string:
# the config name, a colon, and an underscore-delimited list of arguments to that config.
CTR=0
while true; do
  if [[ ! ${CONFIG_ARGS_UNDERSCORES[${CTR}]} ]]; then
    break
  fi
  if [[ ! ${CONFIGS[${CTR}]} ]]; then
    break
  fi

  FULL_CONFIGS+=(${CONFIGS[${CTR}]}:${CONFIG_ARGS_UNDERSCORES[${CTR}]})

  CTR=$(echo "$CTR + 1" | bc)
done

FULL_BASECONFIG=""
if [[ ! -z "${BASECONFIG}" ]]; then
  FULL_BASECONFIG="${BASECONFIG}:${BASECONFIG_ARGS_UNDERSCORES}"
fi

export SICM_ENV="env LD_LIBRARY_PATH="${SICM_PREFIX}/lib:${LD_LIBRARY_PATH}" LD_PRELOAD='${SICM_PREFIX}/lib/libsicm_overrides.so'"
BENCH_COMMANDS=()
for BENCH in ${BENCHES[@]}; do
  BENCH_COMMAND=""
  if [ $BENCH ] && [ $SIZE ]; then
    source $SCRIPTS_DIR/benchmarks/${BENCH}/${BENCH}_sizes.sh
    case "$SIZE" in
      "small" ) BENCH_COMMAND="$SMALL";;
      "medium" ) BENCH_COMMAND="$MEDIUM";;
      "large" ) BENCH_COMMAND="$LARGE";;
      "small_aep" ) BENCH_COMMAND="$SMALL_AEP";;
      "medium_aep" ) BENCH_COMMAND="$MEDIUM_AEP";;
      "large_aep" ) BENCH_COMMAND="$LARGE_AEP";;
      "huge_aep" ) BENCH_COMMAND="$HUGE_AEP";;
      "small_aep_load" ) BENCH_COMMAND="$SMALL_AEP_LOAD";;
      "ref" ) BENCH_COMMAND="$REF";;
      "train" ) BENCH_COMMAND="$TRAIN";;
      "test" ) BENCH_COMMAND="$TEST";;
      * ) echo "Unknown size: '$SIZE'. Aborting."; exit 1;;
    esac
    BENCH_COMMANDS+=("${BENCH_COMMAND}")
  fi
done
