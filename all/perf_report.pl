#!/usr/bin/env perl
use strict; use warnings;
use Getopt::Long qw(GetOptions);
use Data::Dumper;

my $dir =  $ENV{'BENCH_DIR'}; 
my $metric = "perf";
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
          ) or die "Usage: $0 --metric [perf,rss]\n";

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
    my $file = "$dir/$bench/run/results/$size/$cfg/stdout.txt";
    if(-e $file) {
      # Grab information about the runs
      my @output = `cat $file | sicm_dump_info`;
      foreach(@output) {
        if($metric eq "perf") {
          if(/Runtime: (\d+) \(..(\d+)\)/) {
            $results{$cfg}{$bench} = "$1" . "-$2";
          }
        } elsif($metric eq "rss") {
          if(/Peak RSS: (\d+)/) {
            $results{$cfg}{$bench} = sprintf("%.2f", $1 / 1024 / 1024 / 1024);
          }
        }
      }
    } else {
      if($metric eq "perf") {
        $results{$cfg}{$bench} = "0-0";
      } elsif($metric eq "rss") {
        $results{$cfg}{$bench} = sprintf("%.2f", 0);
      }
    }
    if((length($results{$cfg}{$bench}) + 2) > $max_col_length) {
      $max_col_length = length($results{$cfg}{$bench}) + 2;
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
    if($metric eq "perf") {
      printf("%${max_col_length}s", "$results{$cfg}{$bench}");
    } elsif($metric eq "rss") {
      printf("%${max_col_length}s", "$results{$cfg}{$bench}");
    }
  }
	print("\n");
}
