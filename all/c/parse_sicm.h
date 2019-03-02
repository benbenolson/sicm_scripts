#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <limits.h>
#include <sicm_parsing.h>
#include <sicm_packing.h>
#include "graph_helper.h"
#include "table_helper.h"

#define DEFAULT_HEATMAP_TITLE "Relative Allocation Site Per-Interval Accesses"
#define DEFAULT_HOTSET_DIFF_TITLE "Offline and Online Hotset Differences"
#define SORT_WEIGHT_STRING "weight"
#define CURRENT_VALUE_STRING "profile_all_current"
#define TOTAL_VALUE_STRING "profile_all"

char *sicm_metrics_list[] = {
  "graph_hotset_diff_weighted",
  "graph_heatmap_weighted",
  "graph_hotset_diff_top100",
  "graph_heatmap_top100",
  "graph_heatmap_proposal",
  "prof_tot_value",
  "prof_time_over",
  "num_rebinds",
  NULL
};

typedef struct sicm_metrics {
  size_t interval_time_over,
         total_accesses,
         num_rebinds;
} sicm_metrics;

sicm_metrics *init_sicm_metrics() {
  sicm_metrics *info;
  info = malloc(sizeof(sicm_metrics));

  info->interval_time_over = 0;
  info->num_rebinds = 0;

  return info;
}

void graph_hotset_diff(FILE *input_file, char *metric, char top100) {
  char *hotset_diff_table_name, *weight_ratio_table_name,
       *line, *args;

  /* First, use the parsing and packing libraries to gather the info */
  hotset_diff_table_name = generate_hotset_diff_table(input_file, top100, NULL);
  weight_ratio_table_name = generate_weight_ratio_table(input_file, top100, NULL);

  /* Call the graphing script wrapper */
  if(!graph_title) {
    /* Set a default title */
    graph_title = malloc(sizeof(char) * (strlen(DEFAULT_HOTSET_DIFF_TITLE) + 1));
    strcpy(graph_title, DEFAULT_HOTSET_DIFF_TITLE);
  }
  args = orig_malloc(sizeof(char) *
                     (strlen(hotset_diff_table_name) +
                      strlen(weight_ratio_table_name) +
                      strlen(graph_title) +
                      5)); /* Room for 3 spaces, two quotes, and NULL */
  strcpy(args, hotset_diff_table_name);
  strcat(args, " ");
  strcat(args, weight_ratio_table_name);
  strcat(args, " '");
  strcat(args, graph_title);
  strcat(args, "'");
  jgraph_wrapper(metric, args);

  free(hotset_diff_table_name);
  free(args);
  if(graph_title) {
    free(graph_title);
  }
}

void graph_heatmap(FILE *input_file, char *metric, char top100, char *sort_string) {
  char *heatmap_name, *weight_ratio_table_name,
       *args;
  application_profile *prof;

  /* Now use the profiling info to generate the input tables */
  heatmap_name = generate_heatmap_table(input_file, top100, sort_string);
  weight_ratio_table_name = generate_weight_ratio_table(input_file, top100, sort_string);

  /* Call the graphing script wrapper */
  if(!graph_title) {
    /* Set a default title */
    graph_title = malloc(sizeof(char) * (strlen(DEFAULT_HEATMAP_TITLE) + 1));
    strcpy(graph_title, DEFAULT_HEATMAP_TITLE);
  }
  args = orig_malloc(sizeof(char) *
                     (strlen(heatmap_name) +
                      strlen(weight_ratio_table_name) +
                      strlen(graph_title) +
                      strlen("relative") +
                      6)); /* Room for 3 spaces, two quotes, and NULL */
  strcpy(args, heatmap_name);
  strcat(args, " ");
  strcat(args, weight_ratio_table_name);
  strcat(args, " '");
  strcat(args, graph_title);
  strcat(args, "' relative");
  jgraph_wrapper(metric, args);

  free(heatmap_name);
  free(args);
  if(graph_title) {
    free(graph_title);
  }
}

void parse_sicm(FILE *file, char *metric, sicm_metrics *info, int site) {
  double time, interval_time;
  char retval = 0;
  char *line;
  size_t len, rebinds, i, n;
  ssize_t read;

  if(strcmp(metric, "graph_heatmap_weighted") == 0) {
    graph_heatmap(file, metric, 0, NULL);
  } else if(strcmp(metric, "graph_hotset_diff_weighted") == 0) {
    graph_hotset_diff(file, metric, 0);
  } else if(strcmp(metric, "graph_heatmap_top100") == 0) {
    graph_heatmap(file, metric, 1, NULL);
  } else if(strcmp(metric, "graph_hotset_diff_top100") == 0) {
    graph_hotset_diff(file, metric, 1);
  } else if(strcmp(metric, "graph_heatmap_proposal") == 0) {
    graph_heatmap(file, metric, 1, SORT_WEIGHT_STRING);
  } else {
    /* The metric requires parsing a file in-house */
    line = NULL;
    len = 0;
    while(read = getline(&line, &len, file) != -1) {
      if(sscanf(line, "WARNING: Interval (%lf) went over the time limit (%lf).", &time, &interval_time) == 2) {
        info->interval_time_over += (time - interval_time);
      } else if(sscanf(line, "  Number of rebinds: %zu", &rebinds) == 1) {
        info->num_rebinds += rebinds;
      }
    }
  }
}

char *is_sicm_metric(char *metric) {
  char *ptr, *filename;
  int i;

  i = 0;
  while((ptr = sicm_metrics_list[i]) != NULL) {
    if(strcmp(metric, ptr) == 0) {
      if(strcmp(metric, "num_rebinds") == 0) {
        filename = malloc(sizeof(char) * (strlen("online.txt") + 1));
        strcpy(filename, "online.txt");
      } else {
        filename = malloc(sizeof(char) * (strlen("profile.txt") + 1));
        strcpy(filename, "profile.txt");
      }
      return filename;
    }
    i++;
  }

  return NULL;
}

void print_sicm_metric(char *metric, sicm_metrics *info) {
  if(strcmp(metric, "prof_tot_value") == 0) {
    printf("%zu\n", info->total_accesses);
  } else if(strcmp(metric, "prof_time_over") == 0) {
    printf("%zu\n", info->interval_time_over);
  } else if(strcmp(metric, "num_rebinds") == 0) {
    printf("%zu\n", info->num_rebinds);
  } else if(strcmp(metric, "graph_heatmap_weighted") == 0) {
  } else if(strcmp(metric, "graph_hotset_diff_weighted") == 0) {
  } else if(strcmp(metric, "graph_heatmap_top100") == 0) {
  } else if(strcmp(metric, "graph_hotset_diff_top100") == 0) {
  } else if(strcmp(metric, "graph_heatmap_proposal") == 0) {
  }
}
