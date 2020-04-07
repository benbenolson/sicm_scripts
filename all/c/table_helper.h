#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <limits.h>
#include <sicm_parsing.h>
#include <sicm_packing.h>

/* Functions that generate tables for the graphs */
char *generate_hotset_diff_table(FILE *input_file, char top100, int sort_arg);
char *generate_weight_ratio_table(FILE *input_file, char top100, int sort_arg);
char *generate_heatmap_table(FILE *input_file, char top100, int sort_arg);

static application_profile *app_prof = NULL;

/* Sets the filename and fp that you give it a pointer to */
void open_tmp_file(char **filename, FILE **fp) {
  int fd;

  /* Generate a random temporary filename and open it */
  *filename = malloc(sizeof(char) * 12);
  sprintf(*filename, "/tmp/XXXXXX");
  fd = mkstemp(*filename);
  if(fd == -1) {
    fprintf(stderr, "Issue creating temporary files. Aborting.\n");
    exit(1);
  }
  *fp = fdopen(fd, "w");
  if(!(*fp)) {
    fprintf(stderr, "Issue opening temporary files. Aborting.\n");
    exit(1);
  }
}


void packing_init_wrapper(FILE *input_file, int value_arg, int weight_arg, int sort_arg) {
  /* Arguments to the packing library */
  packing_options *opts;
  
  opts = orig_calloc(sizeof(char), sizeof(packing_options));

  opts->value = value_arg;
  opts->weight = weight_arg;
  opts->sort = sort_arg;

  if(!app_prof) {
    /* Only parse the file again if it's not already set. Beware that this means that
       we can only have one profiling file input per run of this application. */
    app_prof = sh_parse_profiling(input_file);
    fseek(input_file, 0, SEEK_SET);
  }

  /* Initialize the packing library */
  sh_packing_init(app_prof, &opts);
}

size_t get_total_site_weight(tree(site_info_ptr, int) site_tree) {
  size_t total_site_size;
  tree_it(site_info_ptr, int) sit;

  total_site_size = 0;
  tree_traverse(site_tree, sit) {
    total_site_size += tree_it_key(sit)->weight;
  }

  return total_site_size;
}

/* If `top100` is set, we'll only generate a table of the top 100 sites (by value/weight). Everything
   else will be the same. */
char *generate_hotset_diff_table(FILE *input_file, char top100, int sort_arg) {
  /* Trees, keyed by their site_info. Sorted by weight. */
  tree(site_info_ptr, int) online_sites,
                           offline_sites;

  /* Trees, keyed on site ID */
  tree(int, site_info_ptr) offline_hotset,
                           online_dramset,
                           online_hotset,
                           top100_sites;

  /* Iterators for the above trees */
  tree_it(site_info_ptr, int) sit;
  tree_it(int, site_info_ptr) hit, off, on, dram;

  char *hotset_diff_table_name;
  unsigned char state;
  FILE *hotset_diff_table_f;
  size_t i;

  open_tmp_file(&hotset_diff_table_name, &hotset_diff_table_f);

  /* This site_tree will be sorted by value/weight, because we need that to generate the hotset. */
  packing_init_wrapper(input_file, PROFILE_ALL_TOTAL, 0, 0);
  offline_sites = sh_convert_to_site_tree(app_prof, app_prof->num_intervals - 1);
  offline_hotset = sh_get_hot_sites(offline_sites, app_prof->upper_capacity);
  if(top100) {
    top100_sites = sh_get_top_sites(offline_sites, 100);
  }

  /* Now get the same sites, but sorted by weight. */
  packing_init_wrapper(input_file, PROFILE_ALL_TOTAL, 0, sort_arg);
  offline_sites = sh_convert_to_site_tree(app_prof, app_prof->num_intervals - 1);

  /* Print the header of site IDs */
  tree_traverse(offline_sites, sit) {
    if(top100 && !tree_it_good(tree_lookup(top100_sites, tree_it_val(sit)))) {
      continue;
    }
    fprintf(hotset_diff_table_f, "%d ", tree_it_val(sit));
  }
  fprintf(hotset_diff_table_f, "\n");


  /* Now we'll go through each interval, generate a hotset for it, and check it against the offline hotset */
  /* For each site that aligns with what the offline hotset chose, place a 1. Otherwise, 0. */
  for(i = 0; i < app_prof->num_intervals; i++) {
    /* Get the current interval's site_tree.
       Using the device that the site was bound to in the profiling information,
       construct a hotset to compare against the offline one. */
    online_sites = sh_convert_to_site_tree(app_prof, i);
    online_dramset = tree_make(int, site_info_ptr);
    online_hotset = tree_make(int, site_info_ptr);

    /* Build `online_dramset`, the set of sites that are in DRAM this interval. */
    tree_traverse(online_sites, sit) {
      if(top100 && !tree_it_good(tree_lookup(top100_sites, tree_it_val(sit)))) {
        continue;
      }
      if(tree_it_key(sit)->dev == 1) {
        tree_insert(online_dramset, tree_it_val(sit), tree_it_key(sit));
      }
    }

    /* Build `online_hotset`, the set of sites that are in the hotset this interval. */
    tree_traverse(online_sites, sit) {
      if(top100 && !tree_it_good(tree_lookup(top100_sites, tree_it_val(sit)))) {
        continue;
      }
      if(tree_it_key(sit)->hot == 1) {
        tree_insert(online_hotset, tree_it_val(sit), tree_it_key(sit));
      }
    }

    /* Compare this interval's set of sites on the DRAM, and the offline hotset */
    tree_traverse(offline_sites, sit) {

      if(top100 && !tree_it_good(tree_lookup(top100_sites, tree_it_val(sit)))) {
        continue;
      }

      off = tree_lookup(offline_hotset, tree_it_val(sit));
      on = tree_lookup(online_hotset, tree_it_val(sit));
      dram = tree_lookup(online_dramset, tree_it_val(sit));

      /* Construct a three-bit mask of the three attributes */
      state = 0;
      if(tree_it_good(dram)) {
        /* The most significant bit is whether or not it's in DRAM. */
        state |= 1UL << 2;
      }
      if(tree_it_good(on)) {
        /* The second-most-significant bit is whether or not it's in the online hotset */
        state |= 1UL << 1;
      }
      if(tree_it_good(off)) {
        /* The last bit is whether or not it's in the offline hotset */
        state |= 1UL << 0;
      }

      fprintf(hotset_diff_table_f, "%d ", state);
    }
    fprintf(hotset_diff_table_f, "\n");

    tree_free(online_dramset);
    tree_free(online_hotset);
    tree_free(online_sites);
  }
  tree_free(offline_hotset);
  tree_free(offline_sites);
  fclose(hotset_diff_table_f);

  return hotset_diff_table_name;
}

/* Uses the given application_profile to generate a list of weight ratios
   for each site. Returns the filename, which the caller should free. */
char *generate_weight_ratio_table(FILE *input_file, char top100, int sort_arg) {
  size_t total_site_size;
  char *weight_ratio_table_name;
  FILE *weight_ratio_table_f;
  tree(site_info_ptr, int) offline_sites;
  tree(int, site_info_ptr) top100_sites;
  tree_it(site_info_ptr, int) sit;

  open_tmp_file(&weight_ratio_table_name, &weight_ratio_table_f);

  if(top100) {
    /* We first need to get the sites sorted by value/weight, then
       get the top 100 */
    packing_init_wrapper(input_file, PROFILE_ALL_TOTAL, 0, 0);
    offline_sites = sh_convert_to_site_tree(app_prof, app_prof->num_intervals - 1);
    top100_sites = sh_get_top_sites(offline_sites, 100);
  }

  /* The resulting tree will be sorted by the weight of the site */
  packing_init_wrapper(input_file, PROFILE_ALL_TOTAL, 0, sort_arg);
  offline_sites = sh_convert_to_site_tree(app_prof, app_prof->num_intervals - 1);

  /* Calculate the total weight first. */
  total_site_size = 0;
  tree_traverse(offline_sites, sit) {
    if(top100 && !tree_it_good(tree_lookup(top100_sites, tree_it_val(sit)))) {
      continue;
    }
    total_site_size += tree_it_key(sit)->weight;
  }

  tree_traverse(offline_sites, sit) {
    if(top100 && !tree_it_good(tree_lookup(top100_sites, tree_it_val(sit)))) {
      continue;
    }
    fprintf(weight_ratio_table_f, "%d ", tree_it_val(sit));
  }
  fprintf(weight_ratio_table_f, "\n");
  tree_traverse(offline_sites, sit) {
    if(top100 && !tree_it_good(tree_lookup(top100_sites, tree_it_val(sit)))) {
      continue;
    }
    fprintf(weight_ratio_table_f, "%lf ", ((double)tree_it_key(sit)->weight) / ((double)total_site_size) * 100);
  }
  fprintf(weight_ratio_table_f, "\n");
  tree_free(offline_sites);
  fclose(weight_ratio_table_f);

  return weight_ratio_table_name;
}

/* Uses the given application_profile to generate a heatmap file.
   Returns the filename, which the caller should free. */
char *generate_heatmap_table(FILE *input_file, char top100, int sort_arg) {
  char *heatmap_name;
  FILE *heatmap_f;
  size_t total_site_size, i, n;

  /* To store the aggregated profiling data */
  tree(site_info_ptr, int) online_sites, last_interval_sites;
  tree(int, site_info_ptr) online_sites_flipped,
                           top100_sites;
  tree_it(site_info_ptr, int) sit;
  tree_it(int, site_info_ptr) find;

  open_tmp_file(&heatmap_name, &heatmap_f);

  if(top100) {
    packing_init_wrapper(input_file, PROFILE_ALL_CURRENT, 0, 0);
    last_interval_sites = sh_convert_to_site_tree(app_prof, app_prof->num_intervals - 1);
    top100_sites = sh_get_top_sites(last_interval_sites, 100);
  }

  /* Sort sites by weight */
  packing_init_wrapper(input_file, PROFILE_ALL_CURRENT, 0, sort_arg);
  last_interval_sites = sh_convert_to_site_tree(app_prof, app_prof->num_intervals - 1);

  /* Print out the header to the table. This is just site IDs. We're iterating over
     the last_interval_sites because it's sorted by weight. */
  tree_traverse(last_interval_sites, sit) {
    if(top100 && !tree_it_good(tree_lookup(top100_sites, tree_it_val(sit)))) {
      continue;
    }
    fprintf(heatmap_f, "%d ", tree_it_val(sit));
  }
  fprintf(heatmap_f, "\n");

  /* Now, look at each interval. Print the value per weight for each site, sorted by weight. */
  for(i = 0; i < app_prof->num_intervals; i++) {
    /* Get the current interval's site_tree, then flip it so the keys are site IDs. */
    online_sites = sh_convert_to_site_tree(app_prof, i);
    online_sites_flipped = sh_flip_site_tree(online_sites);
    /* Iterate over the sites in the last interval, find them in the current interval,
       and print "0" if it's not found. */
    tree_traverse(last_interval_sites, sit) {
      if(top100 && !tree_it_good(tree_lookup(top100_sites, tree_it_val(sit)))) {
        continue;
      }
      find = tree_lookup(online_sites_flipped, tree_it_val(sit));
      if(tree_it_good(find)) {
        fprintf(heatmap_f, "%lf ", tree_it_val(find)->value_per_weight);
      } else {
        fprintf(heatmap_f, "%lf ", 0);
      }
    }
    fprintf(heatmap_f, "\n");
    tree_free(online_sites_flipped);
    tree_free(online_sites);
  }
  tree_free(last_interval_sites);
  fclose(heatmap_f);

  return heatmap_name;
}
