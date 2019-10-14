#!/bin/bash
# Sets environment variables based on the arguments that you specify, using getopt.

# Arguments
GETOPT_OUTPUT=`getopt -o obcsagmi --long memsys,bench:,config:,size:,args:,graph,metric:,iters: -n 'build.sh' -- "$@"`
if [ $? != 0 ] ; then echo "'getopt' failed. Aborting." >&2 ; exit 1 ; fi
eval set -- "$GETOPT_OUTPUT"

# Handle arguments
MEMSYS=false
BENCHES=()
CONFIGS=()
SIZE=""
CONFIG_ARGS_STRS=()
ITERS="3"
METRIC=""
GRAPH=false
while true; do
  case "$1" in
    -o | --memsys ) MEMSYS=true; shift;;
    -b | --bench ) BENCHES+=("$2"); shift 2;;
    -c | --config ) CONFIGS+=("$2"); shift 2;;
    -a | --args ) CONFIG_ARGS_STRS+=("$2"); shift 2;;
    -s | --size ) SIZE="$2"; shift 2;;
    -g | --graph ) GRAPH=true; shift;;
    -m | --metric ) METRIC="$2"; shift 2;;
    -i | --iters ) ITERS="$2"; shift 2;;
    -- ) shift; break;;
    * ) break;;
  esac
done

MAX_ITER=$(echo "$ITERS - 1" | bc)

SICM="sicm-high"
if $MEMSYS; then
  SICM="sicm-high-memsys"
fi

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

# Config name, colon, underscore-delimited list of arguments
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
      "small_aep_load" ) BENCH_COMMAND="$SMALL_AEP_LOAD";;
      * ) echo "Unknown size: '$SIZE'. Aborting."; exit 1;;
    esac
    BENCH_COMMANDS+=("${BENCH_COMMAND}")
  fi
done
