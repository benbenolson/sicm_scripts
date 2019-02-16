#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <limits.h>
#include <sicm_parsing.h>

char *sicm_metrics_list[] = {
  "prof_tot_accesses",
  "prof_time_over",
  NULL
};

typedef struct sicm_metrics {
  size_t interval_time_over,
         total_accesses;
} sicm_metrics;

sicm_metrics *init_sicm_metrics() {
  sicm_metrics *info;
  info = malloc(sizeof(sicm_metrics));

  info->interval_time_over = 0;

  return info;
}

void parse_sicm(FILE *file, sicm_metrics *info) {
  double time, interval_time;
  char retval = 0;
  char *line;
  size_t len;
  ssize_t read;
  application_profile *prof;

  /* First just call SICM's function for parsing the profiling information */
  prof = sh_parse_profiling(file);
  fseek(file, 0, SEEK_SET);

  line = NULL;
  len = 0;
  while(read = getline(&line, &len, file) != 1) {
    if(sscanf(line, "WARNING: Interval (%lf) went over the time limit (%lf).", &time, &interval_time) == 2) {
      info->interval_time_over += (time - interval_time);
    }
  }
}

char *is_sicm_metric(char *metric) {
  char *ptr, *filename;
  int i;

  i = 0;
  while((ptr = sicm_metrics_list[i]) != NULL) {
    if(strcmp(metric, ptr) == 0) {
      filename = malloc(sizeof(char) * (strlen("profile.txt") + 1));
      strcpy(filename, "profile.txt");
      return filename;
    }
    i++;
  }

  return NULL;
}

void print_sicm_metric(char *metric, sicm_metrics *info) {
  if(strcmp(metric, "prof_tot_accesses") == 0) {
    printf("%zu\n", info->total_accesses);
  } else if(strcmp(metric, "prof_time_over") == 0) {
    printf("%zu\n", info->interval_time_over);
  }
}
