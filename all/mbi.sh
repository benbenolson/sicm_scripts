#!/bin/bash

################################################################################
#                                  mbi                                         #
################################################################################
# First argument is results directory
# Second argument is the command to run
# Third argument is the PEBS frequency that has already been run. We use a
# previous PEBS run to get the number of dynamic (reached at runtime)
# allocation sites.
function mbi {
  RESULTS_DIR="$1"
  COMMAND="$2"
  FREQ="$3"

  # Determine how many sites there are

  export SH_DEFAULT_NODE="0"
  export SH_PROFILE_ONE_NODE="1"
  export SH_PROFILE_ONE_IMC="knl_unc_edc_eclk0,knl_unc_edc_eclk1,knl_unc_edc_eclk2,knl_unc_edc_eclk3,knl_unc_edc_eclk4,knl_unc_edc_eclk5,knl_unc_edc_eclk6,knl_unc_edc_eclk7"
  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_PROFILE_ONE_EVENT="UNC_E_RPQ_INSERTS"
  export OMP_NUM_THREADS="64"

  # NEEDS GENERALIZATION
  for site in $(seq 1 87); do
    # Set the site that we want to isolate
    echo "Profiling: ${site}"
    export SH_PROFILE_ONE="${site}"
    drop_caches
    eval "sudo -E" "${COMMAND}" &>> ${RESULTS_DIR}/${site}.txt
  done
}
