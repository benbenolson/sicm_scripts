#pragma once

/* Some metrics require additional miscellaneous information.
   Fill these in if provided, and pass along to the metric parsers */
typedef struct metric_opts {
  unsigned long node;
  int site;
  size_t index;
  char *output_filename; /* Used for graphs */
} metric_opts;

/* This is just a struct that includes a variance and geomean over the iterations that we ran. */
typedef struct geo_result {
  double geomean, rel_geomean;
  double variance, rel_variance;
} geo_result;

/* A parser registers a number of function pointers,
   plus a list of the metrics that it can provide.  */
typedef double (*get_metric_t)(char *, char *, metric_opts *);
typedef struct parser {
  char **metrics;
  get_metric_t get_metric_func;
} parser;

/* The parsers are placed in an array, which is iterated over
   to determine what function to call to get a particular metric */
#define PARSER_MAX 10
static int parser_num = 0;
static parser *parser_arr[PARSER_MAX];

static void clear_double_arr(double *arr, int max) {
  int i;
  
  for(i = 0; i < max; i++) {
    arr[i] = 0;
  }
}

/* The parsers call this function to register themselves to handle a list of metrics*/
void register_parser(char **metrics, get_metric_t get_metric_func);

void register_metrics();

void unregister_metrics();

/* Iterates over the metrics and tells you which index matches the metric string */
int metric_index(char *metric, char **metrics);

/* Gets a path from RESULTS_DIR based on its arguments */
char *get_config_path(char *bench_str, char *size_str, char *config_str);

/* This function returns a `result` struct */
void get_geo_result(char *path, char *metric_str, metric_opts *mopts, geo_result *result);

/* Appends the filename to the path */
char *construct_path(char *path, char *filename);

/* Calls the parser for this specific iteration */
double parse_iteration(char *metric_str, char *iterpath, metric_opts *mopts);
