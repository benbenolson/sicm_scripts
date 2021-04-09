#pragma once
#include "stat.h"

/* Here, we're just doing a bar graph with a number of clusters. Each bench/config pair has a single value, and we
   want to label each bar with the configuration name, and each cluster of bars with the benchmark name. */
void graph_clustered_bars(size_t num_benches, char **bench_strs, size_t num_configs, char **config_strs, char **human_config_strs, char *size_str, char *metric_str) {
  geo_result tmp_result;
  char *path, *config_str, *bench_str, *chosen_config_str;
  size_t i, n, x;
  double rel_val;
  
  if(NUM_COLORS < num_configs - 1) {
    fprintf(stderr, "I don't have enough colors in `graph_helper.h` to graph this!\n");
    exit(1);
  }
  
  x = 1;
  for(i = 0; i < num_benches; i++) {
    bench_str = bench_strs[i];
    
    /* First, get the value of the first config for this benchmark */
    path = get_config_path(bench_str, size_str, config_strs[0]);
    get_geo_result(path, metric_str, NULL, &tmp_result);
    rel_val = tmp_result.geomean;
    
    for(n = 1; n < num_configs; n++) {
      config_str = config_strs[n];
      path = get_config_path(bench_str, size_str, config_str);
      get_geo_result(path, metric_str, NULL, &tmp_result);
      chosen_config_str = config_str;
      if(human_config_strs) {
        chosen_config_str = human_config_strs[n];
      }
      printf("%s %s %s %zu %lf\n", bench_str, chosen_config_str, graph_colors[n - 1], x, tmp_result.geomean / rel_val);
      x++;
    }
    x++;
  }
}

/* The idea here is to have a line, with an x-axis point at each interval, that tracks the predicted efficacy of
   the current hotset. */
void graph_capacity_lines(char *bench_str, char *size_str, char *config_str, char output_eps) {
  FILE *file;
  char *path, *filepath;
  size_t i, node_current, node_max, heap_max, abs_max;
  application_profile *app_prof;
  interval_profile *interval;
  double max_y_val;
  geo_result ***results;
  
  path = get_config_path(bench_str, size_str, config_str);
  filepath = construct_path(path, "i0/profile.txt");
  file = fopen(filepath, "r");
  if(!file) {
    fprintf(stderr, "WARNING: Failed to open '%s'. Not generating graph.\n");
    goto cleanup;
  }
  
  app_prof = sh_parse_profiling(file);
  if(!(app_prof->has_profile_objmap)) {
    fprintf(stderr, "The graph you chose requires objmap profiling. Aborting.\n");
    goto cleanup;
  }
  
  node_max = 0;
  heap_max = 0;
  for(i = 0; i < app_prof->num_intervals; i++) {
    interval = &(app_prof->intervals[i]);
    
    node_current = interval->profile_objmap.upper_current +
                   interval->profile_objmap.lower_current;
    if(node_current > node_max) {
      node_max = node_current;
    }
    
    if(interval->profile_objmap.heap_bytes > heap_max) {
      heap_max = interval->profile_objmap.heap_bytes;
    }
  }
  
  abs_max = node_max;
  if(heap_max > abs_max) {
    abs_max = heap_max;
  }
  
  /* Get the value that we're packing into */
  max_y_val = 1.0;
  results = malloc(sizeof(geo_result **) * 3);
  results[0] = malloc(sizeof(geo_result *) * app_prof->num_intervals);
  results[1] = malloc(sizeof(geo_result *) * app_prof->num_intervals);
  results[2] = malloc(sizeof(geo_result *) * app_prof->num_intervals);
  for(i = 0; i < app_prof->num_intervals; i++) {
    interval = &(app_prof->intervals[i]);
    
    node_current = interval->profile_objmap.upper_current +
                   interval->profile_objmap.lower_current;
    results[0][i] = calloc(1, sizeof(geo_result));
    results[0][i]->geomean = ((double) node_current) / abs_max;
    
    results[1][i] = calloc(1, sizeof(geo_result));
    results[1][i]->geomean = (double) interval->profile_objmap.heap_bytes / abs_max;
    
    results[2][i] = calloc(1, sizeof(geo_result));
    results[2][i]->geomean = ((double) interval->profile_objmap.cgroup_memory_current) / abs_max;
  }
  
  char **curve_labels = (char *[]){"upper_current + lower_current", "objmap", "memory.current"};
  graph_multi_line("Capacity Debugging",
                   "Iteration", "Ratio Against Maximum",
                   0.0, 0.0,
                   app_prof->num_intervals, max_y_val,
                   NULL, app_prof->num_intervals,
                   curve_labels, 3,
                   results,
                   "capacity.png", output_eps);
  
cleanup:
  free(filepath);
  fclose(file);
}

/* The idea here is to have a line, with an x-axis point at each interval, that tracks the predicted efficacy of
   the current hotset. */
void graph_hotset_line(char *bench_str, char *size_str, char *config_str, char output_eps) {
  FILE *file;
  char *path, *filepath;
  size_t i, n, x, last_interval_total, skt,
         prev_interval_hot, prev_interval_dev,
         this_interval_all, this_interval_dev, this_interval_hot,
         num_events, interval_tot, max_hotset_weight;
  application_profile *app_prof;
  interval_profile *interval, *last_interval;
  double y_val, max_y_val, bw, max_bw, upper_max;
  geo_result ***results;
  
  path = get_config_path(bench_str, size_str, config_str);
  filepath = construct_path(path, "i0/profile.txt");
  file = fopen(filepath, "r");
  if(!file) {
    fprintf(stderr, "WARNING: Failed to open '%s'. Not generating graph.\n");
    goto cleanup;
  }
  
  app_prof = sh_parse_profiling(file);
  if(!(app_prof->has_profile_bw)) {
    fprintf(stderr, "The graph you chose requires bw_relative to be in the profiling. Aborting.\n");
    goto cleanup;
  }
  if(!(app_prof->has_profile_online)) {
    fprintf(stderr, "The graph you chose requires online profiling. Aborting.\n");
    goto cleanup;
  }
  if(!(app_prof->has_profile_objmap)) {
    fprintf(stderr, "The graph you chose requires objmap profiling. Aborting.\n");
    goto cleanup;
  }
  
  /* Here, we'll just get the last interval's profiling information. */
  last_interval = &(app_prof->intervals[app_prof->num_intervals - 1]);
  last_interval_total = 0;
  for(n = 0; n < last_interval->max_index; n++) {
    if(!(last_interval->arenas[n])) break;
    if(last_interval->arenas[n]->profile_online.hot == 1) {
      /* This arena is in the final hotset, which we're assuming to be the correct one. 
         Sum the amount of bw-relative that goes to this site. */
      last_interval_total += last_interval->arenas[n]->profile_bw.total;
    }
  }
  
  /* Get the maximum bandwidth value, to take a ratio */
  max_bw = 0;
  for(i = 0; i < app_prof->num_intervals; i++) {
    bw = 0;
    for(skt = 0; skt < app_prof->num_profile_skts; skt++) {
      bw += app_prof->intervals[i].profile_bw.skt[skt].current;
    }
    if(bw > max_bw) {
      max_bw = bw;
    }
  }
  
  /* Get the maximum hotset weight */
  max_hotset_weight = 0;
  for(i = 0; i < app_prof->num_intervals; i++) {
    interval = &(app_prof->intervals[i]);
    if(interval->profile_online.using_hotset_weight > max_hotset_weight) {
      max_hotset_weight = interval->profile_online.using_hotset_weight;
    }
  }
  
  /* Get the value that we're packing into */
  num_events = app_prof->num_profile_all_events;
  upper_max = (double) last_interval->profile_objmap.upper_max;
  this_interval_dev = 0;
  this_interval_hot = 0;
  max_y_val = 0;
  results = malloc(sizeof(geo_result **) * 4);
  results[0] = malloc(sizeof(geo_result *) * app_prof->num_intervals);
  results[1] = malloc(sizeof(geo_result *) * app_prof->num_intervals);
  results[2] = malloc(sizeof(geo_result *) * app_prof->num_intervals);
  results[3] = malloc(sizeof(geo_result *) * app_prof->num_intervals);
  for(i = 0; i < app_prof->num_intervals; i++) {
    interval = &(app_prof->intervals[i]);
    
    /* First, let's get the EE */
    results[0][i] = calloc(1, sizeof(geo_result));
    prev_interval_dev = this_interval_dev;
    prev_interval_hot = this_interval_hot;
    this_interval_dev = 0;
    this_interval_hot = 0;
    this_interval_all = interval->profile_all.total;
    for(n = 0; n < interval->max_index; n++) {
      if(!(interval->arenas[n])) break;
      /* The idea here is to get the arenas that are in the hotset this interval,
         then look at how they *would* perform if they were to be used as an offline hotset. */
      if(interval->arenas[n]->profile_online.hot == 1) {
        this_interval_hot += last_interval->arenas[n]->profile_bw.total;
      }
      if(interval->arenas[n]->profile_online.dev == 1) {
        this_interval_dev += last_interval->arenas[n]->profile_bw.total;
      }
    }
    y_val = ((double) this_interval_dev) / last_interval_total;
    if(y_val > max_y_val) {
      max_y_val = y_val;
    }
    results[0][i]->geomean = y_val;
    
    /* Next, we can grab the bandwidth */
    results[1][i] = calloc(1, sizeof(geo_result));
    bw = 0;
    for(skt = 0; skt < app_prof->num_profile_skts; skt++) {
      bw += app_prof->intervals[i].profile_bw.skt[skt].current;
    }
    results[1][i]->geomean = bw / max_bw;
    
    /* Third, let's get the upper_current value */
    results[2][i] = calloc(1, sizeof(geo_result));
    results[2][i]->geomean = ((double) interval->profile_objmap.upper_current) / upper_max;
    
    /* Fourth, let's get the current hotset weight */
    results[3][i] = calloc(1, sizeof(geo_result));
    results[3][i]->geomean = (double) interval->profile_online.using_hotset_weight / (double) upper_max;
    printf("hotset_weight: %zu\n", interval->profile_online.using_hotset_weight);
  }
  printf("Total intervals: %zu\n", app_prof->num_intervals);
  
  char **curve_labels = (char *[]){"EE",
                                   "Bandwidth",
                                   "Node0 Packed",
                                   "Hotset Weight"};
  graph_multi_line("Hotset Effectiveness Estimate",
                   "Iteration", "Ratio Against Maximum",
                   0.0, 0.0,
                   app_prof->num_intervals, max_y_val,
                   NULL, app_prof->num_intervals,
                   curve_labels, 4,
                   results,
                   "hotset_effectiveness.png", output_eps);
  
cleanup:
  free(filepath);
  fclose(file);
}

/* Creates a graph with three lines, one for each configuration. One benchmark. 
   The x-axis is SICM phases, while the y-axis values are the runtime of the phase. */
void graph_sicm_year_review(char *bench_str, char *size_str, char **config_strs, size_t num_configs, char output_eps) {
  char *path, **x_axis_labels;
  size_t i, n, num_phases;
  DIR *dir;
  geo_result *tmp_result, ***results;
  double max_y_val;
  metric_opts *mopts;
  
  path = get_config_path(bench_str, size_str, config_strs[0]);
  tmp_result = malloc(sizeof(geo_result));
  get_geo_result(path, "num_phases", NULL, tmp_result);
  if(tmp_result->geomean < 3) {
    fprintf(stderr, "Didn't get enough phases. Aborting.\n");
    free(path);
    return;
  }
  num_phases = (size_t) round(tmp_result->geomean) - 2;
  free(path);
  
  if(!num_phases) {
    fprintf(stderr, "Can't generate graph because there are no phases. Aborting.\n");
    return;
  }
  
  /* This loop iterates over the configurations, and generates a two-dimensional array
     of `result` pointers. The first dimension is per-config, and the second is per-phase. */
  dir = NULL;
  results = calloc(num_configs, sizeof(geo_result **));
  mopts = malloc(sizeof(metric_opts));
  max_y_val = 0;
  for(i = 0; i < num_configs; i++) {
    results[i] = calloc(num_phases, sizeof(geo_result *));
    for(n = 0; n < num_phases; n++) {
      results[i][n] = malloc(sizeof(geo_result));
      path = get_config_path(bench_str, size_str, config_strs[i]);
      
      /* Get the phase time */
      mopts->index = n + 1;
      get_geo_result(path, "specific_phase_time", mopts, results[i][n]);
      
      /* Maintain the max */
      if(results[i][n]->geomean > max_y_val) {
        max_y_val = results[i][n]->geomean;
      }
      
      free(path);
    }
  }
  
  x_axis_labels = malloc(sizeof(char *) * num_phases);
  for(i = 0; i < num_phases; i++) {
    x_axis_labels[i] = malloc(sizeof(char) * 32);
    sprintf(x_axis_labels[i], "%d", i);
  }
  char **curve_labels = (char *[]){"Unguided",
                                   "Offline",
                                   "Online"};
  
  graph_multi_line("Execution Time of LULESH Iteration",
                   "Iteration Number", "Execution Time (s)",
                   0, 0,
                   num_phases, max_y_val,
                   x_axis_labels, num_phases,
                   curve_labels, num_configs,
                   results,
                   "sicm_year_review.png", output_eps);
                   
  for(i = 0; i < num_phases; i++) {
    free(x_axis_labels[i]);
  }
  free(x_axis_labels);
}
