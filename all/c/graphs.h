#pragma once
#include "stat.h"

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
    
    node_current = interval->profile_objmap.cgroup_node0_current +
                   interval->profile_objmap.cgroup_node1_current;
    if(node_current > node_max) {
      node_max = node_current;
    }
    
    if(interval->profile_objmap.total_heap_bytes > heap_max) {
      heap_max = interval->profile_objmap.total_heap_bytes;
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
    
    node_current = interval->profile_objmap.cgroup_node0_current +
                   interval->profile_objmap.cgroup_node1_current;
    results[0][i] = calloc(1, sizeof(geo_result));
    results[0][i]->geomean = ((double) node_current) / abs_max;
    
    results[1][i] = calloc(1, sizeof(geo_result));
    results[1][i]->geomean = ((double) interval->profile_objmap.total_heap_bytes) / abs_max;
    
    results[2][i] = calloc(1, sizeof(geo_result));
    results[2][i]->geomean = ((double) interval->profile_objmap.cgroup_memory_current) / abs_max;
  }
  
  char **curve_labels = (char *[]){"node0_current + node1_current", "objmap", "memory.current"};
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
  double y_val, max_y_val, bw, max_bw, node0_max;
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
  node0_max = (double) last_interval->profile_objmap.cgroup_node0_max;
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
    
    /* Third, let's get the node0_current value */
    results[2][i] = calloc(1, sizeof(geo_result));
    results[2][i]->geomean = ((double) interval->profile_objmap.cgroup_node0_current) / node0_max;
    
    /* Fourth, let's get the current hotset weight */
    results[3][i] = calloc(1, sizeof(geo_result));
    results[3][i]->geomean = (double) interval->profile_online.using_hotset_weight / (double) node0_max;
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

#if 0
void graph_hotset_diff(FILE *input_file, char *metric, char top100) {
  char *hotset_diff_table_name, *weight_ratio_table_name,
       *line, *args;

  /* First, use the parsing and packing libraries to gather the info */
  hotset_diff_table_name = generate_hotset_diff_table(input_file, top100, 0);
  weight_ratio_table_name = generate_weight_ratio_table(input_file, top100, 0);

  /* Call the graphing script wrapper */
  if(!graph_title) {
    /* Set a default title */
    graph_title = malloc(sizeof(char) * (strlen(DEFAULT_HOTSET_DIFF_TITLE) + 1));
    strcpy(graph_title, DEFAULT_HOTSET_DIFF_TITLE);
  }
  args = malloc(sizeof(char) *
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

void graph_heatmap(FILE *input_file, char *metric, char top100, int sort_arg) {
  char *heatmap_name, *weight_ratio_table_name,
       *args;

  /* Now use the profiling info to generate the input tables */
  heatmap_name = generate_heatmap_table(input_file, top100, sort_arg);
  weight_ratio_table_name = generate_weight_ratio_table(input_file, top100, sort_arg);

  /* Call the graphing script wrapper */
  if(!graph_title) {
    /* Set a default title */
    graph_title = malloc(sizeof(char) * (strlen(DEFAULT_HEATMAP_TITLE) + 1));
    strcpy(graph_title, DEFAULT_HEATMAP_TITLE);
  }
  args = malloc(sizeof(char) *
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

void graph_online_bandwidth(FILE *input_file, char *metric) {
  char *bandwidth_name,
       *reconfigure_name,
       *phase_change_name,
       *interval_time_name,
       *args;
       
  bandwidth_name = generate_bandwidth_table(input_file);
  reconfigure_name = generate_reconfigure_table(input_file);
  phase_change_name = generate_phase_change_table(input_file);
  interval_time_name = generate_interval_time_table(input_file);
  
  /* Construct the string of arguments to pass to the jgraph script */
  args = malloc(sizeof(char) *
                     (strlen(bandwidth_name) +
                      strlen(reconfigure_name) +
                      strlen(phase_change_name) +
                      strlen(interval_time_name) +
                      4)); /* Three spaces and one NULL */
  strcpy(args, bandwidth_name);
  strcat(args, " ");
  strcat(args, reconfigure_name);
  strcat(args, " ");
  strcat(args, phase_change_name);
  strcat(args, " ");
  strcat(args, interval_time_name);
  jgraph_wrapper(metric, args);
  
  free(args);
  free(bandwidth_name);
  free(reconfigure_name);
  free(phase_change_name);
}

void graph_online_hot_aep_acc(FILE *input_file, char *metric) {
  char *hot_aep_acc_name,
       *reconfigure_name,
       *phase_change_name,
       *interval_time_name,
       *args;
       
  hot_aep_acc_name = generate_hot_aep_acc_table(input_file);
  reconfigure_name = generate_reconfigure_table(input_file);
  phase_change_name = generate_phase_change_table(input_file);
  interval_time_name = generate_interval_time_table(input_file);
  
  /* Construct the string of arguments to pass to the jgraph script */
  args = malloc(sizeof(char) *
                     (strlen(hot_aep_acc_name) +
                      strlen(reconfigure_name) +
                      strlen(phase_change_name) +
                      strlen(interval_time_name) +
                      4)); /* Three spaces and one NULL */
  strcpy(args, hot_aep_acc_name);
  strcat(args, " ");
  strcat(args, reconfigure_name);
  strcat(args, " ");
  strcat(args, phase_change_name);
  strcat(args, " ");
  strcat(args, interval_time_name);
  printf("args: '%s'\n", args);
  jgraph_wrapper("graph_online_percentage", args);
  
  free(args);
  free(hot_aep_acc_name);
  free(reconfigure_name);
  free(phase_change_name);
}

void graph_online_aep_acc(FILE *input_file, char *metric) {
  char *aep_acc_name,
       *reconfigure_name,
       *phase_change_name,
       *interval_time_name,
       *args;
       
  aep_acc_name = generate_aep_acc_table(input_file);
  reconfigure_name = generate_reconfigure_table(input_file);
  phase_change_name = generate_phase_change_table(input_file);
  interval_time_name = generate_interval_time_table(input_file);
  
  /* Construct the string of arguments to pass to the jgraph script */
  args = malloc(sizeof(char) *
                     (strlen(aep_acc_name) +
                      strlen(reconfigure_name) +
                      strlen(phase_change_name) +
                      strlen(interval_time_name) +
                      4)); /* Three spaces and one NULL */
  strcpy(args, aep_acc_name);
  strcat(args, " ");
  strcat(args, reconfigure_name);
  strcat(args, " ");
  strcat(args, phase_change_name);
  strcat(args, " ");
  strcat(args, interval_time_name);
  printf("args: '%s'\n", args);
  jgraph_wrapper("graph_online_percentage", args);
  
  free(args);
  free(aep_acc_name);
  free(reconfigure_name);
  free(phase_change_name);
}

void graph_online_offhot_aep_acc(FILE *input_file, char *metric) {
  char *offhot_aep_acc_name,
       *reconfigure_name,
       *phase_change_name,
       *interval_time_name,
       *args;
       
  offhot_aep_acc_name = generate_offhot_aep_acc_table(input_file);
  reconfigure_name = generate_reconfigure_table(input_file);
  phase_change_name = generate_phase_change_table(input_file);
  interval_time_name = generate_interval_time_table(input_file);
  
  /* Construct the string of arguments to pass to the jgraph script */
  args = malloc(sizeof(char) *
                     (strlen(offhot_aep_acc_name) +
                      strlen(reconfigure_name) +
                      strlen(phase_change_name) +
                      strlen(interval_time_name) +
                      4)); /* Three spaces and one NULL */
  strcpy(args, offhot_aep_acc_name);
  strcat(args, " ");
  strcat(args, reconfigure_name);
  strcat(args, " ");
  strcat(args, phase_change_name);
  strcat(args, " ");
  strcat(args, interval_time_name);
  printf("args: '%s'\n", args);
  jgraph_wrapper("graph_online_percentage", args);
  
  free(args);
  free(offhot_aep_acc_name);
  free(reconfigure_name);
  free(phase_change_name);
}

void graph_online_dev_aep_acc(FILE *input_file, char *metric) {
  char *dev_aep_acc_name,
       *reconfigure_name,
       *phase_change_name,
       *interval_time_name,
       *args;
       
  dev_aep_acc_name = generate_dev_aep_acc_table(input_file);
  reconfigure_name = generate_reconfigure_table(input_file);
  phase_change_name = generate_phase_change_table(input_file);
  interval_time_name = generate_interval_time_table(input_file);
  
  /* Construct the string of arguments to pass to the jgraph script */
  args = malloc(sizeof(char) *
                     (strlen(dev_aep_acc_name) +
                      strlen(reconfigure_name) +
                      strlen(phase_change_name) +
                      strlen(interval_time_name) +
                      4)); /* Three spaces and one NULL */
  strcpy(args, dev_aep_acc_name);
  strcat(args, " ");
  strcat(args, reconfigure_name);
  strcat(args, " ");
  strcat(args, phase_change_name);
  strcat(args, " ");
  strcat(args, interval_time_name);
  jgraph_wrapper("graph_online_percentage", args);
  
  free(args);
  free(dev_aep_acc_name);
  free(reconfigure_name);
  free(phase_change_name);
}

void graph_online_site_aep_acc(FILE *input_file, char *metric, int site) {
  char *site_aep_acc_name,
       *reconfigure_name,
       *phase_change_name,
       *interval_time_name,
       *args;
       
  site_aep_acc_name = generate_site_aep_acc_table(input_file, site);
  reconfigure_name = generate_reconfigure_table(input_file);
  phase_change_name = generate_phase_change_table(input_file);
  interval_time_name = generate_interval_time_table(input_file);
  
  /* Construct the string of arguments to pass to the jgraph script */
  args = malloc(sizeof(char) *
                     (strlen(site_aep_acc_name) +
                      strlen(reconfigure_name) +
                      strlen(phase_change_name) +
                      strlen(interval_time_name) +
                      4)); /* Three spaces and one NULL */
  strcpy(args, site_aep_acc_name);
  strcat(args, " ");
  strcat(args, reconfigure_name);
  strcat(args, " ");
  strcat(args, phase_change_name);
  strcat(args, " ");
  strcat(args, interval_time_name);
  printf("args: '%s'\n", args);
  jgraph_wrapper("graph_online_percentage", args);
  
  free(args);
  free(site_aep_acc_name);
  free(reconfigure_name);
  free(phase_change_name);
}
#endif

#if 0
void graph_config_on_x_axis(char **bench_strs, size_t num_benches,
                            char **config_strs, size_t num_configs,
                            char **group_strs, size_t num_groups,
                            char **label_strs, size_t num_labels,
                            result ***results,
                            char *x_axis_title,
                            char *y_axis_title) {
  char *first_file_name, *args, **file_names;
  FILE *first_file_f, **file_fs;
  size_t max_x_value, max_y_value,
         bench, config, group, configs_per_group,
         str_size, i, label;
         
  if(!num_groups) {
    fprintf(stderr, "You didn't specify group names. Aborting.\n");
    exit(1);
  }
  
  /* We'll sum up the length of the argument string.
     Start at one, for the NULL character. */
  str_size = 1;
  
  /* The maximum value on the X-axis will just be the number of configurations in each group,
     minus one because we start at zero. */
  max_x_value = (num_configs / num_groups) - 1;
  
  /* The maximum value on the Y-axis will be the largest value in the results */
  max_y_value = 0;
  for(config = 0; config < num_configs; config++) {
    if(max_y_value < results[0][config]->geomean) {
      max_y_value = results[0][config]->geomean;
    }
  }
  
  /* Create the first file, which includes information about
     the graph as a whole: labels and maximum values. */
  open_tmp_file(&first_file_name, &first_file_f);
  if(graph_title) {
    fprintf(first_file_f, "%s", graph_title);
  }
  fprintf(first_file_f, "\n");
  if(x_axis_title) {
    fprintf(first_file_f, "%s", x_axis_title);
  }
  fprintf(first_file_f, "\n");
  if(y_axis_title) {
    fprintf(first_file_f, "%s", y_axis_title);
  }
  fprintf(first_file_f, "\n");
  fprintf(first_file_f, "%zu\n", max_x_value);
  fprintf(first_file_f, "%zu\n", max_y_value);
  for(label = 0; label < num_labels; label++) {
    fprintf(first_file_f, "%s\n", label_strs[label]);
  }
  fclose(first_file_f);
  str_size += strlen(first_file_name);
  
  /* Create the subsequent files that include the points for
     each of the curves */
  file_names = calloc(num_groups, sizeof(char *));
  file_fs = calloc(num_groups, sizeof(FILE *));
  configs_per_group = num_configs / num_groups; /* stat.c ensures that this will divide evenly */
  str_size = 0;
  printf("There are %zu groups, and %zu configs per group.\n", num_groups, configs_per_group);
  for(group = 0; group < num_groups; group++) {
    open_tmp_file(&(file_names[group]), &(file_fs[group]));
    str_size += strlen(file_names[group]) + 1; /* The filename and a space */
    fprintf(file_fs[group], group_strs[group]);
    fprintf(file_fs[group], "\n");
    i = 0;
    for(config = group * configs_per_group; config < ((group * configs_per_group) + configs_per_group); config++) {
      fprintf(file_fs[group], "%zu %f\n", i, results[0][config]->geomean);
      i++;
    }
    fclose(file_fs[group]);
  }
  
  args = malloc(sizeof(char) * str_size);
  strcpy(args, first_file_name);
  for(group = 0; group < num_groups; group++) {
    strcat(args, " ");
    strcat(args, file_names[group]);
  }
  printf("ARGS: '%s'\n", args);
  jgraph_wrapper("graph_multi_line", args);

  orig_free(first_file_name);
  orig_free(args);
}
#endif
