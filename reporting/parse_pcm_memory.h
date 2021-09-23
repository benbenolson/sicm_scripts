#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <limits.h>
#include <math.h>

#define NUM_PCM_MEMORY_METRICS 6
static char *pcm_memory_strs[NUM_PCM_MEMORY_METRICS+1] = {
  "geomean_bw",
  "geomean_dram_bw",
  "geomean_pmm_bw",
  "cum_bw",
  "num_bw_intervals",
  "hit_rate",
  NULL
};
enum pcm_memory_indices {
  GEOMEAN_BW,
  GEOMEAN_DRAM_BW,
  GEOMEAN_PMM_BW,
  CUM_BW,
  NUM_BW_INTERVALS,
  HIT_RATE,
};
static double pcm_memory_vals[NUM_PCM_MEMORY_METRICS];

double get_pcm_memory_val(char *metric_str, char *path, metric_opts *mopts) {
  char *line, *filepath;
  size_t len;
  ssize_t read;
  FILE *file;
  double tmp, tmp2;
  double *tot_bw_vals, *dram_read_vals, *dram_write_vals,
         *pmm_read_vals, *pmm_write_vals,
         tot_bw_geomean, dram_bw_geomean, pmm_bw_geomean;
  int num_skts;
  size_t num_intervals, num_tots, i;
  
  clear_double_arr(pcm_memory_vals, NUM_PCM_MEMORY_METRICS);
  
  /* Open the file */
  filepath = construct_path(path, "pcm-memory.txt");
  file = fopen(filepath, "r");
  if(!file) {
    fprintf(stderr, "WARNING: Failed to open '%s'. Filling with zero.\n");
    return 0.0;
  }
  free(filepath);
  
  /* We'll need all values to calculate the geomeans */
  tot_bw_vals = NULL;
  dram_read_vals = NULL;
  dram_write_vals = NULL;
  pmm_read_vals = NULL;
  pmm_write_vals = NULL;
  tot_bw_geomean = 0;
  dram_bw_geomean = 0;
  pmm_bw_geomean = 0;
  num_intervals = 0;
  num_tots = 0;
  
  /* NOTE: only supports one socket */
  line = NULL;
  len = 0;
  while(read = getline(&line, &len, file) != -1) {
    if(sscanf(line, "|-- Socket %lf --|", &tmp) == 1) {
      num_intervals++;
    } else if(sscanf(line, "|-- NODE0 Memory (MB/s): %lf --|", &tmp) == 1) {
      /* Older PCM tools use this printout */
      num_tots++;
      tot_bw_vals = realloc(tot_bw_vals, sizeof(double) * num_tots);
      tot_bw_vals[num_tots - 1] = tmp;
    } else if(sscanf(line, "|-- NODE 0 Memory (MB/s): %lf --|", &tmp) == 1) {
      /* This case is the newer PCM tools */
      num_tots++;
      tot_bw_vals = realloc(tot_bw_vals, sizeof(double) * num_tots);
      tot_bw_vals[num_tots - 1] = tmp;
    } else if(sscanf(line, "|-- NODE0 Mem Read (MB/s) : %lf --|", &tmp) == 1) {
      dram_read_vals = realloc(dram_read_vals, sizeof(double) * num_intervals);
      dram_read_vals[num_intervals - 1] = tmp;
    } else if(sscanf(line, "|-- NODE0 Mem Write(MB/s) : %lf --|", &tmp) == 1) {
      dram_write_vals = realloc(dram_write_vals, sizeof(double) * num_intervals);
      dram_write_vals[num_intervals - 1] = tmp;
    } else if(sscanf(line, "|-- NODE0 PMM Read (MB/s): %lf --|", &tmp) == 1) {
      pmm_read_vals = realloc(pmm_read_vals, sizeof(double) * num_intervals);
      pmm_read_vals[num_intervals - 1] = tmp;
    } else if(sscanf(line, "|-- NODE0 PMM Write(MB/s): %lf --|", &tmp) == 1) {
      pmm_write_vals = realloc(pmm_write_vals, sizeof(double) * num_intervals);
      pmm_write_vals[num_intervals - 1] = tmp;
    }
  }

  /* Aggregate the results, calculate geomeans */
  for(i = 0; i < num_intervals; i++) {
    if(dram_read_vals && dram_write_vals && (dram_read_vals[i] + dram_write_vals[i])) {
      dram_bw_geomean += log(dram_read_vals[i] + dram_write_vals[i]);
    }
    if(pmm_read_vals && pmm_write_vals && (pmm_read_vals[i] + pmm_write_vals[i])) {
      pmm_bw_geomean += log(pmm_read_vals[i] + pmm_write_vals[i]);
    }
  }
  for(i = 0; i < num_tots; i++) {
    if(tot_bw_vals[i]) {
      tot_bw_geomean += log(tot_bw_vals[i]);
      pcm_memory_vals[CUM_BW] += tot_bw_vals[i];
      printf("%lf,", tot_bw_vals[i]);
    }
  }
  printf("\n");
  tot_bw_geomean /= num_tots;
  tot_bw_geomean = exp(tot_bw_geomean);
  dram_bw_geomean /= num_intervals;
  dram_bw_geomean = exp(dram_bw_geomean);
  pmm_bw_geomean /= num_intervals;
  pmm_bw_geomean = exp(pmm_bw_geomean);
  
  pcm_memory_vals[GEOMEAN_BW] = tot_bw_geomean;
  pcm_memory_vals[GEOMEAN_DRAM_BW] = dram_bw_geomean;
  pcm_memory_vals[GEOMEAN_PMM_BW] = pmm_bw_geomean;
  pcm_memory_vals[NUM_BW_INTERVALS] = num_intervals;

cleanup:
  if(line) {
    free(line);
  }
  if(tot_bw_vals) {
    free(tot_bw_vals);
  }
  fclose(file);

  return pcm_memory_vals[metric_index(metric_str, pcm_memory_strs)];
}

void register_pcm_memory_metrics() {
  register_parser(pcm_memory_strs, get_pcm_memory_val);
}
