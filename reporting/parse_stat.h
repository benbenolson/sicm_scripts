#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "report.h"

/* The `*_strs` and `*_indices` arrays must line up precisely. */
#define NUM_STAT_METRICS 1
static char *stat_strs[NUM_STAT_METRICS+1] = {
  "num_iters",
  NULL
};
enum stat_indices {
  NUM_ITERS
};
static double stat_vals[NUM_STAT_METRICS];

double get_stat_val(char *metric_str, char *path, metric_opts *mopts) {
  stat_vals[NUM_ITERS] = 1;
  return stat_vals[metric_index(metric_str, stat_strs)];
}

void register_stat_metrics() {
  register_parser(stat_strs, get_stat_val);
}
