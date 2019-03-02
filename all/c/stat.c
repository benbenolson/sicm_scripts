#include <getopt.h>
#include <string.h>
#include <ctype.h>
#include "stat.h"

/* USAGE: ./stat --metric=X [--node=X] pathname */

static struct option long_options[] = {
    {"metric", required_argument, 0, 'm'},
    {"node", required_argument, 0, 'n'},
    {"site", required_argument, 0, 's'},
    {"graph_title", required_argument, 0, 't'},
    {"filename", required_argument, 0, 'o'},
    {"eps", no_argument, 0, 'e'},
    {0,        0,                 0, 0}
};

int main(int argc, char **argv) {
  metrics *info;
  int option_index, site;
  char *metric, c, *path;
  unsigned long node;

  /* Handle options and arguments */
  node = UINT_MAX;
  metric = NULL;
  while(1) {
    option_index = 0;
    c = getopt_long(argc, argv, "m:n:s:t:eo:",
                    long_options, &option_index);
    if(c == -1) {
      break;
    }

    switch(c) {
      case 0:
        printf("option %s\n", long_options[option_index].name);
        break;
      case 'm':
        /* Metric name. Required. */
        metric = (char *) malloc(sizeof(char) * (strlen(optarg) + 1));
        strcpy(metric, optarg);
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
        /* This is an output filename that can be used to output a PNG or table to. */
        output_filetype = 1;
        break;
      case '?':
        exit(1);
      default:
        exit(1);
    }
  }
  if(!metric) {
    fprintf(stderr, "No metric given. Aborting.\n");
    exit(1);
  }
  if(!(optind < argc) || !((argc - optind) == 1)) {
    fprintf(stderr, "Incorrect number of arguments. Specify the filename as the last argument.\n");
    exit(1);
  }

  /* The last argument is the path. */
  path = malloc(sizeof(char) * (strlen(argv[optind]) + 1));
  strcpy(path, argv[optind]);

  /* Initialize and do the parsing */
  info = init_metrics();
  parse_metrics(info, path, metric, node, site);
  free_metrics(info);

  /* Clean up */
  free(path);
  free(metric);
}
