#!/usr/bin/perl
# One argument: the background bandwidth that you'd like to filter out.
# Reads on stdin and outputs on stdout.
use warnings; use strict;

my $background_bandwidth = $ARGV[0];

while(<STDIN>) {
  if(/Average bandwidth: ([\d\.]+) MB\/s/) {
    my $new_bandwidth = 0.0;
    if($1 > $background_bandwidth) {
      $new_bandwidth = $1 - $background_bandwidth;
    }
    print("Average bandwidth: $new_bandwidth MB/s\n");
  } else {
    print;
  }
}
