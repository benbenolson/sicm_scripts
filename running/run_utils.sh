#!/bin/bash

# Benchmark names are the names of the directory in the `benchmarks/` directory.
# Configs include the config name, followed by a period, then an underscore-separated list of arguments.

# Arguments
GETOPT_OUTPUT=`getopt -o bcsip --long bench:,config:,size:,iters:,profilecfg: -n 'run_utils.sh' -- "$@"`
if [ $? != 0 ] ; then echo "'getopt' failed. Aborting." >&2 ; exit 1 ; fi
eval set -- "$GETOPT_OUTPUT"

function get_config_name() {
  local retval=$(echo ${1} | awk '{split($0, a, "."); print a[1] }')
  echo "$retval"
}

function get_config_args() {
  local retval=$(echo ${1} | awk '{split($0, a, "."); print a[2] }' | sed -e 's/_/ /g')
  echo "$retval"
}

# Handle arguments
BENCHES=()
CONFIGS=()
SIZE=""
ITERS="1"
PROFILE_CFG=""
while true; do
  case "$1" in
    -b | --bench ) BENCHES+=("$2"); shift 2;;
    -c | --config ) CONFIGS+=("$2"); shift 2;;
    -s | --size ) SIZE="$2"; shift 2;;
    -i | --iters ) ITERS="$2"; shift 2;;
    -p | --profilecfg ) PROFILE_CFG="$2"; shift 2;;
    -- ) shift; break;;
    * ) break;;
  esac
done

# Check the arguments
if [[ ${#BENCHES[@]} = 0 ]]; then
  echo "You didn't specify a benchmark name. Aborting."
  exit 1
fi
if [[ ${#CONFIGS[@]} = 0 ]]; then
  echo "You didn't specify a configuration name. Aborting."
  exit 1
fi
if [[ ! $SIZE ]]; then
  echo "You didn't specify a size. Aborting."
  exit 1
fi

export "PROFILE_CFG=${PROFILE_CFG}"
export MAX_ITER=$(echo "$ITERS - 1" | bc)

BENCH_COMMANDS=()
for BENCH in ${BENCHES[@]}; do
  BENCH_COMMAND=""
  if [ $BENCH ] && [ $SIZE ]; then
    source ${SCRIPTS_DIR}/benchmarks/${BENCH}/${BENCH}_run.sh
    
    # The benchmark commands are just the upper-case version of the size name
   BENCH_COMMAND=$(eval echo \$$(echo ${SIZE} | awk '{ print toupper($0); }'))
   if [[ -z "${BENCH_COMMAND}" ]]; then
     echo "Unknown size: ${SIZE}. Aborting." && exit 1
   fi
    
    BENCH_COMMANDS+=("${BENCH_COMMAND}")
  fi
done
