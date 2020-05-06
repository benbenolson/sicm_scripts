#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <limits.h>
#include <math.h>

char *memreserve_metrics_list[] = {
  "num_reserved_bytes",
  NULL
};

typedef struct memreserve_metrics {
  unsigned long num_reserved_bytes;
} memreserve_metrics;

memreserve_metrics *init_memreserve_metrics() {
  memreserve_metrics *info;
  info = malloc(sizeof(memreserve_metrics));

  info->num_reserved_bytes = 0;

  return info;
}

void parse_memreserve(FILE *file, memreserve_metrics *info) {
  char *line;
  size_t len;
  ssize_t read;
  char flag;
  unsigned long tmp_ul;
  size_t pagesize;
  
  flag = 0; /* 0: not in any blocks.
               1: in GET_NUM_RESERVED_PAGES */
               
  pagesize = (size_t) sysconf(_SC_PAGESIZE);

  line = NULL;
  len = 0;
  while(read = getline(&line, &len, file) != -1) {
    if(flag == 0) {
      if(strncmp(line, "===== BEGIN GET_NUM_RESERVED_PAGES =====", 40) == 0) {
        flag = 1;
        continue;
      }
    } else if(flag == 1) {
      if(sscanf(line, "Wrong node: %lu", &tmp_ul) == 1) {
        info->num_reserved_bytes = tmp_ul * pagesize;
      } else if(strncmp(line, "===== END GET_NUM_RESERVED_PAGES =====", 38) == 0) {
        flag = 0;
        continue;
      } else {
        /* Unrecognized line, but we don't want to parse every line, so we'll ignore it */
      }
    } else {
      /* Impossible */
    }
  }

  return;
}

char *is_memreserve_metric(char *metric_str) {
  char *ptr, *filename;
  int i;

  i = 0;
  while((ptr = memreserve_metrics_list[i]) != NULL) {
    if(strcmp(metric_str, ptr) == 0) {
      filename = malloc(sizeof(char) * (strlen("memreserve.txt") + 1));
      strcpy(filename, "memreserve.txt");
      return filename;
    }
    i++;
  }

  return NULL;
}

void set_memreserve_metric(char *metric_str, memreserve_metrics *info, metric *m) {
  if(strcmp(metric_str, "num_reserved_bytes") == 0) {
    m->val.s = (size_t) info->num_reserved_bytes;
    m->type = 1;
  }
}
