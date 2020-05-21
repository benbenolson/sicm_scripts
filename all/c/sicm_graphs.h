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
  args = orig_malloc(sizeof(char) *
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
  args = orig_malloc(sizeof(char) *
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
  args = orig_malloc(sizeof(char) *
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
  args = orig_malloc(sizeof(char) *
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
  args = orig_malloc(sizeof(char) *
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
  args = orig_malloc(sizeof(char) *
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
