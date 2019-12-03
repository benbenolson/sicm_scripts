#include <sicm_parsing.h>
#include <string.h>
#include <ctype.h>

char parse_sicm(char *line, metrics *info) {
  double time, interval_time;
  char retval = 0;

  if(sscanf(line, "WARNING: Interval (%lf) went over the time limit (%lf).", &time, &interval_time) == 2) {
    info->interval_time_over += (time - interval_time);
    retval = 1;
  }

  return retval;
}
