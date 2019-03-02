#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <limits.h>

/* Takes a metric (graphing script name) as input, runs `jgraph` on it and generates a PNG of the graph */
void jgraph_wrapper(char *metric, char *args) {
  char *command, *line;
  size_t nread, line_length;
  FILE *output;

  /* Call the jgraph script */
  command = malloc(sizeof(char) * 400);
  if(output_filename) {
    if(output_filetype) {
      snprintf(command, 400,
        "${SCRIPTS_DIR}/all/bash/%s.sh %s | ${SCRIPTS_DIR}/tools/jgraph/jgraph > %s",
        metric, args, output_filename);
    } else {
      snprintf(command, 400,
        "${SCRIPTS_DIR}/all/bash/%s.sh %s | ${SCRIPTS_DIR}/tools/jgraph/jgraph | gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=png16m -dEPSCrop -r500 -dGraphicsAlphaBits=1 -dTextAlphaBits=4 -sOutputFile=%s -",
        metric, args, output_filename);
    }
  } else {
    if(output_filetype) {
      snprintf(command, 400,
        "${SCRIPTS_DIR}/all/bash/%s.sh %s | ${SCRIPTS_DIR}/tools/jgraph/jgraph",
        metric, args);
    } else {
      snprintf(command, 400,
        "${SCRIPTS_DIR}/all/bash/%s.sh %s | ${SCRIPTS_DIR}/tools/jgraph/jgraph | gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=png16m -dEPSCrop -r500 -dGraphicsAlphaBits=1 -dTextAlphaBits=4 -sOutputFile=test.png -",
        metric, args);
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
