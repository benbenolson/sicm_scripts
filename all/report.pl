#!/usr/bin/env perl
use strict; use warnings;
use Getopt::Long qw(GetOptions);
use Data::Dumper qw(Dumper);
use parse; # Does most of the nitty-gritty parsing

my $dir =  $ENV{'BENCH_DIR'}; 
my $metric = 'runtime';
my @benches = ('lulesh,imagick,fotonik3d,roms,qmcpack,snap,pennant');
my @benches_arg;
my $size = 'small';
my $size_arg;
my @cfgs = ('firsttouch_all_exclusive_device_0,firsttouch_all_exclusive_device_1');
my @cfgs_arg;

GetOptions('metric:s' => \$metric,
           'benches:s' => \@benches_arg,
           'size:s' => \$size_arg,
           'cfgs:s' => \@cfgs_arg,
          ) or die "Usage: $0 --metric=[perf,rss] --benches=[list of benches] --size=[small,medium,large] --cfgs=[list of cfgs]\n";

# If any of these arrays are defined as arguments, overwrite the defaults
if(scalar @benches_arg > 0) {
  @benches = ();
  @benches = split(/,/,join(',',@benches_arg));
} else {
  @benches = split(/,/,join(',',@benches));
}
if(defined $size_arg) {
  $size = $size_arg;
}
if(scalar @cfgs_arg > 0) {
  @cfgs = ();
  @cfgs = split(/,/,join(',',@cfgs_arg));
} else {
  @cfgs = split(/,/,join(',',@cfgs));
}

# Figure out the longest config string
my $max_cfg_length = 0;
foreach(@cfgs) {
  if(length() > $max_cfg_length) {
    $max_cfg_length = length();
  }
}
$max_cfg_length += 2;

# Figure out the longest benchmark string
my $max_col_length = 0;
foreach(@benches) {
  if(length() > $max_col_length) {
    $max_col_length = length();
  }
}
$max_col_length += 2;

# Figure out the largest value string.
# Put all results in a hash.
my %results;
foreach my $cfg(@cfgs) {
  foreach my $bench(@benches) {
    $results{$cfg}{$bench} = {};
    parse_gnu_time("$dir/$bench/run/results/$size/$cfg/stdout.txt", $results{$cfg}{$bench});
    parse_pcm_memory("$dir/$bench/run/results/$size/$cfg/pcm-memory.txt", $results{$cfg}{$bench});
    if(not defined $results{$cfg}{$bench}{$metric}) {
      die("Unknown metric '$metric'");
    }
    if((length($results{$cfg}{$bench}{$metric}) + 2) > $max_col_length) {
      $max_col_length = length($results{$cfg}{$bench}{$metric}) + 2;
    }
  }
}

# Print out the top row, the benchmark names
printf("%-${max_cfg_length}s", "Config");
foreach my $bench(@benches) {
	printf("%${max_col_length}s", $bench);
}
print("\n");

foreach my $cfg(@cfgs) {
	printf("%-${max_cfg_length}s", $cfg);
  foreach my $bench(@benches) {
    printf("%${max_col_length}s", "$results{$cfg}{$bench}{$metric}");
  }
	print("\n");
}
