#include <string.h>
#include <ctype.h>

typedef struct fom_metrics {
  double fom;

  /* Just for QMCPACK */
  unsigned qmcpack_blocks, qmcpack_steps, qmcpack_walkers;
  double qmcpack_exectime;
} fom_metrics;

fom_metrics *init_fom_metrics() {
  fom_metrics *info;
  info = malloc(sizeof(fom_metrics));

  info->fom = 0.0;

  return info;
}

char parse_fom_metrics(file *line, fom_metrics *info) {
  unsigned unsigned_tmp;
  double double_tmp;
  char retval, *ptr;

  retval = 0;

  /* First QMCPACK */
  if(sscanf(line, "  blocks         = %u", &unsigned_tmp) == 1) {
    info->qmcpack_blocks = unsigned_tmp;
    retval = 1;
  } else if(sscanf(line, "  steps          = %u", &unsigned_tmp) == 1) {
    info->qmcpack_steps = unsigned_tmp;
    retval = 1;
  } else if(sscanf(line, "  walkers/mpi    = %u", &unsigned_tmp) == 1) {
    info->qmcpack_walkers = unsigned_tmp;
    retval = 1;
  } else if(sscanf(line, "  QMC Execution time = %lf secs", &double_tmp) == 1) {
    info->qmcpack_exectime = double_tmp;
    retval = 1;
  } else if(sscanf(line, "Figure of Merit (FOM_2): %lf", &double_tmp) == 1) {
    /* AMG */
    info->fom = double_tmp;
    retval = 1;
  } else if(strncmp(line, "  Grind Time (nanoseconds)", 26) == 0) {
    /* SNAP */
    /* Seek to the numerical value on the line */
    ptr = line;
    while(!isdigit(*ptr) && (*ptr)) {
      ptr++;
    }
    if(sscanf(ptr, "%lf\n", &double_tmp) != 1) {
      fprintf(stderr, "Error getting SNAP FOM. Aborting.\n");
      exit(1);
    }
    info->fom = 1.0 / double_tmp;
    retval = 1;
  } else if(strncmp(line, "FOM        ", 11) == 0) {
    /* LULESH */
    /* Seek to the numerical value on the line */
    ptr = line;
    while(!isdigit(*ptr) && (*ptr)) {
      ptr++;
    }
    if(sscanf(ptr, "%lf\n", &double_tmp) != 1) {
      fprintf(stderr, "Error getting LULESH FOM. Aborting.\n");
      exit(1);
    }
    info->fom = double_tmp;
    retval = 1;
  }

  if(retval) {
    if(info->qmcpack_blocks && info->qmcpack_steps && info->qmcpack_walkers && info->qmcpack_exectime) {
      /* If all qmcpack values have been found, calculate the fom */
      info->fom = ((double) (info->qmcpack_blocks * info->qmcpack_steps * info->qmcpack_walkers)) / info->qmcpack_exectime;
    }
  }

  return retval;
}
