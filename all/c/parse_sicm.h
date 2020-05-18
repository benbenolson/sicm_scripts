#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <limits.h>
#include <math.h>
#include <sicm_parsing.h>
#include <sicm_packing.h>
#include "graph_helper.h"
#include "table_helper.h"

#define DEFAULT_HEATMAP_TITLE "Relative Allocation Site Per-Interval Accesses"
#define DEFAULT_HOTSET_DIFF_TITLE "Offline and Online Hotset Differences"

char *sicm_metrics_list[] = {
  "graph_hotset_diff_weighted",
  "graph_heatmap_weighted",
  "graph_hotset_diff_top100",
  "graph_heatmap_top100",
  "graph_heatmap_proposal",
  "graph_online_bandwidth",
  "online_num_rebinds",
  "online_total_rebind_time",
  "online_total_rebind_estimate",
  "prof_num_intervals",
  "prof_total_interval_time",
  "prof_num_phases",
  "prof_avg_interval_time",
  "prof_last_phase_time",
  "prof_geomean_hotset_peak_size",
  "prof_geomean_device_peak_size",
  "prof_geomean_hotset_current_size",
  "prof_geomean_device_current_size",
  NULL
};

typedef struct sicm_metrics {
  double online_total_rebind_time,
         prof_total_interval_time,
         prof_avg_interval_time,
         prof_last_phase_time,
         prof_avg_phase_time,
         prof_geomean_hotset_peak_size,
         prof_geomean_device_peak_size,
         prof_geomean_hotset_current_size,
         prof_geomean_device_current_size;
  size_t online_num_rebinds,
         online_total_rebind_estimate,
         prof_num_intervals,
         prof_num_phases;
  application_profile *app_prof;
} sicm_metrics;

sicm_metrics *init_sicm_metrics() {
  sicm_metrics *info;
  info = malloc(sizeof(sicm_metrics));
  info->app_prof = NULL;
  info->online_total_rebind_time = 0;
  info->online_num_rebinds = 0;
  info->prof_total_interval_time = 0;
  info->prof_avg_interval_time = 0;
  info->prof_last_phase_time = 0;
  info->prof_avg_phase_time = 0;
  info->prof_num_intervals = 0;
  info->prof_num_phases = 0;
  info->prof_geomean_hotset_peak_size = 0.0;
  info->prof_geomean_device_peak_size = 0.0;
  info->prof_geomean_hotset_current_size = 0.0;
  info->prof_geomean_device_current_size = 0.0;

  return info;
}

#include "sicm_graphs.h"

void parse_sicm(FILE *file, char *metric, sicm_metrics *info, int site) {
  char retval = 0;
  char *line;
  size_t len, rebinds, i, n;
  ssize_t read;
  interval_profile *interval;
  double hotset_sum, device_sum,
         hotset_cur_sum, device_cur_sum;
  
  size_t tmp_sizet;
  double tmp_dbl;
  
  if(strcmp(metric, "graph_heatmap_weighted") == 0) {
    graph_heatmap(file, metric, 0, 0);
  } else if(strcmp(metric, "graph_hotset_diff_weighted") == 0) {
    graph_hotset_diff(file, metric, 0);
  } else if(strcmp(metric, "graph_heatmap_top100") == 0) {
    graph_heatmap(file, metric, 1, 0);
  } else if(strcmp(metric, "graph_hotset_diff_top100") == 0) {
    graph_hotset_diff(file, metric, 1);
  } else if(strcmp(metric, "graph_heatmap_proposal") == 0) {
    graph_heatmap(file, metric, 1, WEIGHT);
  } else if(strcmp(metric, "graph_online_bandwidth") == 0) {
    graph_online_bandwidth(file, metric);
  } else if(strncmp(metric, "prof_", 5) == 0) {
    info->app_prof = sh_parse_profiling(file);
    fseek(file, 0, SEEK_SET);
    for(i = 0; i < info->app_prof->num_intervals; i++) {
      interval = &(info->app_prof->intervals[i]);
      info->prof_total_interval_time += interval->time;
      info->prof_num_intervals++;
      if(info->app_prof->has_profile_online) {
        if(interval->profile_online.phase_change) {
          info->prof_num_phases++;
        }
        hotset_sum = 0.0;
        device_sum = 0.0;
        hotset_cur_sum = 0.0;
        device_cur_sum = 0.0;
        for(n = 0; n < interval->num_arenas; n++) {
          if(info->app_prof->has_profile_rss) {
            if(interval->arenas[n]->profile_online.hot &&
               interval->arenas[n]->profile_rss.peak) {
              hotset_sum += (((double) interval->arenas[n]->profile_rss.peak) / 1024 / 1024);
            }
            if(interval->arenas[n]->profile_online.hot &&
               interval->arenas[n]->profile_rss.current) {
              hotset_cur_sum += (((double) interval->arenas[n]->profile_rss.current) / 1024 / 1024);
            }
            if((interval->arenas[n]->profile_online.dev == 1) &&
               interval->arenas[n]->profile_rss.peak) {
              device_sum += (((double) interval->arenas[n]->profile_rss.peak) / 1024 / 1024);
            }
            if((interval->arenas[n]->profile_online.dev == 1) &&
               interval->arenas[n]->profile_rss.current) {
              device_cur_sum += (((double) interval->arenas[n]->profile_rss.current) / 1024 / 1024);
            }
          }
        }
        if(hotset_sum) {
          info->prof_geomean_hotset_peak_size += log(hotset_sum);
        }
        if(device_sum) {
          info->prof_geomean_device_peak_size += log(device_sum);
        }
        if(hotset_cur_sum) {
          info->prof_geomean_hotset_current_size += log(hotset_cur_sum);
        }
        if(device_cur_sum) {
          info->prof_geomean_device_current_size += log(device_cur_sum);
        }
      }
    }
    info->prof_geomean_hotset_peak_size /= info->app_prof->num_intervals;
    info->prof_geomean_device_peak_size /= info->app_prof->num_intervals;
    info->prof_geomean_hotset_peak_size = exp(info->prof_geomean_hotset_peak_size);
    info->prof_geomean_device_peak_size = exp(info->prof_geomean_device_peak_size);
    info->prof_geomean_hotset_current_size /= info->app_prof->num_intervals;
    info->prof_geomean_device_current_size /= info->app_prof->num_intervals;
    info->prof_geomean_hotset_current_size = exp(info->prof_geomean_hotset_current_size);
    info->prof_geomean_device_current_size = exp(info->prof_geomean_device_current_size);
    info->prof_num_phases++;
    info->prof_avg_interval_time = info->prof_total_interval_time / info->prof_num_intervals;
  } else if(strncmp(metric, "online_", 7) == 0) {
    /* The metric requires parsing a file in-house */
    line = NULL;
    len = 0;
    while(read = getline(&line, &len, file) != -1) {
      if(sscanf(line, "Full rebind estimate: %zu ms, real: %lf s.", &tmp_sizet, &tmp_dbl) == 2) {
        info->online_total_rebind_time += tmp_dbl;
        info->online_total_rebind_estimate += tmp_sizet;
        info->online_num_rebinds++;
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
      printf("Matched the metric %s\n", metric);
      if(strncmp(metric, "online_", 7) == 0) {
        filename = malloc(sizeof(char) * (strlen("online.txt") + 1));
        strcpy(filename, "online.txt");
      } else if(strncmp(metric, "prof_", 5) == 0) {
        filename = malloc(sizeof(char) * (strlen("profile.txt") + 1));
        strcpy(filename, "profile.txt");
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

void set_sicm_metric(char *metric_str, sicm_metrics *info, metric *m) {
  if(strncmp(metric_str, "graph_", 6) == 0) {
    
  /* Use profile.txt */
  } else if(strcmp(metric_str, "prof_avg_interval_time") == 0) {
    m->val.f = info->prof_avg_interval_time;
    m->type = 0;
  } else if(strcmp(metric_str, "prof_last_phase_time") == 0) {
    m->val.f = info->prof_last_phase_time;
    m->type = 0;
  } else if(strcmp(metric_str, "prof_num_phases") == 0) {
    m->val.f = info->prof_num_phases;
    m->type = 0;
  } else if(strcmp(metric_str, "prof_geomean_hotset_peak_size") == 0) {
    m->val.f = info->prof_geomean_hotset_peak_size;
    m->type = 0;
  } else if(strcmp(metric_str, "prof_geomean_device_peak_size") == 0) {
    m->val.f = info->prof_geomean_device_peak_size;
    m->type = 0;
  } else if(strcmp(metric_str, "prof_geomean_hotset_current_size") == 0) {
    m->val.f = info->prof_geomean_hotset_current_size;
    m->type = 0;
  } else if(strcmp(metric_str, "prof_geomean_device_current_size") == 0) {
    m->val.f = info->prof_geomean_device_current_size;
    m->type = 0;
    
  /* Specific to online approach */
  } else if(strcmp(metric_str, "online_total_rebind_time") == 0) {
    m->val.f = info->online_total_rebind_time;
    m->type = 0;
  } else if(strcmp(metric_str, "online_total_rebind_estimate") == 0) {
    m->val.s = info->online_total_rebind_estimate;
    m->type = 1;
  } else if(strcmp(metric_str, "online_num_rebinds") == 0) {
    m->val.f = info->online_num_rebinds;
    m->type = 0;
  }
}
