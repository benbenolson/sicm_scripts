#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "stat.h"

/* The `*_strs` and `*_indices` arrays must line up precisely. */
#define NUM_GNU_TIME_METRICS 3
static char *gnu_time_strs[NUM_GNU_TIME_METRICS+1] = {
  "peak_rss",
  "peak_rss_kbytes",
  "runtime",
  NULL
};
enum gnu_time_indices {
  PEAK_RSS,
  PEAK_RSS_KBYTES,
  RUNTIME
};
static double gnu_time_vals[NUM_GNU_TIME_METRICS];

double get_gnu_time_val(char *metric_str, char *path, metric_opts *mopts) {
  size_t tmp, tmp2;
  float tmp_f;
  char *line, *filepath;
  size_t len;
  ssize_t read;
  FILE *file;
  
  filepath = construct_path(path, "stdout.txt");
  file = fopen(filepath, "r");
  if(!file) {
    fprintf(stderr, "WARNING: Failed to open '%s'. Filling with zero.\n");
    return 0.0;
  }
  free(filepath);
  
  line = NULL;
  len = 0;
  while(read = getline(&line, &len, file) != -1) {
    if(sscanf(line, "  Maximum resident set size (kbytes): %zu", &tmp) == 1) {
      gnu_time_vals[PEAK_RSS_KBYTES] = tmp;
      gnu_time_vals[PEAK_RSS] = ((double)tmp) / ((double)1024) / ((double)1024);
      goto cleanup;
    } else if(sscanf(line, "   Elapsed (wall clock) time (h:mm:ss or m:ss): %zu:%zu:%f", &tmp, &tmp2, &tmp_f) == 3) {
      gnu_time_vals[RUNTIME] = (tmp * 60 * 60) + (tmp2 * 60) + ((size_t) tmp_f);
    } else if(sscanf(line, "   Elapsed (wall clock) time (h:mm:ss or m:ss): %zu:%f", &tmp, &tmp_f) == 2) {
      if(tmp_f < 0) {
        /* Just to make sure the below explicit cast from float->size_t is valid */
        fprintf(stderr, "Number of seconds from GNU time was negative. Aborting.\n");
        exit(1);
      }
      gnu_time_vals[RUNTIME] = (tmp * 60) + ((size_t) tmp_f);
    }
  }
  
cleanup:
  free(line);
  fclose(file);
  
  return gnu_time_vals[metric_index(metric_str, gnu_time_strs)];
}

void register_gnu_time_metrics() {
  register_parser(gnu_time_strs, get_gnu_time_val);
}
