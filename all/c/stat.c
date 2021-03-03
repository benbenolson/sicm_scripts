#include <getopt.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include "stat.h"
#include "parse_gnu_time.h"
#include "parse_bench.h"
#include "parse_sicm.h"
#include "graph_helper.h"
#include "graphs.h"

#if 0
#include "parse_numastat.h"
#include "parse_pcm_memory.h"
#include "parse_memreserve.h"
#endif

/* The parsers call this function to register themselves to handle a list of metrics*/
void register_parser(char **metrics, get_metric_t get_metric_func) {
  int i;
  
  if(parser_num == PARSER_MAX) {
    fprintf(stderr, "Reached the maximum number of parsers. Aborting.\n");
    exit(1);
  }
  
  parser_arr[parser_num] = malloc(sizeof(parser));
  parser_arr[parser_num]->metrics = metrics;
  parser_arr[parser_num]->get_metric_func = get_metric_func;
  
  i = 0;
  while(metrics[i]) {
    i++;
  }
  
  parser_num++;
}

void register_metrics() {
  register_gnu_time_metrics();
  register_bench_metrics();
  register_sicm_metrics();
#if 0
  register_numastat_metrics();
  register_pcm_memory_metrics();
  register_memreserve_metrics();
#endif
}

void unregister_metrics() {
  int i;
  
  for(i = 0; i < parser_num; i++) {
    if(!(parser_arr[i])) {
      break;
    }
    free(parser_arr[i]);
  }
}

/* Iterates over the metrics and tells you which index matches the metric string */
int metric_index(char *metric, char **metrics) {
  int i;
  
  i = 0;
  while(metrics[i]) {
    if(strcmp(metric, metrics[i]) == 0) {
      return i;
    }
    i++;
  }
  
  return -1;
}

char *get_config_path(char *bench_str, char *size_str, char *config_str) {
  char *path, *results_dir;
  
  results_dir = getenv("RESULTS_DIR");
  if(!results_dir) {
    fprintf(stderr, "Failed to get RESULTS_DIR environment variable. Aborting.\n");
    exit(1);
  }
  
  /* Constructs a results path */
  path = malloc(sizeof(char) *
                (strlen(results_dir) +
                strlen(bench_str) +
                strlen(size_str) +
                strlen(config_str) +
                4)); /* Three slashes and a NULL terminator */
                
  sprintf(path, "%s/%s/%s/%s", results_dir, bench_str, size_str, config_str);
  return path;
}

/* This function returns a `result` struct */
void get_geo_result(char *path, char *metric_str, metric_opts *mopts, geo_result *result) {
  double geomean, diff;
  size_t num_iters, i;
  int iter;
  char *iterpath;
  DIR *dir;
  double *arr, d;
  struct dirent *de;
  metric_opts *orig_mopts;
  
  if(!result) {
    fprintf(stderr, "Result wasn't allocated. Aborting.\n");
    exit(1);
  }
  
  orig_mopts = mopts;
  if(!mopts) {
    mopts = malloc(sizeof(metric_opts));
    mopts->node = 0;
    mopts->site = 0;
    mopts->index = 0;
    mopts->output_filename = NULL;
  }
  
  dir = opendir(path);
  if(!dir) {
    fprintf(stderr, "Unable to open directory: '%s'. Filling with zeroes.\n", path);
    result->geomean = 0.0;
    result->variance = 0.0;
    result->rel_geomean = 0.0;
    result->rel_variance = 0.0;
    return;
  }
  
  /* Iterate over the directories (each of which is an iteration), get the result for
     that iteration, and add it to the array */
  result->geomean = 0.0;
  result->variance = 0.0;
  num_iters = 0;
  arr = NULL;
  while ((de = readdir(dir)) != NULL) {
    if(sscanf(de->d_name, "i%d", &iter) == 1) {
      iterpath = malloc(sizeof(char) * (strlen(path) + strlen(de->d_name) + 2));
      sprintf(iterpath, "%s/%s", path, de->d_name);
      d = parse_iteration(metric_str, iterpath, mopts);
      
      /* Store this result in the array (so that we can calculate variance) */
      num_iters++;
      arr = realloc(arr, sizeof(double) * num_iters);
      arr[num_iters - 1] = d;
      
      /* Add up the values in the `geomean` variable */
      if(d) {
        result->geomean += log(d);
      }
      
      free(iterpath);
    }
  }
  
  /* Calculate the geomean and variance across those iterations */
  if(!num_iters) {
    fprintf(stderr, "WARNING: Failed to find any iterations in '%s'.\n", path);
    result->geomean = 0.0;
    result->variance = 0.0;
  } else if(num_iters == 1) {
    result->geomean = d;
    result->variance = 0;
  } else {
    result->geomean /= num_iters;
    result->geomean = exp(result->geomean);
    for(i = 0; i < num_iters; i++) {
      d = arr[i];
      diff = abs(result->geomean - d);
      if(diff > result->variance) {
        result->variance = diff;
      }
    }
  }
  
  if(num_iters) {
    free(arr);
  }
  if(!orig_mopts) {
    free(mopts);
  }
}

char *construct_path(char *path, char *filename) {
  size_t pathsize, filenamesize;
  char *fullpath;

  pathsize = strlen(path);
  filenamesize = strlen(filename);

  if(path[pathsize - 1] == '/') {
    fullpath = calloc(pathsize + filenamesize + 1, sizeof(char));
    strcat(fullpath, path);
    strcat(fullpath, filename);
  } else {
    fullpath = calloc(pathsize + filenamesize + 2, sizeof(char));
    strcat(fullpath, path);
    fullpath[pathsize] = '/';
    fullpath[pathsize + 1] = '\0';
    strcat(fullpath, filename);
  }

  return fullpath;
}

double parse_iteration(char *metric_str, char *iterpath, metric_opts *mopts) {
  double d;
  int i, n;
  parser *p;
  
  /* Hop down the list of parsers */
  d = 0.0;
  for(i = 0; i < parser_num; i++) {
    p = parser_arr[i];
    if(!p) {
      break;
    }
    
    /* Check if this parser can fulfill our needs ;`) */
    n = 0;
    while(p->metrics[n]) {
      if(strcmp(metric_str, p->metrics[n]) == 0) {
        d = (p->get_metric_func)(metric_str, iterpath, mopts);
        break;
      }
      n++;
    }
  }

  return d;
}
/* USAGE: ./stat --metric=X --config=Y [--node=X] */

/* We use the environment variable RESULTS_DIR to
   figure out where to look for results. */

static struct option long_options[] = {
  {"bench",       required_argument, 0, 'b'},
  {"config",      required_argument, 0, 'c'},
  {"hconfig",     required_argument, 0, 'h'},
  {"size",        required_argument, 0, 'i'},
  {"groupsize",   required_argument, 0, 'g'},
  {"groupname",   required_argument, 0, 'u'},
  {"label",       required_argument, 0, 'l'},
  {"metric",      required_argument, 0, 'm'},
  {"node",        required_argument, 0, 'n'},
  {"site",        required_argument, 0, 's'},
  {"filename",    required_argument, 0, 'o'},
  {"x_label",     required_argument, 0, 'x'},
  {"y_label",     required_argument, 0, 'y'},
  {"eps",         no_argument,       0, 'e'},
  {"single",      required_argument, 0, 'q'},
  {"relative",    no_argument,       0, 'r'},
  {"debug",       no_argument,       0, 'd'},
  {0,             0,                 0, 0}
};

char check_args(char *metric_str, char *size_str, size_t num_configs, char **config_strs, size_t num_human_configs, char **bench_strs) {
  if(num_human_configs && (num_configs != num_human_configs)) {
    fprintf(stderr, "Spcified human config names, but not the same number as configs. Aborting.\n");
    exit(1);
  }
  if(!metric_str) {
    fprintf(stderr, "No metric given. Aborting.\n");
    exit(1);
  }
  if(!size_str) {
    fprintf(stderr, "No size given. Aborting.\n");
    exit(1);
  }
  if(!config_strs) {
    fprintf(stderr, "No configs given. Aborting.\n");
    exit(1);
  }
  if(!bench_strs) {
    fprintf(stderr, "No benches given. Aborting.\n");
    exit(1);
  }
  if(!getenv("RESULTS_DIR")) {
    fprintf(stderr, "Please set RESULTS_DIR environment variable.\n");
    exit(1);
  }
}

int main(int argc, char **argv) {
  int option_index, arg, iter, num_iters;
  char c, *metric_str, *iterpath, *path, *size_str, relative,
       print_table, output_eps;
  double geomean;
  char *single_path, debug;
  DIR *dir;
  metric_opts *mopts;
  
  /* Array of configuration and benchmark strings */
  char **config_strs,
       **bench_strs,
       **group_strs,
       **label_strs,
       *x_label,
       *y_label,
       **human_config_strs;
  size_t num_configs, num_human_configs, config, max_config_len,
         num_benches, bench,
         num_groups, group,
         num_labels, label,
         groupsize;
  ssize_t max_column_len, column_len;
  
  /* Array of per-bench, per-config result pointers */
  geo_result ***results, *result;
  /* Same as above, but the strings of what we're going to print in the table */
  char ***result_strs;
  
  /* Handle options and arguments */
  mopts = malloc(sizeof(metric_opts));
  metric_str = NULL;
  size_str = NULL;
  num_configs = 0;
  num_human_configs = 0;
  config_strs = NULL;
  human_config_strs = NULL;
  num_benches = 0;
  bench_strs = NULL;
  num_groups = 0;
  group_strs = NULL;
  num_labels = 0;
  label_strs = NULL;
  x_label = NULL;
  y_label = NULL;
  groupsize = 0;
  single_path = NULL;
  relative = 0;
  debug = 0;
  print_table = 1;
  output_eps = 0;
  while(1) {
    option_index = 0;
    c = getopt_long(argc, argv, "m:n:s:t:eo:c:h:b:gz:l:x:y:i:",
                    long_options, &option_index);
    if(c == -1) {
      break;
    }

    switch(c) {
      case 0:
        printf("option %s\n", long_options[option_index].name);
        break;
      case 'd':
        debug = 1;
        break;
      case 'x':
        x_label = (char *) malloc(sizeof(char) * (strlen(optarg) + 1));
        strcpy(x_label, optarg);
        printf("X LABEL: %s\n", x_label);
        break;
      case 'y':
        y_label = (char *) malloc(sizeof(char) * (strlen(optarg) + 1));
        strcpy(y_label, optarg);
        break;
      case 'c':
        /* Configuration name. At least one required. */
        num_configs++;
        config_strs = (char **) realloc(config_strs, sizeof(char *) * num_configs);
        config_strs[num_configs - 1] = malloc(sizeof(char) * (strlen(optarg) + 1));
        strcpy(config_strs[num_configs - 1], optarg);
        break;
      case 'h':
        /* Human-readable configuration name. At least one required. */
        num_human_configs++;
        human_config_strs = (char **) realloc(human_config_strs, sizeof(char *) * num_human_configs);
        human_config_strs[num_human_configs - 1] = malloc(sizeof(char) * (strlen(optarg) + 1));
        strcpy(human_config_strs[num_human_configs - 1], optarg);
        break;
      case 'g':
        groupsize = (size_t) strtoul(optarg, NULL, 0);
        break;
      case 'u':
        /* Configuration group name. None are required, but are used for graphs. */
        num_groups++;
        group_strs = (char **) realloc(group_strs, sizeof(char *) * num_groups);
        group_strs[num_groups - 1] = malloc(sizeof(char) * (strlen(optarg) + 1));
        strcpy(group_strs[num_groups - 1], optarg);
        printf("%s\n", optarg);
        printf("%zu %s\n", num_groups, group_strs[num_groups - 1]);
        break;
      case 'l':
        /* Label name. None are required, but are used for graphs. */
        num_labels++;
        label_strs = (char **) realloc(label_strs, sizeof(char *) * num_labels);
        label_strs[num_labels - 1] = malloc(sizeof(char) * (strlen(optarg) + 1));
        strcpy(label_strs[num_labels - 1], optarg);
        printf("%s\n", optarg);
        printf("%zu %s\n", num_labels, label_strs[num_labels - 1]);
        break;
      case 'q':
        /* Singleton mode. Only first config and first bench used. Single value prints out instead of a table. */
        single_path = malloc(sizeof(char) * (strlen(optarg) + 1));
        strcpy(single_path, optarg);
        break;
      case 'b':
        /* Benchmark name. At least one required. */
        num_benches++;
        bench_strs = (char **) realloc(bench_strs, sizeof(char *) * num_benches);
        bench_strs[num_benches - 1] = malloc(sizeof(char) * (strlen(optarg) + 1));
        strcpy(bench_strs[num_benches - 1], optarg);
        break;
      case 'm':
        /* Metric name. Required. */
        metric_str = (char *) malloc(sizeof(char) * (strlen(optarg) + 1));
        strcpy(metric_str, optarg);
        break;
      case 'i':
        /* Size name. Required. */
        size_str = (char *) malloc(sizeof(char) * (strlen(optarg) + 1));
        strcpy(size_str, optarg);
        break;
      case 'n':
        /* A NUMA node ID. */
        mopts->node = strtoul(optarg, NULL, 0);
        /* Necessary because strtoul returns 0 on failure,
         * which could be the node number the user passed in.
         */
        if(((mopts->node == 0) && (strcmp(optarg, "0") != 0)) && (mopts->node < 0)) {
          fprintf(stderr, "Invalid node number: '%s'. Aborting.\n", optarg);
          exit(1);
        }
        break;
      case 's':
        /* A site ID. Integer. */
        mopts->site = strtoul(optarg, NULL, 0);
        if(mopts->site <= 0) {
          fprintf(stderr, "Invalid site number: '%d'. Aborting.\n", optarg);
          exit(1);
        }
        break;
      case 'o':
        /* This is an output filename that can be used to output a PNG or table to. */
        mopts->output_filename = (char *) malloc(sizeof(char) * (strlen(optarg) + 1));
        strcpy(mopts->output_filename, optarg);
        break;
      case 'e':
        /* If this is specified, we're going to output to an EPS. */
        output_eps = 1;
        break;
      case 'r':
        relative = 1;
        break;
      case '?':
        exit(1);
      default:
        exit(1);
    }
  }
  
  /* Set up the parsers */
  register_metrics();
  
  if(single_path) {
    if(!metric_str) {
      fprintf(stderr, "No metric given. Aborting.\n");
      exit(1);
    }
    result = malloc(sizeof(geo_result));
    get_geo_result(single_path, metric_str, mopts, result);
    printf("%lf", result->geomean);
    free(result);
    goto cleanup;
  }
  
  check_args(metric_str, size_str, num_configs, config_strs, num_human_configs, bench_strs);
  if(groupsize && num_groups) {
    if((num_configs % groupsize != 0) || ((num_configs / groupsize != num_groups))) {
      fprintf(stderr, "The number of group names that you've specified doesn't align with the number of groups. Aborting.\n");
      exit(1);
    }
  }
  
  if(strncmp(metric_str, "graph_", 6) == 0) {
    print_table = 0;
  }
  
  if(print_table) {
    /* This loop iterates over the configs, gets a `metric` struct per config per bench */
    results = calloc(num_benches, sizeof(geo_result **));
    result_strs = calloc(num_benches, sizeof(char **));
    for(bench = 0; bench < num_benches; bench++) {
      results[bench] = calloc(num_configs, sizeof(geo_result *));
      result_strs[bench] = calloc(num_configs, sizeof(char *));
      for(config = 0; config < num_configs; config++) {
        if(debug) {
          printf("Parsing '%s', '%s'\n", bench_strs[bench], config_strs[config]);
        }
        
        /* Get the result */
        results[bench][config] = malloc(sizeof(geo_result));
        path = get_config_path(bench_strs[bench], size_str, config_strs[config]);
        get_geo_result(path, metric_str, mopts, results[bench][config]);
        
        /* Now handle the `relative` flag */
        if(relative && (results[bench][0]->geomean != 0.0)) {
          results[bench][config]->rel_geomean = results[bench][config]->geomean / results[bench][0]->geomean;
          results[bench][config]->rel_variance = results[bench][config]->variance / results[bench][0]->geomean;
        }
        
        /* Here, we'll store the string of the result (including variance) in `result_strs`. We first figure
          out how long the string is going to be, then allocate enough room, then finally write the result
          into `result_strs[bench][config]`. */
        if(relative) {
          column_len = snprintf(NULL, 0, "%.3f ± %.3f", results[bench][config]->rel_geomean, results[bench][config]->rel_variance);
          result_strs[bench][config] = malloc(sizeof(char) * column_len);
          snprintf(result_strs[bench][config], column_len, "%.3f ± %.3f", results[bench][config]->rel_geomean, results[bench][config]->rel_variance);
        } else {
          column_len = snprintf(NULL, 0, "%.3f ± %.3f", results[bench][config]->geomean, results[bench][config]->variance);
          result_strs[bench][config] = malloc(sizeof(char) * column_len);
          snprintf(result_strs[bench][config], column_len, "%.3f ± %.3f", results[bench][config]->geomean, results[bench][config]->variance);
        }
        free(path);
      }
    }
  
    /* The first column should be the width of the longest config name. */
    max_config_len = 0;
    for(config = 0; config < num_configs; config++) {
      if(strlen(config_strs[config]) > max_config_len) {
        max_config_len = strlen(config_strs[config]);
      }
    }
    max_config_len += 2;
    
    /* Subsequent columns should be as wide as the longest result or benchmark name. */
    max_column_len = 0;
    for(config = 0; config < num_configs; config++) {
      for(bench = 0; bench < num_benches; bench++) {
        column_len = strlen(result_strs[bench][config]);
        if(column_len > max_column_len) {
          max_column_len = column_len;
        }
      }
    }
    for(bench = 0; bench < num_benches; bench++) {
      column_len = strlen(bench_strs[bench]);
      if(column_len > max_column_len) {
        max_column_len = column_len;
      }
    }
    max_column_len += 2;
    
    /* Print the table of results */
    printf("%-*s", max_config_len, " ");
    for(bench = 0; bench < num_benches; bench++) {
      printf("%-*s", max_column_len, bench_strs[bench]);
    }
    printf("\n");
    for(config = 0; config < num_configs; config++) {
      printf("%-*s", max_config_len, config_strs[config]);
      for(bench = 0; bench < num_benches; bench++) {
        printf("%-*s", max_column_len, result_strs[bench][config]);
      }
      printf("\n");
      if(groupsize && ((config + 1) % groupsize == 0)) {
        printf("\n");
      }
    }
  } else {
    /* It's a graph metric */
    if(strcmp(metric_str, "graph_sicm_year_review") == 0) {
      graph_sicm_year_review(bench_strs[0], size_str, config_strs, num_configs, output_eps);
    } else if(strcmp(metric_str, "graph_hotset_line") == 0) {
      graph_hotset_line(bench_strs[0], size_str, config_strs[0], output_eps);
    } else if(strcmp(metric_str, "graph_capacity_lines") == 0) {
      graph_capacity_lines(bench_strs[0], size_str, config_strs[0], output_eps);
    } else if(strncmp(metric_str, "graph_clustered_bars_", 21) == 0) {
      /* For this graph, the last part of the `metric_str` is the metric we want to use as values in the graph */
      graph_clustered_bars(num_benches, bench_strs, num_configs, config_strs, human_config_strs, size_str, (metric_str + 21));
    } else {
      fprintf(stderr, "Graph metric name not recognized. Aborting.\n");
      goto cleanup;
    }
  }
  
#if 0
  /* Now, if we're doing a multi-config graph of some kind, let's output that */
  if((strcmp(metric_str, "graph_runtime") == 0) ||
     (strcmp(metric_str, "graph_first_phase_time") == 0) ||
     (strcmp(metric_str, "graph_max_phase_time") == 0) ||
     (strcmp(metric_str, "graph_min_phase_time") == 0) ||
     (strcmp(metric_str, "graph_last_phase_time") == 0)) {
    graph_metric_memreserve(bench_strs, num_benches, config_strs, num_configs, group_strs, num_groups, label_strs, num_labels, results, x_label, y_label);
  }
#endif
  
  /* Clean up */
  cleanup:
  unregister_metrics();
  free(metric_str);
  free(config_strs);
  free(bench_strs);
  free(mopts);
  return 0;
}
