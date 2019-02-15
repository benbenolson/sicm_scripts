#include <getopt.h>
#include <string.h>
#include <ctype.h>
#include "parse_gnu_time.h"
#include "parse_numastat.h"

typedef struct metrics {
  gnu_time_metrics *gnu_time;
  numastat_metrics *numastat;
} metrics;

metrics *init_metrics() {
  metrics *info;
  info = malloc(sizeof(metrics));

  info->gnu_time = init_gnu_time_metrics();
  info->numastat = init_numastat_metrics();

  return info;
}

void free_metrics(metrics *info) {
  free(info->gnu_time);
  free(info->numastat);
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

void parse_metrics(metrics *info, char *path, char *metric, unsigned long node) {
  char *filename, *fullpath;
  FILE *file;

  if((filename = is_gnu_time_metric(metric)) != NULL) {
    fullpath = construct_path(path, filename);
    file = fopen(fullpath, "r");
    parse_gnu_time(file, info->gnu_time);
    print_gnu_time_metric(metric, info->gnu_time);
  } else if((filename = is_numastat_metric(metric)) != NULL) {
    fullpath = construct_path(path, filename);
    file = fopen(fullpath, "r");
    if(!file) {
      fprintf(stderr, "Failed to open file '%s'. Aborting.\n", fullpath);
      exit(1);
    }
    parse_numastat(file, info->numastat);
    print_numastat_metric(metric, info->numastat, node);
  } else {
    fprintf(stderr, "Metric not yet implemented.\n");
    return;
  }

  free(fullpath);
  free(filename);
  fclose(file);
}
