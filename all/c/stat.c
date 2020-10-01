#include <getopt.h>
#include <string.h>
#include <ctype.h>
#include <dirent.h>
#include "stat.h"

/* USAGE: ./stat --metric=X --config=Y [--node=X] */

/* We use the environment variable RESULTS_DIR to
   figure out where to look for results. */

static struct option long_options[] = {
  {"bench",       required_argument, 0, 'b'},
  {"config",      required_argument, 0, 'c'},
  {"size",        required_argument, 0, 'i'},
  {"groupsize",   required_argument, 0, 'g'},
  {"groupname",   required_argument, 0, 'u'},
  {"label",       required_argument, 0, 'l'},
  {"metric",      required_argument, 0, 'm'},
  {"node",        required_argument, 0, 'n'},
  {"site",        required_argument, 0, 's'},
  {"graph_title", required_argument, 0, 't'},
  {"filename",    required_argument, 0, 'o'},
  {"x_label",     required_argument, 0, 'x'},
  {"y_label",     required_argument, 0, 'y'},
  {"eps",         no_argument,       0, 'e'},
  {"single",      required_argument, 0, 'q'},
  {"relative",    no_argument,       0, 'r'},
  {"debug",       no_argument,       0, 'd'},
  {0,             0,                 0, 0}
};

/* This function returns a `result` struct */
result *get_geomean_result(DIR *dir, char *path, char *metric_str, unsigned long node, int site) {
  double geomean, diff;
  size_t num_iters, i;
  int iter;
  char *iterpath;
  metric *m;
  metrics *info;
  metric **m_arr;
  result *res;
  
  /* Used for detecting iteration directories */
  struct dirent *de;
  
  /* We're going to take the geomean across iterations */
  res = malloc(sizeof(result));
  res->geomean = 0.0;
  res->variance = 0.0;
  num_iters = 0;
  m_arr = NULL;
  while ((de = readdir(dir)) != NULL) {
    if(sscanf(de->d_name, "i%d", &iter) == 1) {
      iterpath = malloc(sizeof(char) * (strlen(path) + strlen(de->d_name) + 2));
      sprintf(iterpath, "%s/%s", path, de->d_name);
      info = init_metrics();
      m = parse_metrics(info, iterpath, metric_str, node, site);
      if(!m) {
        break;
      }
      
      /* Store this result in the array (so that we can calculate variance) */
      num_iters++;
      m_arr = realloc(m_arr, sizeof(metric *) * num_iters);
      m_arr[num_iters - 1] = m;
      
      /* Add up the values in the `geomean` variable */
      if(m->type == 0) {
        res->geomean += log(m->val.f);
      } else if(m->type == 1) {
        res->geomean += log(m->val.s);
      }
      
      free_metrics(info);
      free(iterpath);
    }
  }
  if(!num_iters) {
    fprintf(stderr, "WARNING: Failed to find any iterations in '%s'.\n", path);
    res->geomean = 0.0;
    res->variance = 0.0;
  } else {
    res->geomean /= num_iters;
    res->geomean = exp(res->geomean);
    for(i = 0; i < num_iters; i++) {
      m = m_arr[i];
      if(m->type == 0) {
        diff = abs(res->geomean - m->val.f);
      } else if(m->type == 1) {
        diff = abs(res->geomean - m->val.s);
      }
      if(diff > res->variance) {
        res->variance = diff;
      }
      free(m_arr[i]);
    }
  }
  free(m_arr);
  
  return res;
}

char check_args(char *metric_str, char *size_str, char **config_strs, char **bench_strs) {
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
}

int main(int argc, char **argv) {
  int option_index, site, arg, iter, num_iters;
  char *metric_str, c, *iterpath, *path, *size_str, relative;
  unsigned long node;
  metric *m;
  double geomean;
  char *single_path, debug;
  DIR *dir;
  metrics *info;
  
  /* Array of configuration and benchmark strings */
  char **config_strs, **bench_strs, **group_strs, **label_strs, *x_label, *y_label;
  size_t num_configs, config, max_config_len,
         num_benches, bench,
         num_groups, group,
         num_labels, label,
         groupsize;
  ssize_t max_column_len, column_len;
  
  /* Array of per-bench, per-config result pointers */
  result ***results;
  /* Same as above, but the strings of what we're going to print in the table */
  char ***result_strs;
  
  /* Handle options and arguments */
  node = UINT_MAX;
  metric_str = NULL;
  size_str = NULL;
  num_configs = 0;
  config_strs = NULL;
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
  while(1) {
    option_index = 0;
    c = getopt_long(argc, argv, "m:n:s:t:eo:c:b:gz:l:x:y:i:",
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
        node = strtoul(optarg, NULL, 0);
        /* Necessary because strtoul returns 0 on failure,
         * which could be the node number the user passed in.
         */
        if(((node == 0) && (strcmp(optarg, "0") != 0)) && (node < 0)) {
          fprintf(stderr, "Invalid node number: '%s'. Aborting.\n", optarg);
          exit(1);
        }
        break;
      case 's':
        /* A site ID. Integer. */
        site = strtoul(optarg, NULL, 0);
        if(site <= 0) {
          fprintf(stderr, "Invalid site number: '%d'. Aborting.\n", optarg);
          exit(1);
        }
        break;
      case 't':
        /* Title of the output graph. We'll store this in the global in `stat.h`. */
        graph_title = (char *) malloc(sizeof(char) * (strlen(optarg) + 1));
        strcpy(graph_title, optarg);
        break;
      case 'o':
        /* This is an output filename that can be used to output a PNG or table to. */
        output_filename = (char *) malloc(sizeof(char) * (strlen(optarg) + 1));
        strcpy(output_filename, optarg);
        break;
      case 'e':
        /* If this is specified, we're going to output to an EPS. */
        output_filetype = 1;
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
  
  if(single_path) {
    if(!metric_str) {
      fprintf(stderr, "No metric given. Aborting.\n");
      exit(1);
    }
    num_iters = 0;
    info = init_metrics();
    m = parse_metrics(info, single_path, metric_str, node, site);
    if(m->type == 0) {
      printf("%f", m->val.f);
    } else if(m->type == 1) {
      printf("%zu", m->val.s);
    }
    free_metrics(info);
    free(m);
    goto cleanup;
  }
  
  check_args(metric_str, size_str, config_strs, bench_strs);
  if(groupsize && num_groups) {
    if((num_configs % groupsize != 0) || ((num_configs / groupsize != num_groups))) {
      fprintf(stderr, "The number of group names that you've specified doesn't align with the number of groups. Aborting.\n");
      exit(1);
    }
  }
  
  /* This loop iterates over the configs, gets a `metric` struct per config */
  results = calloc(num_benches, sizeof(result **));
  result_strs = calloc(num_benches, sizeof(char **));
  for(bench = 0; bench < num_benches; bench++) {
    results[bench] = calloc(num_configs, sizeof(result *));
    result_strs[bench] = calloc(num_configs, sizeof(char *));
    for(config = 0; config < num_configs; config++) {
      if(debug) {
        printf("Parsing '%s', '%s'\n", bench_strs[bench], config_strs[config]);
      }
      /* First, construct a string of the path that we're looking at, consisting of:
         1. The RESULTS_DIR environment variable
         2. The benchmark name
         3. The benchmark size
         4. The configuration name
      */
      path = malloc(sizeof(char) *
                   (strlen(getenv("RESULTS_DIR")) +
                    strlen(bench_strs[bench]) +
                    strlen(size_str) +
                    strlen(config_strs[config]) +
                    4)); /* Three slashes and a NULL terminator */
      sprintf(path, "%s/%s/%s/%s", getenv("RESULTS_DIR"), bench_strs[bench], size_str, config_strs[config]);
      dir = opendir(path);
      if(dir == NULL) {
        fprintf(stderr, "Unable to open directory: '%s'. Filling with zeroes.\n", path);
        results[bench][config] = malloc(sizeof(result));
        results[bench][config]->geomean = 0.0;
        results[bench][config]->variance = 0.0;
        results[bench][config]->rel_geomean = 0.0;
        results[bench][config]->rel_variance = 0.0;
      } else {
        results[bench][config] = get_geomean_result(dir, path, metric_str, node, site);
        closedir(dir);
      }
      
      /* Now handle the `relative` flag */
      if(relative && (results[bench][0]->geomean != 0.0)) {
        results[bench][config]->rel_geomean = results[bench][config]->geomean / results[bench][0]->geomean;
        results[bench][config]->rel_variance = results[bench][config]->variance / results[bench][0]->geomean;
      }
      
      /* Here, we'll store the string of the result (including variance) in `result_strs`. We first figure
         out how long the string is going to be, then allocate enough room, then finally write the result
         into `result_strs[bench][config]`. */
      if(relative) {
        column_len = snprintf(NULL, 0, "%.2f ± %.2f", results[bench][config]->rel_geomean, results[bench][config]->rel_variance);
        result_strs[bench][config] = malloc(sizeof(char) * column_len);
        snprintf(result_strs[bench][config], column_len, "%.2f ± %.2f", results[bench][config]->rel_geomean, results[bench][config]->rel_variance);
      } else {
        column_len = snprintf(NULL, 0, "%.2f ± %.2f", results[bench][config]->geomean, results[bench][config]->variance);
        result_strs[bench][config] = malloc(sizeof(char) * column_len);
        snprintf(result_strs[bench][config], column_len, "%.2f ± %.2f", results[bench][config]->geomean, results[bench][config]->variance);
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
  
  /* Now, if we're doing a multi-config graph of some kind, let's output that */
  if((strcmp(metric_str, "graph_runtime") == 0) ||
     (strcmp(metric_str, "graph_first_phase_time") == 0) ||
     (strcmp(metric_str, "graph_max_phase_time") == 0) ||
     (strcmp(metric_str, "graph_min_phase_time") == 0) ||
     (strcmp(metric_str, "graph_last_phase_time") == 0)) {
    graph_metric_memreserve(bench_strs, num_benches, config_strs, num_configs, group_strs, num_groups, label_strs, num_labels, results, x_label, y_label);
  }
  
  /* Clean up */
  cleanup:
  free(metric_str);
  free(config_strs);
  free(bench_strs);
  return 0;
}
