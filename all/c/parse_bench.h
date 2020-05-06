#include <string.h>
#include <ctype.h>

char *bench_metrics_list[] = {
  "fom",
  "avg_phase_time",
  "first_phase_time",
  "last_phase_time",
  "max_phase_time",
  "total_phase_time",
  "num_phases",
  NULL
};

typedef struct bench_metrics {
  double fom,
         avg_phase_time,
         first_phase_time,
         last_phase_time,
         max_phase_time,
         total_phase_time;
  size_t num_phases;

  /* Just for QMCPACK */
  unsigned qmcpack_blocks, qmcpack_steps, qmcpack_walkers;
  double qmcpack_exectime;
} bench_metrics;

bench_metrics *init_bench_metrics() {
  bench_metrics *info;
  info = malloc(sizeof(bench_metrics));
  info->fom = 0.0;
  info->avg_phase_time = 0;
  info->first_phase_time = 0;
  info->last_phase_time = 0;
  info->max_phase_time = 0;
  info->total_phase_time = 0;
  info->num_phases = 0;

  return info;
}

void parse_bench(FILE *file, bench_metrics *info) {
  unsigned unsigned_tmp;
  double double_tmp;
  char *line, *ptr;
  size_t len;
  ssize_t read;
  char found_qmcpack;
  
  line = NULL;
  len = 0;
  found_qmcpack = 0;
  while(read = getline(&line, &len, file) != -1) {

    /* First QMCPACK */
    if(sscanf(line, "  blocks         = %u", &unsigned_tmp) == 1) {
      info->qmcpack_blocks = unsigned_tmp;
      found_qmcpack++;
    } else if(sscanf(line, "  steps          = %u", &unsigned_tmp) == 1) {
      info->qmcpack_steps = unsigned_tmp;
      found_qmcpack++;
    } else if(sscanf(line, "  walkers/mpi    = %u", &unsigned_tmp) == 1) {
      info->qmcpack_walkers = unsigned_tmp;
      found_qmcpack++;
    } else if(sscanf(line, "  QMC Execution time = %lf secs", &double_tmp) == 1) {
      info->qmcpack_exectime = double_tmp;
      found_qmcpack++;
    } else if(sscanf(line, "Figure of Merit (FOM_2): %lf", &double_tmp) == 1) {
      /* AMG */
      info->fom = double_tmp;
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
    } else if(sscanf(line, "cycle timer =     %lf (s)", &double_tmp) == 1) {
      info->total_phase_time += double_tmp;
      info->num_phases++;
      if(double_tmp > info->max_phase_time) {
        info->max_phase_time = double_tmp;
      }
      if(info->num_phases == 1) {
        info->first_phase_time = double_tmp;
      }
      info->last_phase_time = double_tmp;
    }
  }
  
  if(info->total_phase_time) {
    info->avg_phase_time = info->total_phase_time / info->num_phases;
  }
  
  if(found_qmcpack == 4) {
    /* If all qmcpack values have been found, calculate the fom */
    info->fom = ((double) (info->qmcpack_blocks * info->qmcpack_steps * info->qmcpack_walkers)) / info->qmcpack_exectime;
  }
}

char *is_bench_metric(char *metric) {
  char *ptr, *filename;
  int i;

  i = 0;
  while((ptr = bench_metrics_list[i]) != NULL) {
    if(strcmp(metric, ptr) == 0) {
      filename = malloc(sizeof(char) * (strlen("stdout.txt") + 1));
      strcpy(filename, "stdout.txt");
      return filename;
    }
    i++;
  }

  return NULL;
}

void set_bench_metric(char *metric_str, bench_metrics *info, metric *m) {
  if(strcmp(metric_str, "fom") == 0) {
    m->val.f = info->fom;
    m->type = 0;
  } else if(strcmp(metric_str, "avg_phase_time") == 0) {
    m->val.f = info->avg_phase_time;
    m->type = 0;
  } else if(strcmp(metric_str, "total_phase_time") == 0) {
    m->val.f = info->total_phase_time;
    m->type = 0;
  } else if(strcmp(metric_str, "max_phase_time") == 0) {
    m->val.f = info->max_phase_time;
    m->type = 0;
  } else if(strcmp(metric_str, "first_phase_time") == 0) {
    m->val.f = info->first_phase_time;
    m->type = 0;
  } else if(strcmp(metric_str, "last_phase_time") == 0) {
    m->val.f = info->last_phase_time;
    m->type = 0;
  }
}
