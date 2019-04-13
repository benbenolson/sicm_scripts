#!/usr/bin/env perl
# Takes an input file and a metric. Prints out the metric.
use strict; use warnings;
use parse; # Does most of the nitty-gritty parsing

my $file = $ARGV[0];
my $stat = $ARGV[1];

my %results;
parse_gnu_time("$file", \%results);
parse_one_numastat("$file", \%results);
parse_gnu_time("$file", \%results);
parse_pcm_memory("$file", \%results);
parse_numastat("$file", \%results);
parse_pebs("$file", \%results);

if(ref($results{$stat}) eq 'ARRAY') {
  foreach(@{$results{$stat}}) {
    print("$_\n");
  }
} else {
  print($results{$stat});
}
