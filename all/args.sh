#!/bin/bash

# Arguments
GETOPT_OUTPUT=`getopt -o mbcs --long memsys,bench:,config:,size: -n 'build.sh' -- "$@"`
if [ $? != 0 ] ; then echo "'getopt' failed. Aborting." >&2 ; exit 1 ; fi
eval set -- "$GETOPT_OUTPUT"

# Handle arguments
MEMSYS=false
BENCH=""
CONFIGSTR=""
SIZE=""
while true; do
  case "$1" in
    -m | --memsys ) MEMSYS=true; shift;;
    -b | --bench ) BENCH="$2"; shift 2;;
    -c | --config ) CONFIGSTR="$2"; shift 2;;
    -s | --size ) SIZE="$2"; shift 2;;
    -- ) shift; break;;
    * ) break;;
  esac
done

SICM="sicm-high"
if $MEMSYS; then
  SICM="sicm-high-memsys"
fi

# The ${CONFIG} variable contains a configuration name,
# followed by a comma and an underscore-delimited list of arguments
# to that configuration. Split these up in order to call it properly.
CONFIG_ARRAY=(${CONFIGSTR//,/ })
CONFIG=${CONFIG_ARRAY[0]}
CONFIG_ARGS=${CONFIG_ARRAY[1]}
CONFIG_ARGS_ARRAY=(${CONFIG_ARGS//_/ })

# Construct a space-delimited list of configuration arguments.
# Last line in this block removes leading whitespace.
CONFIG_ARGS_SPACES=""
for arg in "${CONFIG_ARGS_ARRAY[@]}"; do
  CONFIG_ARGS_SPACES="$CONFIG_ARGS_SPACES $arg"
done
CONFIG_ARGS_SPACES="$(echo -e "${CONFIG_ARGS_SPACES}" | sed -e 's/^[[:space:]]*//')"

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
    * ) echo "Unknown size: '$SIZE'. Aborting."; exit 1;;
  esac
fi
