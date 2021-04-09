#include <string.h>
#include <ctype.h>
#include <float.h>

#define NUM_BENCH_METRICS 10
static char *bench_strs[NUM_BENCH_METRICS+1] = {
  "fom",
  "best_mid_phase_time",
  "avg_phase_time",
  "first_phase_time",
  "second_phase_time",
  "last_phase_time",
  "second_to_last_phase_time",
  "total_phase_time",
  "num_phases",
  "specific_phase_time",
  NULL
};
enum bench_indices {
  FOM,
  BEST_MID_PHASE_TIME,
  AVG_PHASE_TIME,
  FIRST_PHASE_TIME,
  SECOND_PHASE_TIME,
  LAST_PHASE_TIME,
  SECOND_TO_LAST_PHASE_TIME,
  TOTAL_PHASE_TIME,
  NUM_PHASES,
  SPECIFIC_PHASE_TIME
};
static double bench_vals[NUM_BENCH_METRICS];

double get_bench_val(char *metric_str, char *path, metric_opts *mopts) {
  unsigned unsigned_tmp;
  double double_tmp, last_phase, first_phase, last_best_phase_time;
  char *line, *ptr;
  size_t len, last_best_phase_num;
  ssize_t read;
  char found_qmcpack;
  char *filepath;
  FILE *file;
  
  unsigned qmcpack_blocks, qmcpack_steps, qmcpack_walkers;
  double qmcpack_exectime;
  
  clear_double_arr(bench_vals, NUM_BENCH_METRICS);
  
  filepath = construct_path(path, "stdout.txt");
  file = fopen(filepath, "r");
  if(!file) {
    fprintf(stderr, "WARNING: Failed to open '%s'. Filling with zero.\n");
    return 0.0;
  }
  free(filepath);
  
  line = NULL;
  len = 0;
  found_qmcpack = 0;
  last_phase = 0.0;
  first_phase = 0.0;
  last_best_phase_num = 0;
  while(read = getline(&line, &len, file) != -1) {

    /* First QMCPACK */
    if(sscanf(line, "  blocks         = %u", &unsigned_tmp) == 1) {
      qmcpack_blocks = unsigned_tmp;
      found_qmcpack++;
    } else if(sscanf(line, "  steps          = %u", &unsigned_tmp) == 1) {
      qmcpack_steps = unsigned_tmp;
      found_qmcpack++;
    } else if(sscanf(line, "  walkers/mpi    = %u", &unsigned_tmp) == 1) {
      qmcpack_walkers = unsigned_tmp;
      found_qmcpack++;
    } else if(sscanf(line, "  QMC Execution time = %lf secs", &double_tmp) == 1) {
      qmcpack_exectime = double_tmp;
      found_qmcpack++;
    } else if(sscanf(line, "Figure of Merit (FOM_2): %lf", &double_tmp) == 1) {
      /* AMG */
      bench_vals[FOM] = double_tmp;
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
      bench_vals[FOM] = 1.0 / double_tmp;
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
      bench_vals[FOM] = double_tmp;
    } else if(sscanf(line, "===== SICM phase time:      %lf =====", &double_tmp) == 1) {
      bench_vals[NUM_PHASES]++;
      if(bench_vals[NUM_PHASES] == mopts->index + 1) {
        bench_vals[SPECIFIC_PHASE_TIME] = double_tmp;
      }
      if(bench_vals[NUM_PHASES] == 1) {
        bench_vals[FIRST_PHASE_TIME] = double_tmp;
      } else if(bench_vals[NUM_PHASES] == 2) {
        bench_vals[SECOND_PHASE_TIME] = double_tmp;
      }
      if((bench_vals[NUM_PHASES] != 1) && (double_tmp < bench_vals[BEST_MID_PHASE_TIME])) {
        last_best_phase_num = bench_vals[NUM_PHASES];
        last_best_phase_time = bench_vals[BEST_MID_PHASE_TIME];
        bench_vals[BEST_MID_PHASE_TIME] = double_tmp;
      }
      last_phase = bench_vals[LAST_PHASE_TIME];
      bench_vals[LAST_PHASE_TIME] = double_tmp;
      bench_vals[TOTAL_PHASE_TIME] += double_tmp;
    }
  }
  
  bench_vals[SECOND_TO_LAST_PHASE_TIME] = last_phase;
  
  if(last_best_phase_num == bench_vals[NUM_PHASES]) {
    bench_vals[BEST_MID_PHASE_TIME] = last_best_phase_time;
  }
  if(bench_vals[BEST_MID_PHASE_TIME] == DBL_MAX) {
    bench_vals[BEST_MID_PHASE_TIME] = 0;
  }
  
  if(bench_vals[TOTAL_PHASE_TIME]) {
    bench_vals[AVG_PHASE_TIME] = bench_vals[TOTAL_PHASE_TIME] / bench_vals[NUM_PHASES];
  }
  
  if(found_qmcpack == 4) {
    /* If all qmcpack values have been found, calculate the fom */
    bench_vals[FOM] = ((double) (qmcpack_blocks * qmcpack_steps * qmcpack_walkers)) / qmcpack_exectime;
  }
  
  return bench_vals[metric_index(metric_str, bench_strs)];
}

void register_bench_metrics() {
  register_parser(bench_strs, get_bench_val);
}
