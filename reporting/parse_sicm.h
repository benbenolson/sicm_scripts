#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <limits.h>
#include <math.h>
#include <sicm_parsing.h>
#include <sicm_packing.h>

#define NUM_SICM_METRICS 14
char *sicm_strs[NUM_SICM_METRICS+1] = {
  "online_num_rebinds",
  "online_total_rebind_time",
  "online_total_rebind_estimate",
  "prof_num_intervals",
  "prof_total_interval_time",
  "prof_num_phases",
  "prof_avg_interval_time",
  "prof_last_phase_time",
  "prof_total_rss_time",
  "prof_total_acc",
  "prof_geomean_hotset_peak_size",
  "prof_geomean_device_peak_size",
  "prof_geomean_hotset_current_size",
  "prof_geomean_device_current_size",
  NULL
};
enum sicm_indices {
  ONLINE_NUM_REBINDS,
  ONLINE_TOTAL_REBIND_TIME,
  ONLINE_TOTAL_REBIND_ESTIMATE,
  PROF_NUM_INTERVALS,
  PROF_TOTAL_INTERVAL_TIME,
  PROF_NUM_PHASES,
  PROF_AVG_INTERVAL_TIME,
  PROF_LAST_PHASE_TIME,
  PROF_TOTAL_RSS_TIME,
  PROF_TOTAL_ACC,
  PROF_GEOMEAN_HOTSET_PEAK_SIZE,
  PROF_GEOMEAN_DEVICE_PEAK_SIZE,
  PROF_GEOMEAN_HOTSET_CURRENT_SIZE,
  PROF_GEOMEAN_DEVICE_CURRENT_SIZE
};
static double sicm_vals[NUM_SICM_METRICS];

double get_sicm_val(char *metric_str, char *path, metric_opts *mopts) {
  char retval = 0;
  char *line, *filepath;
  size_t len, rebinds, i, n, x, tmp_sizet;
  ssize_t read;
  double tmp_dbl, hotset_sum, device_sum,
         hotset_cur_sum, device_cur_sum;
  FILE *file;
         
  application_profile *app_prof;
  interval_profile *interval;
  
  if(strncmp(metric_str, "online_", 7) == 0) {
    filepath = construct_path(path, "online.txt");
  } else if(strncmp(metric_str, "prof_", 5) == 0) {
    filepath = construct_path(path, "profile.txt");
  } else {
    filepath = construct_path(path, "profile.txt");
  }
  file = fopen(filepath, "r");
  if(!file) {
    fprintf(stderr, "WARNING: Failed to open '%s'. Filling with zero.\n");
    return 0.0;
  }
  free(filepath);
  
  if(strncmp(metric_str, "prof_", 5) == 0) {
    app_prof = sh_parse_profiling(file);
    for(i = 0; i < app_prof->num_intervals; i++) {
      interval = &(app_prof->intervals[i]);
      sicm_vals[PROF_TOTAL_INTERVAL_TIME] += interval->time;
      sicm_vals[PROF_NUM_INTERVALS]++;
      if(app_prof->has_profile_rss) {
        sicm_vals[PROF_TOTAL_RSS_TIME] += interval->profile_rss.time;
      }
      if(app_prof->has_profile_all) {
        for(n = 0; n < interval->max_index; n++) {
          if(!interval->arenas[n]) {
            continue;
          }
          for(x = 0; x < app_prof->num_profile_all_events; x++) {
            sicm_vals[PROF_TOTAL_ACC] += interval->arenas[n]->profile_all.events[x].current;
          }
        }
      }
      if(app_prof->has_profile_online) {
        if(interval->profile_online.phase_change) {
          sicm_vals[PROF_NUM_PHASES]++;
        }
        hotset_sum = 0.0;
        device_sum = 0.0;
        hotset_cur_sum = 0.0;
        device_cur_sum = 0.0;
        for(n = 0; n < interval->num_arenas; n++) {
          if(app_prof->has_profile_rss) {
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
          sicm_vals[PROF_GEOMEAN_HOTSET_PEAK_SIZE] += log(hotset_sum);
        }
        if(device_sum) {
          sicm_vals[PROF_GEOMEAN_DEVICE_PEAK_SIZE] += log(device_sum);
        }
        if(hotset_cur_sum) {
          sicm_vals[PROF_GEOMEAN_HOTSET_CURRENT_SIZE] += log(hotset_cur_sum);
        }
        if(device_cur_sum) {
          sicm_vals[PROF_GEOMEAN_DEVICE_CURRENT_SIZE] += log(device_cur_sum);
        }
      }
    }
    
    /* Get the geomean of the peak values */
    sicm_vals[PROF_GEOMEAN_HOTSET_PEAK_SIZE] /= app_prof->num_intervals;
    sicm_vals[PROF_GEOMEAN_DEVICE_PEAK_SIZE] /= app_prof->num_intervals;
    sicm_vals[PROF_GEOMEAN_HOTSET_PEAK_SIZE] = exp(sicm_vals[PROF_GEOMEAN_HOTSET_PEAK_SIZE]);
    sicm_vals[PROF_GEOMEAN_DEVICE_PEAK_SIZE] = exp(sicm_vals[PROF_GEOMEAN_DEVICE_PEAK_SIZE]);
    
    /* Get the geomean of the current values */
    sicm_vals[PROF_GEOMEAN_HOTSET_CURRENT_SIZE] /= app_prof->num_intervals;
    sicm_vals[PROF_GEOMEAN_DEVICE_CURRENT_SIZE] /= app_prof->num_intervals;
    sicm_vals[PROF_GEOMEAN_HOTSET_CURRENT_SIZE] = exp(sicm_vals[PROF_GEOMEAN_HOTSET_CURRENT_SIZE]);
    sicm_vals[PROF_GEOMEAN_DEVICE_CURRENT_SIZE] = exp(sicm_vals[PROF_GEOMEAN_DEVICE_CURRENT_SIZE]);
    sicm_vals[PROF_NUM_PHASES]++;
    sicm_vals[PROF_AVG_INTERVAL_TIME] = sicm_vals[PROF_TOTAL_INTERVAL_TIME] / sicm_vals[PROF_NUM_INTERVALS];
  } else if(strncmp(metric_str, "online_", 7) == 0) {
    /* The metric requires parsing the online debug file in-house */
    line = NULL;
    len = 0;
    while(read = getline(&line, &len, file) != -1) {
      if(sscanf(line, "Full rebind estimate: %zu ms, real: %lf s.", &tmp_sizet, &tmp_dbl) == 2) {
        sicm_vals[ONLINE_TOTAL_REBIND_TIME] += tmp_dbl;
        sicm_vals[ONLINE_TOTAL_REBIND_ESTIMATE] += tmp_sizet;
        sicm_vals[ONLINE_NUM_REBINDS]++;
      }
    }
  }
  
cleanup:
  fclose(file);
  
  return sicm_vals[metric_index(metric_str, sicm_strs)];
}

void register_sicm_metrics() {
  register_parser(sicm_strs, get_sicm_val);
}
