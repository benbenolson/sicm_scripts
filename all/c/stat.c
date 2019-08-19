#include <sicm_parsing.h>
#include <getopt.h>
#include <string.h>
#include <ctype.h>

static struct option long_options[] = {
    {"metric", required_argument, 0, 'm'},
    {"node", required_argument, 0, 'n'},
    {0,        0,                 0, 0}
};

typedef struct metrics {
  /* Peak RSS */
  size_t peak_rss_kbytes,
         sites_peak_rss,
         sites_peak_extent_size,
         sites_peak_alloc_size;

  /* Numastat */
  size_t num_nodes;
  unsigned long *memfree;

  /* Benchmark-specific */
  unsigned qmcpack_blocks, qmcpack_steps, qmcpack_walkers;
  double qmcpack_exectime;

  /* All benchmarks */
  double fom;
} metrics;

metrics *sh_init_metrics() {
  metrics *info;
  info = malloc(sizeof(metrics));

  /* Peak RSS */
  info->peak_rss_kbytes = 0;
  info->sites_peak_rss = 0;
  info->sites_peak_extent_size = 0;
  info->sites_peak_alloc_size = 0;

  /* Numastat */
  info->num_nodes = 0;
  info->memfree = NULL;

  /* Benchmark-specific  */
  info->qmcpack_blocks = 0;
  info->qmcpack_steps = 0;
  info->qmcpack_walkers = 0;
  info->qmcpack_exectime = 0.0;

  /* All benchmarks */
  info->fom = 0.0;

  return info;
}

char parse_fom(char *line, metrics *info) {
  unsigned unsigned_tmp;
  double double_tmp;
  char retval, *ptr;

  retval = 0;

  /* First QMCPACK */
	if(sscanf(line, "  blocks         = %u", &unsigned_tmp) == 1) {
    info->qmcpack_blocks = unsigned_tmp;
    retval = 1;
  } else if(sscanf(line, "  steps          = %u", &unsigned_tmp) == 1) {
    info->qmcpack_steps = unsigned_tmp;
    retval = 1;
  } else if(sscanf(line, "  walkers/mpi    = %u", &unsigned_tmp) == 1) {
    info->qmcpack_walkers = unsigned_tmp;
    retval = 1;
  } else if(sscanf(line, "  QMC Execution time = %lf secs", &double_tmp) == 1) {
    info->qmcpack_exectime = double_tmp;
    retval = 1;
  /* AMG */
  } else if(sscanf(line, "Figure of Merit (FOM_2): %lf", &double_tmp) == 1) {
    info->fom = double_tmp;
    retval = 1;
  /* SNAP */
  } else if(strncmp(line, "  Grind Time (nanoseconds)", 26) == 0) {
    /* Seek to the numerical value on the line */
    ptr = line;
    while(!isdigit(*ptr) && (*ptr)) {
      ptr++;
    }
    if(sscanf(ptr, "%lf\n", &double_tmp) != 1) {
      fprintf(stderr, "Error getting SNAP FOM. Aborting.\n");
      exit(1);
    }
    info->fom = 1.0 / double_tmp;
    retval = 1;
  }

  if(retval) {
    if(info->qmcpack_blocks && info->qmcpack_steps && info->qmcpack_walkers && info->qmcpack_exectime) {
      /* If all qmcpack values have been found, calculate the fom */
      info->fom = ((double) (info->qmcpack_blocks * info->qmcpack_steps * info->qmcpack_walkers)) / info->qmcpack_exectime;
    }
  }

  return retval;
}

char parse_gnu_time(char *line, metrics *info) {
  size_t tmp;

  if(sscanf(line, "  Maximum resident set size (kbytes): %zu", &tmp) == 1) {
    info->peak_rss_kbytes = tmp;
    return 1;
  }

  return 0;
}

char parse_numastat(char *line, metrics *info) {
  char *tmp_line, *tok;
  unsigned long val;
  char retval;

  retval = 0;

  /* Need to make a copy of the line because strtok modifies it */
  tmp_line = (char *) malloc(sizeof(char) * (strlen(line) + 1));
  strcpy(tmp_line, line);

  if(strncmp(line, "MemFree ", 8) == 0) {
    /* Figure out how many nodes there are in the output.
     * This is the number of space-delimited values on the line, 
     * minus the "MemFree" token and the total.
     */
    tok = strtok(tmp_line, " ");
    tok = strtok(NULL, " ");
    while(tok) {
      val = strtoul(tok, NULL, 0);
      info->num_nodes++;
      info->memfree = realloc(info->memfree, sizeof(unsigned long) * info->num_nodes);
      info->memfree[info->num_nodes - 1] = val;
      tok = strtok(NULL, " ");
      retval = 1;
    }
  }

  free(tmp_line);
  return retval;
}

/* Gets all non-SICM output; i.e., GNU time, benchmark FOM, etc. */
metrics *sh_parse_info(FILE *file) {
  char *line;
  size_t len;
  ssize_t read;
  metrics *info;

  info = sh_init_metrics();

  line = NULL;
  len = 0;
  while(read = getline(&line, &len, file) != -1) {
    if(parse_gnu_time(line, info)) continue;
    if(parse_numastat(line, info)) continue;
    if(parse_fom(line, info)) continue;
	}

  free(line);
  return info;
}

int main(int argc, char **argv) {
  app_info *site_info;
  metrics *info;
	int option_index;
  char *metric, c;
  FILE *file;
  unsigned long node;

  /* Handle options and arguments */
  node = -1;
  metric = NULL;
  while(1) {
    option_index = 0;
    c = getopt_long(argc, argv, "m:n:",
                    long_options, &option_index);
    if(c == -1) {
      break;
    }

    switch(c) {
      case 0:
        printf("option %s\n", long_options[option_index].name);
        break;
      case 'm':
        metric = (char *) malloc(sizeof(char) * (strlen(optarg) + 1));
        strcpy(metric, optarg);
        break;
      case 'n':
        node = strtoul(optarg, NULL, 0);
        /* Necessary because strtoul returns 0 on failure,
         * which could be the node number the user passed in.
         */
        if(((node == 0) && (strcmp(optarg, "0") != 0)) && (node < 0)) {
          fprintf(stderr, "Invalid node number: '%s'. Aborting.\n", optarg);
          exit(1);
        }
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

  /* Open the file */
  file = fopen(argv[optind], "r");
  if(!file) {
    fprintf(stderr, "Unable to open the file '%s'. Aborting.\n", argv[optind]);
    exit(1);
  }

  /* Do our parsing */
  info = sh_parse_info(file);
  fseek(file, 0, SEEK_SET);
  site_info = sh_parse_site_info(file);

  /* Print out the proper value */
  if(strncmp(metric, "peak_rss_kbytes", 15) == 0) {
    printf("%zu\n", info->peak_rss_kbytes);
  } else if(strncmp(metric, "memfree", 7) == 0) {
    if(node == -1) {
      fprintf(stderr, "Metric requires a node argument. Aborting.\n");
      goto cleanup;
    }
    if(node > (info->num_nodes - 1)) {
      fprintf(stderr, "Couldn't find specified node in output. Aborting.\n");
      goto cleanup;
    }
    printf("%zu\n", info->memfree[node]);
  } else if(strncmp(metric, "fom", 3) == 0) {
    printf("%f\n", info->fom);
  } else {
    fprintf(stderr, "Metric not yet implemented. Aborting.\n");
    goto cleanup;
  }

cleanup:
  /* Clean up */
  free(info);
  free_info(site_info);
  fclose(file);
  if(metric) free(metric);
}
