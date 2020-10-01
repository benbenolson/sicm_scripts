#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <limits.h>
#include <math.h>

char *pcm_memory_metrics_list[] = {
  "geomean_bw",
  "geomean_dram_bw",
  "geomean_pmm_bw",
  NULL
};

typedef struct pcm_memory_metrics {
  /* First dimension is per-interval, next is per-socket */
  double **tot_bw_vals,
         **dram_read_vals, **dram_write_vals,
         **pmm_read_vals, **pmm_write_vals;
  double *tot_bw_geomeans, *dram_bw_geomeans, *pmm_bw_geomeans; /* per-socket */
  int num_skts;
  size_t num_intervals;
} pcm_memory_metrics;

/* NOTE: Currently only supports two sockets. */

char parse_pcm_memory(FILE *file, pcm_memory_metrics *info) {
  double tmp, tmp2;
  long long val;
  char *line;
  size_t len;
  ssize_t read;
  size_t i, n;

  line = NULL;
  len = 0;
  while(read = getline(&line, &len, file) != -1) {
    if(sscanf(line, "|-- Socket %lf --||-- Socket %lf --|", &tmp, &tmp2) == 2) {
      info->num_skts = 2;
      info->num_intervals++;
    } else if(sscanf(line, "|-- NODE 0 Memory (MB/s): %lf --||-- NODE 1 Memory (MB/s): %lf --|", &tmp, &tmp2) == 2) {
      info->tot_bw_vals = realloc(info->tot_bw_vals, sizeof(double *) * info->num_intervals);
      info->tot_bw_vals[info->num_intervals - 1] = malloc(sizeof(double) * 2);
      info->tot_bw_vals[info->num_intervals - 1][0] = tmp;
      info->tot_bw_vals[info->num_intervals - 1][1] = tmp2;
    } else if(sscanf(line, "|-- NODE 0 Mem Read (MB/s) : %lf --||-- NODE 1 Mem Read (MB/s) : %lf --|", &tmp, &tmp2) == 2) {
      info->dram_read_vals = realloc(info->dram_read_vals, sizeof(double *) * info->num_intervals);
      info->dram_read_vals[info->num_intervals - 1] = malloc(sizeof(double) * 2);
      info->dram_read_vals[info->num_intervals - 1][0] = tmp;
      info->dram_read_vals[info->num_intervals - 1][1] = tmp2;
    } else if(sscanf(line, "|-- NODE 0 Mem Write(MB/s) : %lf --||-- NODE 1 Mem Write(MB/s) : %lf --|", &tmp, &tmp2) == 2) {
      info->dram_write_vals = realloc(info->dram_write_vals, sizeof(double *) * info->num_intervals);
      info->dram_write_vals[info->num_intervals - 1] = malloc(sizeof(double) * 2);
      info->dram_write_vals[info->num_intervals - 1][0] = tmp;
      info->dram_write_vals[info->num_intervals - 1][1] = tmp2;
    } else if(sscanf(line, "|-- NODE 0 PMM Read (MB/s): %lf --||-- NODE 1 PMM Read (MB/s): %lf --|", &tmp, &tmp2) == 2) {
      info->pmm_read_vals = realloc(info->pmm_read_vals, sizeof(double *) * info->num_intervals);
      info->pmm_read_vals[info->num_intervals - 1] = malloc(sizeof(double) * 2);
      info->pmm_read_vals[info->num_intervals - 1][0] = tmp;
      info->pmm_read_vals[info->num_intervals - 1][1] = tmp2;
    } else if(sscanf(line, "|-- NODE 0 PMM Write(MB/s): %lf --||-- NODE 1 PMM Write(MB/s): %lf --|", &tmp, &tmp2) == 2) {
      info->pmm_write_vals = realloc(info->pmm_write_vals, sizeof(double *) * info->num_intervals);
      info->pmm_write_vals[info->num_intervals - 1] = malloc(sizeof(double) * 2);
      info->pmm_write_vals[info->num_intervals - 1][0] = tmp;
      info->pmm_write_vals[info->num_intervals - 1][1] = tmp2;
    }
  }
  
  /* Aggregate the results, calculate geomeans */
  info->tot_bw_geomeans = calloc(info->num_skts, sizeof(double));
  info->dram_bw_geomeans = calloc(info->num_skts, sizeof(double));
  info->pmm_bw_geomeans = calloc(info->num_skts, sizeof(double));
  for(n = 0; n < info->num_skts; n++) {
    for(i = 0; i < info->num_intervals; i++) {
      if(info->tot_bw_vals[i][n]) {
        info->tot_bw_geomeans[n] += log(info->tot_bw_vals[i][n]);
      }
      if(info->dram_read_vals[i][n] + info->dram_write_vals[i][n]) {
        info->dram_bw_geomeans[n] += log(info->dram_read_vals[i][n] + info->dram_write_vals[i][n]);
      }
      if(info->pmm_read_vals[i][n] + info->pmm_write_vals[i][n]) {
        info->pmm_bw_geomeans[n] += log(info->pmm_read_vals[i][n] + info->pmm_write_vals[i][n]);
      }
    }
    info->tot_bw_geomeans[n] /= info->num_intervals;
    info->tot_bw_geomeans[n] = exp(info->tot_bw_geomeans[n]);
    info->dram_bw_geomeans[n] /= info->num_intervals;
    info->dram_bw_geomeans[n] = exp(info->dram_bw_geomeans[n]);
    info->pmm_bw_geomeans[n] /= info->num_intervals;
    info->pmm_bw_geomeans[n] = exp(info->pmm_bw_geomeans[n]);
  }

  return 0;
}

pcm_memory_metrics *init_pcm_memory_metrics() {
  pcm_memory_metrics *info;
  info = malloc(sizeof(pcm_memory_metrics));
  info->tot_bw_vals = NULL;
  info->dram_read_vals = NULL;
  info->dram_write_vals = NULL;
  info->pmm_read_vals = NULL;
  info->pmm_write_vals = NULL;
  info->tot_bw_geomeans = NULL;
  info->dram_bw_geomeans = NULL;
  info->pmm_bw_geomeans = NULL;
  info->num_skts = 0;
  info->num_intervals = 0;
}

char *is_pcm_memory_metric(char *metric) {
  char *ptr, *filename;
  int i;

  i = 0;
  while((ptr = pcm_memory_metrics_list[i]) != NULL) {
    if(strcmp(metric, ptr) == 0) {
      filename = malloc(sizeof(char) * (strlen("pcm-memory.txt") + 1));
      strcpy(filename, "pcm-memory.txt");
      return filename;
    }
    i++;
  }

  return NULL;
}

metric *set_pcm_memory_metric(char *metric_str, pcm_memory_metrics *info, long long node) {
  metric *m;
  
  if(node == UINT_MAX) {
    fprintf(stderr, "This metric requires the `--node` argument. Aborting.\n");
    exit(1);
  }

  m = malloc(sizeof(metric));
  if((strcmp(metric_str, "geomean_bw") == 0)) {
    m->val.f = info->tot_bw_geomeans[node];
    m->type = 0;
  } else if((strcmp(metric_str, "geomean_dram_bw") == 0)) {
    m->val.f = info->dram_bw_geomeans[node];
    m->type = 0;
  } else if((strcmp(metric_str, "geomean_pmm_bw") == 0)) {
    m->val.f = info->pmm_bw_geomeans[node];
    m->type = 0;
  }
  
  return m;
}
