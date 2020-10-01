#include "stat.h"

void graph_metric_memreserve(char **bench_strs, size_t num_benches,
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
  
  /* Create the first file */
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
  
  args = orig_malloc(sizeof(char) *
                     str_size);
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
