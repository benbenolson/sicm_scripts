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
