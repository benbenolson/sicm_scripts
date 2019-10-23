#!/bin/bash

declare -a cpu2017_benchmarks=(
  "603.bwaves_s"
  "607.cactuBSSN_s"
  "619.lbm_s"
  "621.wrf_s"
  "627.cam4_s"
  "628.pop2_s"
  "638.imagick_s"
  "644.nab_s"
  "649.fotonik3d_s"
  "654.roms_s"
  "657.xz_s"
)

# Arguments
GETOPT_OUTPUT=`getopt -o mb:c:s:a: --long memsys,bench:,config:,size:,args: -n 'args.sh' -- "$@"`
if [ $? != 0 ] ; then echo "'getopt' failed. Aborting." >&2 ; exit 1 ; fi
eval set -- "$GETOPT_OUTPUT"

# Handle arguments
MEMSYS=false
BENCH=""
CONFIGSTR=""
SIZE=""
CONFIGARGSSTR=""
while true; do
  case "$1" in
    -m | --memsys ) MEMSYS=true; shift;;
    -b | --bench ) BENCH="$2"; shift 2;;
    -c | --config ) CONFIGSTR="$2"; shift 2;;
    -a | --args ) CONFIGARGSSTR="$2"; shift 2;;
    -s | --size ) SIZE="$2"; shift 2;;
    -- ) shift; break;;
    * ) break;;
  esac
done

CPU2017_BENCH=false
for x in "${cpu2017_benchmarks[@]}"; do
  if [ "$x" == "$BENCH" ]; then
    CPU2017_BENCH=true
    break;
  fi
done

SICM="sicm-high"
if $MEMSYS; then
  SICM="sicm-high-memsys"
fi

# The ${CONFIG} variable contains a configuration name,
# The ${CONFIG_ARGS} variable contains an array of config arguments.
CONFIG_ARGS=(${CONFIGARGSSTR//,/ })
CONFIG=${CONFIGSTR}

CONFIG_ARGS_SPACES=""
CONFIG_ARGS_UNDERSCORES=""
for arg in "${CONFIG_ARGS[@]}"; do
  CONFIG_ARGS_SPACES="$CONFIG_ARGS_SPACES $arg"
  CONFIG_ARGS_UNDERSCORES="${CONFIG_ARGS_UNDERSCORES}_$arg"
done
CONFIG_ARGS_SPACES="$(echo -e "${CONFIG_ARGS_SPACES}" | sed -e 's/^[[:space:]]*//')"
CONFIG_ARGS_UNDERSCORES="$(echo -e "${CONFIG_ARGS_UNDERSCORES}" | sed -e 's/^[[_]]*//')"

# Config name, colon, underscore-delimited list of arguments
FULLCONFIG=${CONFIG}:${CONFIG_ARGS_UNDERSCORES}

BENCH_COMMAND=""
if [ $CPU2017_BENCH ]; then
  BENCH_COMMAND="./run.sh";
elif [ $BENCH ] && [ $SIZE ]; then
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
