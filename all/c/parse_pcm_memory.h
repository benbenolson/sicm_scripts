#include <string.h>
#include <ctype.h>

char parse_pcm_memory(char *line, metrics *info) {
  double tmp, tmp2;

  if(sscanf(line, "|-- NODE 0 Memory (MB/s):%*[ ]%f --||-- NODE 1 Memory (MB/s):%*[ ]%f --|", &tmp, &tmp2) == 2) {

  }

  return 0;
}
