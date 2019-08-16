#!/usr/bin/env perl
use strict; use warnings;

use Inline C => Config =>
    LIBS => '-lsicm_high',
    INC  => "$ENV{'INC'}";
use Inline C => <<'END_OF_C_CODE';
#include <sicm_parsing.h>

void print_profiling() {
  app_info *info;
  info = sh_parse_site_info(stdin);
}
END_OF_C_CODE

print_profiling();
