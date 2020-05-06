#include <getopt.h>
#include <string.h>
#include <ctype.h>

/* Globals for setting various miscellaneous options; i.e.
   graph titles, benchmark names, etc. */
static char *graph_title = NULL;
static char *output_filename = NULL;
static char output_filetype = 0;

typedef struct metric {
  union {
    double f;
    size_t s;
  } val;
  int type; /* 0 for double,
               1 for size_t */
} metric;

#include "parse_gnu_time.h"
#include "parse_numastat.h"
#include "parse_sicm.h"
#include "parse_memreserve.h"
#include "parse_bench.h"
#include "graph_helper.h"
#include "table_helper.h"
#include "graphs.h"

typedef struct metrics {
  gnu_time_metrics *gnu_time;
  numastat_metrics *numastat;
  sicm_metrics *sicm;
  memreserve_metrics *memreserve;
  bench_metrics *bench;
} metrics;

metrics *init_metrics() {
  metrics *info;
  info = malloc(sizeof(metrics));

  info->gnu_time = init_gnu_time_metrics();
  info->numastat = init_numastat_metrics();
  info->sicm = init_sicm_metrics();
  info->memreserve = init_memreserve_metrics();
  info->bench = init_bench_metrics();

  return info;
}

void free_metrics(metrics *info) {
  free(info->gnu_time);
  free(info->numastat);
  free(info->sicm);
  free(info->memreserve);
  free(info->bench);
  free(info);
}

char *construct_path(char *path, char *filename) {
  size_t pathsize, filenamesize;
  char *fullpath;

  pathsize = strlen(path);
  filenamesize = strlen(filename);

  if(path[pathsize - 1] == '/') {
    fullpath = calloc(pathsize + filenamesize + 1, sizeof(char));
    strcat(fullpath, path);
    strcat(fullpath, filename);
  } else {
    fullpath = calloc(pathsize + filenamesize + 2, sizeof(char));
    strcat(fullpath, path);
    fullpath[pathsize] = '/';
    fullpath[pathsize + 1] = '\0';
    strcat(fullpath, filename);
  }

  return fullpath;
}

metric *parse_metrics(metrics *info, char *path, char *metric_str, unsigned long node, int site) {
  char *filename, *fullpath;
  FILE *file;
  metric *m;

  m = malloc(sizeof(metric));
  if((filename = is_gnu_time_metric(metric_str)) != NULL) {
    fullpath = construct_path(path, filename);
    file = fopen(fullpath, "r");
    if(!file) {
      fprintf(stderr, "Failed to open file '%s'. Aborting.\n", fullpath);
      exit(1);
    }
    parse_gnu_time(file, info->gnu_time);
    set_gnu_time_metric(metric_str, info->gnu_time, m);
  } else if((filename = is_numastat_metric(metric_str)) != NULL) {
    fullpath = construct_path(path, filename);
    file = fopen(fullpath, "r");
    if(!file) {
      fprintf(stderr, "Failed to open file '%s'. Aborting.\n", fullpath);
      exit(1);
    }
    parse_numastat(file, info->numastat);
    set_numastat_metric(metric_str, info->numastat, node, m);
  } else if((filename = is_sicm_metric(metric_str)) != NULL) {
    fullpath = construct_path(path, filename);
    file = fopen(fullpath, "r");
    if(!file) {
      fprintf(stderr, "Failed to open file '%s'. Aborting.\n", fullpath);
      exit(1);
    }
    parse_sicm(file, metric_str, info->sicm, site);
    set_sicm_metric(metric_str, info->sicm, m);
  } else if((filename = is_memreserve_metric(metric_str)) != NULL) {
    fullpath = construct_path(path, filename);
    file = fopen(fullpath, "r");
    if(!file) {
      fprintf(stderr, "Failed to open file '%s'. Aborting.\n", fullpath);
      exit(1);
    }
    parse_memreserve(file, info->memreserve);
    set_memreserve_metric(metric_str, info->memreserve, m);
  } else if((filename = is_bench_metric(metric_str)) != NULL) {
    fullpath = construct_path(path, filename);
    file = fopen(fullpath, "r");
    if(!file) {
      fprintf(stderr, "Failed to open file '%s'. Aborting.\n", fullpath);
      exit(1);
    }
    parse_bench(file, info->bench);
    set_bench_metric(metric_str, info->bench, m);
  } else {
    fprintf(stderr, "Metric not yet implemented.\n");
    exit(1);
  }

  free(fullpath);
  free(filename);
  fclose(file);
  
  return m;
}
