#!/bin/bash

################################################################################
#                                  mbi                                         #
################################################################################
# First argument is results directory
# Second argument is the command to run
function mbi {
  BASEDIR="$1"
  COMMAND="$2"
  PEBS_CFG="pebs_128"
  PEBS_STDOUT="${BASEDIR}/../${PEBS_CFG}/i0/stdout.txt"

  # User output
  echo "Running experiment:"
  echo "  Config: 'mbi'"
  echo "  Sites: $(${SCRIPTS_DIR}/stat.sh "${PEBS_STDOUT}" num_sites)"

  export SH_DEFAULT_NODE="1"
  export SH_PROFILE_ONE_NODE="0"
  #export SH_PROFILE_ONE_IMC="knl_unc_edc_eclk0,knl_unc_edc_eclk1,knl_unc_edc_eclk2,knl_unc_edc_eclk3,knl_unc_edc_eclk4,knl_unc_edc_eclk5,knl_unc_edc_eclk6,knl_unc_edc_eclk7"
  export SH_PROFILE_ONE_IMC="knl_unc_imc0,knl_unc_imc1,knl_unc_imc2,knl_unc_imc3,knl_unc_imc4,knl_unc_imc5"
  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  #export SH_PROFILE_ONE_EVENT="UNC_E_RPQ_INSERTS"
  export SH_PROFILE_ONE_EVENT="UNC_M_CAS_COUNT:RD"
  export JE_MALLOC_CONF="oversize_threshold:0"
  export OMP_NUM_THREADS="272"

  eval "${PRERUN}"

  # NEEDS GENERALIZATION
  for site in $(${SCRIPTS_DIR}/stat.sh "${PEBS_STDOUT}" sites); do
    echo "  Site: ${site}"
    export SH_PROFILE_ONE="${site}"
    drop_caches
    eval "env time -v " "numactl --preferred=1 sudo -E LD_LIBRARY_PATH="${LD_LIBRARY_PATH} " ${COMMAND}" &>> ${BASEDIR}/${site}.txt
  done
}
