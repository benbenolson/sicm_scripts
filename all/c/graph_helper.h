#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <limits.h>
#include "table_helper.h"

/* Takes a metric (graphing script name) as input, runs `jgraph` on it and generates a PNG of the graph */
void jgraph_wrapper(char *metric_str, char *args, char *output_filename, char output_eps) {
  char *command, *line;
  size_t nread, line_length;
  FILE *output;
  
  /* Call the jgraph script */
  command = malloc(sizeof(char) * 400);
  if(output_filename) {
    if(output_eps) {
      snprintf(command, 400,
        "${SCRIPTS_DIR}/all/bash/%s.sh %s | ${SCRIPTS_DIR}/tools/jgraph/jgraph > %s",
        metric_str, args, output_filename);
    } else {
      snprintf(command, 400,
        "${SCRIPTS_DIR}/all/bash/%s.sh %s | ${SCRIPTS_DIR}/tools/jgraph/jgraph | gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=png16m -dEPSCrop -r500 -dGraphicsAlphaBits=1 -dTextAlphaBits=4 -sOutputFile=%s -",
        metric_str, args, output_filename);
    }
  } else {
    if(output_eps) {
      snprintf(command, 400,
        "${SCRIPTS_DIR}/all/bash/%s.sh %s | ${SCRIPTS_DIR}/tools/jgraph/jgraph > %s",
        metric_str, args, "test.eps");
    } else {
      snprintf(command, 400,
        "${SCRIPTS_DIR}/all/bash/%s.sh %s | ${SCRIPTS_DIR}/tools/jgraph/jgraph | gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=png16m -dEPSCrop -r500 -dGraphicsAlphaBits=1 -dTextAlphaBits=4 -sOutputFile=%s -",
        metric_str, args, "test.png");
    }
  }
  output = popen(command, "r");
  if(!output) {
    fprintf(stderr, "Failed to launch the shell subprocess. Aborting.\n");
    exit(1);
  }
  line = malloc(sizeof(char) * 300);
  line_length = 300;
  while(nread = fread(line, 1, line_length, output)) {
    fwrite(line, 1, nread, stdout);
    fflush(stdout);
  }
  if(!(pclose(output) == 0)) {
    fprintf(stderr, "The command returned an error. Aborting.\n");
    exit(1);
  }
}

/* Takes arguments that describe a multi-line graph, and uses the graph_multi_line.sh jgraph script
   to make the graph. */
void graph_multi_line(char *graph_title,
                      char *x_axis_title, char *y_axis_title,
                      double min_x_val, double min_y_val,
                      double max_x_val, double max_y_val,
                      char **x_axis_strs, size_t num_x_axis_strs,
                      char **curve_strs, size_t num_curves,
                      geo_result ***results, /* First dimension is per-curve, second dimension is per-point */
                      char *output_filename, char output_eps) {
  char *first_file_name, *args, **file_names;
  FILE *first_file_f, **file_fs;
  size_t str_size, i, n;
         
  /* We'll sum up the length of the argument string.
     Start at one, for the NULL character. */
  str_size = 1;
  
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
  fprintf(first_file_f, "%lf\n", min_x_val);
  fprintf(first_file_f, "%lf\n", min_y_val);
  fprintf(first_file_f, "%lf\n", max_x_val);
  fprintf(first_file_f, "%lf\n", max_y_val);
  for(i = 0; i < num_x_axis_strs; i++) {
    if(x_axis_strs) {
      fprintf(first_file_f, "%s\n", x_axis_strs[i]);
    }
  }
  fclose(first_file_f);
  str_size += strlen(first_file_name);
  
  /* Create the subsequent files that include the points for
     each of the curves */
  file_names = calloc(num_curves, sizeof(char *));
  file_fs = calloc(num_curves, sizeof(FILE *));
  for(i = 0; i < num_curves; i++) {
    open_tmp_file(&(file_names[i]), &(file_fs[i]));
    str_size += strlen(file_names[i]) + 1; /* The filename and a space */
    if(curve_strs) {
      fprintf(file_fs[i], curve_strs[i]);
    }
    fprintf(file_fs[i], "\n");
    for(n = 0; n < num_x_axis_strs; n++) {
      fprintf(file_fs[i], "%zu %f\n", n, results[i][n]->geomean);
    }
    fclose(file_fs[i]);
  }
  
  args = malloc(sizeof(char) * str_size);
  strcpy(args, first_file_name);
  for(i = 0; i < num_curves; i++) {
    strcat(args, " ");
    strcat(args, file_names[i]);
  }
  printf("ARGS: '%s'\n", args);
  jgraph_wrapper("graph_multi_line", args, output_filename, output_eps);

  free(first_file_name);
  free(file_fs);
  free(args);
}
