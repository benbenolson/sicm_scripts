#!/usr/bin/env perl
use strict; use warnings;
use Getopt::Long qw(GetOptions);
use Data::Dumper qw(Dumper);
use parse; # Does most of the nitty-gritty parsing

my $basedir =  "$ENV{'RESULTS_DIR'}"; 
my $metric = 'runtime';
my @benches = ('lulesh,imagick,fotonik3d,roms,qmcpack,snap,pennant');
my @benches_arg;
my @sizes = ('small');
my @sizes_arg;
my @cfgs = ('firsttouch_all_exclusive_device_0,firsttouch_all_exclusive_device_1');
my @cfgs_arg;

GetOptions('metric:s' => \$metric,
           'benches:s' => \@benches_arg,
           'sizes:s' => \@sizes_arg,
           'cfgs:s' => \@cfgs_arg,
          ) or die "Usage: $0 --metric=[perf,rss] --benches=[list of benches] --size=[list of sizes] --cfgs=[list of cfgs]\n";

# If any of these arrays are defined as arguments, overwrite the defaults
if(scalar @benches_arg > 0) {
  @benches = ();
  @benches = split(/,/,join(',',@benches_arg));
} else {
  @benches = split(/,/,join(',',@benches));
}
if(scalar @cfgs_arg > 0) {
  @cfgs = ();
  @cfgs = split(/,/,join(',',@cfgs_arg));
} else {
  @cfgs = split(/,/,join(',',@cfgs));
}
if(scalar @sizes_arg > 0) {
  @sizes = ();
  @sizes = split(/,/,join(',',@sizes_arg));
} else {
  @sizes = split(/,/,join(',',@sizes));
}

foreach my $size(@sizes) {
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
      my $dir = "$basedir/$bench/$size/$cfg";
      my $iter = 0;
      while(1) {

        # Break if this directory doesn't exist
        my $idir = "$dir/i${iter}";
        if((not -e $idir) or (not -d $idir)) {
          last;
        }

        # Parse the results into the hash
        $results{$cfg}{$bench}{${iter}} = {};
        parse_gnu_time("$idir/stdout.txt", $results{$cfg}{$bench}{$iter});
        parse_pcm_memory("$idir/pcm-memory.txt", $results{$cfg}{$bench}{$iter});
        parse_numastat("$idir/numastat.txt", $results{$cfg}{$bench}{$iter});
        parse_fom("$idir/stdout.txt", $results{$cfg}{$bench}{$iter}, $bench);
        parse_pebs("$idir/stdout.txt", $results{$cfg}{$bench}{$iter});

        $iter += 1;
      }

      # Construct a list of the metrics
      my $i;
      my @metrics;
      for($i = 0; $i < $iter; $i++) {
        @metrics = ();
        while(my($key, $val) = each %{$results{$cfg}{$bench}{$i}}) {
          if(defined($val)) {
            $results{$cfg}{$bench}{$key} = 0;
            $results{$cfg}{$bench}{$key . "_max"} = 0;
            $results{$cfg}{$bench}{$key . "_min"} = 999999999999;
            push(@metrics, $key);
          }
        }
      }

      # Iterate over each metric and get a total, maximum, and minimum for each.
      my $val;
      foreach my $metric(@metrics) {
        for($i = 0; $i < $iter; $i++) {
          $val = $results{$cfg}{$bench}{$i}{$metric};
          if(defined($val)) {
            $results{$cfg}{$bench}{$metric} += $val;
            if($val gt ($results{$cfg}{$bench}{$metric . "_max"})) {
              $results{$cfg}{$bench}{$metric . "_max"} = $val;
            }
            if($val lt ($results{$cfg}{$bench}{$metric . "_min"})) {
              $results{$cfg}{$bench}{$metric . "_min"} = $val;
            }
          }
        }
      }

      # Divide by the number of iterations
      foreach my $tmp_metric(@metrics) {
        if($results{$cfg}{$bench}{$tmp_metric} gt 0) {
          $results{$cfg}{$bench}{$tmp_metric} /= ($iter);
          $results{$cfg}{$bench}{$tmp_metric . "_max"} /= $results{$cfg}{$bench}{$tmp_metric};
          $results{$cfg}{$bench}{$tmp_metric . "_min"} /= $results{$cfg}{$bench}{$tmp_metric};
        }
      }

      $val = $results{$cfg}{$bench}{$metric};
      if(not defined $val) {
        $val = -1;
        $results{$cfg}{$bench}{$metric} = -1;
      }
      if((length($val) + 2) > $max_col_length) {
        $max_col_length = length($val) + 2;
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
}
