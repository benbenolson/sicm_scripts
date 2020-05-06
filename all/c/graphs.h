void graph_metric_memreserve(char **bench_strs, size_t num_benches,
                             char **config_strs, size_t num_configs,
                             char **group_strs, size_t num_groups,
                             double **results,
                             char *x_axis_title,
                             char *y_axis_title) {
  char *first_file_name, *args, **file_names;
  FILE *first_file_f, **file_fs;
  size_t max_x_value, max_y_value,
         bench, config, group;
         
  if(!num_groups) {
    fprintf(stderr, "You didn't specify group names. Aborting.\n");
    exit(1);
  }
  
  /* The maximum value on the X-axis will just be the number of configurations in each group. */
  max_x_value = num_configs / num_groups;
  
  /* The maximum value on the Y-axis will be the largest value in the results */
  max_y_value = 0;
  for(config = 0; config < num_configs; config++) {
    if(max_y_value < results[0][config]) {
      max_y_value = results[0][config];
    }
  }
  
  /* Create the first file */
  open_tmp_file(&first_file_name, &first_file_f);
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
  fclose(first_file_f);
  
  file_names = calloc(num_groups, sizeof(char *));
  file_fs = calloc(num_groups, sizeof(FILE *));
  for(group = 0; group < num_groups; group++) {
    open_tmp_file(&(file_names[group]), &(file_fs[group]));
    
  }
  
  args = orig_malloc(sizeof(char) *
                     (strlen(first_file_name) +
                     1));
  strcpy(args, first_file_name);
  printf("ARGS: '%s'\n", args);
  jgraph_wrapper("graph_multi_line", args);

  free(first_file_name);
  free(args);
}
