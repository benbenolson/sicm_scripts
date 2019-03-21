#!/usr/bin/env perl
use strict; use warnings;
use parse; # Does most of the nitty-gritty parsing

my $file = $ARGV[0];
my $stat = $ARGV[1];

my %results;
parse_gnu_time("$file", \%results);
parse_one_numastat("$file", \%results);

print($results{$stat});
