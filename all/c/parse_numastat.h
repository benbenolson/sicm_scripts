#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <limits.h>

char *numastat_metrics_list[] = {
  "memfree",
  "avg_memfree",
  "memfree_noreserve",
  "memfree_before",
  NULL
};

typedef struct numastat_metrics {
  /* An array of memfree values.
     First dimension is per-interval,
     second dimension is per-node */
  long long **memfree_vals;
  size_t num_intervals;

  /* Per-node memfree averages. */
  long long *memfree_avgs;
} numastat_metrics;

numastat_metrics *init_numastat_metrics() {
  numastat_metrics *info;
  info = malloc(sizeof(numastat_metrics));

  info->num_intervals = 0;
  info->memfree_vals = NULL;
  info->memfree_avgs = NULL;

  return info;
}

/* In this function, we assume that all `numastat` printouts in the file
   have the same number of NUMA nodes. If not, this will likely segfault. */
void parse_numastat(FILE *file, numastat_metrics *info) {
  char *tok;
  long long val;
  char *line;
  size_t len;
  ssize_t read;
  size_t num_mem_nodes, i, n;

  line = NULL;
  len = 0;
  while(read = getline(&line, &len, file) != -1) {

    if(strncmp(line, "MemFree ", 8) == 0) {
      /* Allocate room for this interval */
      info->num_intervals++;
      info->memfree_vals = realloc(info->memfree_vals, sizeof(long long *) * info->num_intervals);
      info->memfree_vals[info->num_intervals - 1] = NULL;
      tok = strtok(line, " ");
      tok = strtok(NULL, " ");
      num_mem_nodes = 0;
      while(tok) {
        val = strtoul(tok, NULL, 0);
        num_mem_nodes++;
        info->memfree_vals[info->num_intervals - 1] = realloc(info->memfree_vals[info->num_intervals - 1], sizeof(long long) * num_mem_nodes);
        info->memfree_vals[info->num_intervals - 1][num_mem_nodes - 1] = val;
        tok = strtok(NULL, " ");
      }
    }
  }

  /* Now calculate the aggregated metrics */
  info->memfree_avgs = malloc(sizeof(long long) * num_mem_nodes);
  for(i = 0; i < num_mem_nodes; i++) {
    info->memfree_avgs[i] = 0;
    /* Calculate an average for this node. */
    for(n = 0; n < info->num_intervals; n++) {
      info->memfree_avgs[i] += (info->memfree_vals[n][i] - info->memfree_avgs[i]) / ((long long)(n + 1));
    }
  }

  return;
}

char *is_numastat_metric(char *metric) {
  char *ptr, *filename;
  int i;

  i = 0;
  while((ptr = numastat_metrics_list[i]) != NULL) {
    if(strcmp(metric, ptr) == 0) {
      /* Now we need to determine which numastat file we're going to parse:
         1. numastat.txt
         2. numastat_noreserve.txt
         3. numastat_before.txt
      */
      if(strstr(metric, "_noreserve") != NULL) {
        filename = malloc(sizeof(char) * (strlen("numastat_noreserve.txt") + 1));
        strcpy(filename, "numastat_noreserve.txt");
      } else if(strstr(metric, "_before") != NULL) {
        filename = malloc(sizeof(char) * (strlen("numastat_before.txt") + 1));
        strcpy(filename, "numastat_before.txt");
      } else {
        filename = malloc(sizeof(char) * (strlen("numastat.txt") + 1));
        strcpy(filename, "numastat.txt");
      }
      return filename;
    }
    i++;
  }

  return NULL;
}

void print_numastat_metric(char *metric, numastat_metrics *info, long long node) {
  if(node == UINT_MAX) {
    fprintf(stderr, "This metric requires the `--node` argument. Aborting.\n");
    exit(1);
  }

  if((strcmp(metric, "memfree") == 0) || (strcmp(metric, "avg_memfree") == 0) ||
     (strcmp(metric, "memfree_noreserve") == 0) || (strcmp(metric, "memfree_before") == 0)) {
    printf("%ld", info->memfree_avgs[node]);
  }
}
