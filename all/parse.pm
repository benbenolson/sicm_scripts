#!/usr/bin/env perl
package parse;
use List::Util qw(sum max min);
use POSIX qw(ceil);
use Data::Dumper qw(Dumper);

# Export functions in this module
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(parse_gnu_time 
             parse_pcm_memory 
             parse_one_numastat 
             parse_numastat
             parse_pebs
             parse_fom
             median 
             round_two);

sub median {
  sum( (sort{ $a <=> $b } @_ )[ int( $#_/2 ), ceil( $#_/2 ) ] )/2;
}

sub round_two {
  int($_[0] * (10**2)) / 10**2;
}

# Accepts a filename of a file that
# contains GNU time output. Second
# argument is a reference to a hash with
# which to fill with results.
sub parse_gnu_time {
  my $filename = shift;
  my $results = shift; # This is a hash ref

  # Initialize all values to zero
  $results->{'runtime'} = 0;
  $results->{'rss'} = 0.0;
  $results->{'rss_kbytes'} = 0.0;

  open(my $file, '<', $filename)
    or return;

  while(<$file>) {
    chomp;
    if(/Elapsed \(wall clock\) time \(h:mm:ss or m:ss\): (\d+):([\d\.]+)$/) {
      # Convert m:ss to seconds
      $results->{'runtime'} = ($1 * 60) + $2;
    } elsif(/Elapsed \(wall clock\) time \(h:mm:ss or m:ss\): (\d+):(\d+):([\d\.]+)$/) {
      $results->{'runtime'} = ($1 * 60 * 60) + ($2 * 60) + $3;
    } elsif(/Maximum resident set size \(kbytes\): (\d+)/) {
      # Convert kilobytes to gigabytes, truncate to two decimal places
      $results->{'rss'} = round_two($1 / 1024 / 1024);
      $results->{'rss_kbytes'} = $1;
    }
  }
  close($file);
}

# Accepts a filename of a file that
# contains Intel's pcm-memory.x tool output. Second
# argument is a reference to a hash with
# which to fill with results.
sub parse_pcm_memory {
  my $filename = shift;
  my $results = shift; # This is a hash ref
  my @node0_bandwidth;
  my @node1_bandwidth;
  my @node0_read_bandwidth;
  my @node1_read_bandwidth;
  my @node0_write_bandwidth;
  my @node1_write_bandwidth;
  my @total_bandwidth;
  my @total_read_bandwidth;
  my @total_write_bandwidth;

  # AEP machine
  $results->{'avg_node0_bandwidth'} = 0.0;
  $results->{'max_node0_bandwidth'} = 0.0;
  $results->{'min_node0_bandwidth'} = 0.0;
  $results->{'median_node0_bandwidth'} = 0.0;

  $results->{'avg_node1_bandwidth'} = 0.0;
  $results->{'max_node1_bandwidth'} = 0.0;
  $results->{'min_node1_bandwidth'} = 0.0;
  $results->{'median_node1_bandwidth'} = 0.0;

  # Total
  $results->{'avg_total_bandwidth'} = 0.0;
  $results->{'max_total_bandwidth'} = 0.0;
  $results->{'min_total_bandwidth'} = 0.0;
  $results->{'median_total_bandwidth'} = 0.0;

  # Sum
  $results->{'sum_node0_bandwidth'} = 0;
  $results->{'sum_node1_bandwidth'} = 0;
  $results->{'sum_node0_read_bandwidth'} = 0;
  $results->{'sum_node1_read_bandwidth'} = 0;
  $results->{'sum_node0_write_bandwidth'} = 0;
  $results->{'sum_node1_write_bandwidth'} = 0;

  open(my $file, '<', $filename)
    or return;

  # Collect all samples into @*_bandwidth arrays
  while(<$file>) {
    chomp;
    if(/^\|\-\-\s+DDR4 Memory \(MB\/s\)\s+\:\s+([\d\.]+)\s+\-\-\|\|\-\-\s+MCDRAM \(MB\/s\)\s+\:\s+([\d\.]+)\s+\-\-\|$/) {
      # First and second are DDR bandwidth (before and after decimal point)
      # Third and fourth are MCDRAM
      push(@node0_bandwidth, $1);
      push(@node1_bandwidth, $2);
    } elsif(/^\|\-\-\s+DDR4 Mem Read\s+\(MB\/s\)\:\s+([\d\.]+)\s+\-\-\|\|\-\-\s+MCDRAM Read\s+\(MB\/s\)\:\s+([\d\.]+)\s+\-\-\|$/) {
      push(@node0_read_bandwidth, $1);
      push(@node1_read_bandwidth, $2);
    } elsif(/^\|\-\-\s+DDR4 Mem Write \(MB\/s\)\:\s+([\d\.]+)\s+\-\-\|\|\-\-\s+MCDRAM Write\(MB\/s\)\:\s+([\d\.]+)\s+\-\-\|$/) {
      push(@node0_write_bandwidth, $1);
      push(@node1_write_bandwidth, $2);
    } elsif(/^\|\-\-\s+NODE 0 Memory \(MB\/s\)\:\s+([\d\.]+)\s+\-\-\|\|\-\-\s+NODE 1 Memory \(MB\/s\)\:\s+([\d\.]+)\s+\-\-\|$/) {
      push(@node0_bandwidth, $1);
      push(@node1_bandwidth, $2);
    } elsif(/^\|\-\-\s+NODE 0 Mem Read \(MB\/s\) \:\s+([\d\.]+)\s+\-\-\|\|\-\-\s+NODE 1 Mem Read \(MB\/s\) \:\s+([\d\.]+)\s+\-\-\|$/) {
      push(@node0_read_bandwidth, $1);
      push(@node1_read_bandwidth, $2);
    } elsif(/^\|\-\-\s+NODE 0 Mem Write\(MB\/s\) \:\s+([\d\.]+)\s+\-\-\|\|\-\-\s+NODE 1 Mem Write\(MB\/s\) \:\s+([\d\.]+)\s+\-\-\|$/) {
      push(@node0_write_bandwidth, $1);
      push(@node1_write_bandwidth, $2);
    } elsif(/^\|\-\-\s+System Memory Throughput\(MB\/s\)\:\s+(\d+)\.(\d\d)\s+\-\-\|$/) {
      push(@total_bandwidth, $1 + ($2 / 100));
    } elsif(/^\|\-\-\s+System Read Throughput\(MB\/s\)\:\s+(\d+)\.(\d\d)\s+\-\-\|$/) {
      push(@total_read_bandwidth, $1 + ($2 / 100));
    } elsif(/^\|\-\-\s+System Write Throughput\(MB\/s\)\:\s+(\d+)\.(\d\d)\s+\-\-\|$/) {
      push(@total_write_bandwidth, $1 + ($2 / 100));
    }
  }
  close($file);

  # Now aggregate the results into single numbers
  if((scalar(@node0_bandwidth) > 0) and (scalar(@node1_bandwidth) > 0)) {
    $results->{'avg_node0_bandwidth'} = round_two(sum(@node0_bandwidth)/@node0_bandwidth);
    $results->{'sum_node0_bandwidth'} = sum(@node0_bandwidth);
    $results->{'max_node0_bandwidth'} = max(@node0_bandwidth) or die "Didn't get any PCM samples";
    $results->{'min_node0_bandwidth'} = min(@node0_bandwidth) or die "Didn't get any PCM samples";
    $results->{'median_node0_bandwidth'} = median(@node0_bandwidth);
    $results->{'avg_node1_bandwidth'} = round_two(sum(@node1_bandwidth)/@node1_bandwidth);
    $results->{'sum_node1_bandwidth'} = sum(@node1_bandwidth);
    $results->{'max_node1_bandwidth'} = max(@node1_bandwidth) or die "Didn't get any PCM samples";
    $results->{'min_node1_bandwidth'} = min(@node1_bandwidth) or die "Didn't get any PCM samples";
    $results->{'median_node1_bandwidth'} = median(@node1_bandwidth);
    $results->{'avg_total_bandwidth'} = round_two(sum(@total_bandwidth)/@total_bandwidth);
    $results->{'sum_total_bandwidth'} = sum(@total_bandwidth);
    $results->{'max_total_bandwidth'} = max(@total_bandwidth) or die "Didn't get any PCM samples";
    $results->{'min_total_bandwidth'} = min(@total_bandwidth) or die "Didn't get any PCM samples";
    $results->{'median_total_bandwidth'} = median(@total_bandwidth);
  }
  if((scalar(@node0_read_bandwidth) > 0) and (scalar(@node1_read_bandwidth) > 0)) {
    $results->{'avg_node0_read_bandwidth'} = round_two(sum(@node0_read_bandwidth)/@node0_read_bandwidth);
    $results->{'sum_node0_read_bandwidth'} = sum(@node0_read_bandwidth);
    $results->{'max_node0_read_bandwidth'} = max(@node0_read_bandwidth) or die "Didn't get any PCM samples";
    $results->{'min_node0_read_bandwidth'} = min(@node0_read_bandwidth) or die "Didn't get any PCM samples";
    $results->{'median_node0_read_bandwidth'} = median(@node0_read_bandwidth);
    $results->{'avg_node1_read_bandwidth'} = round_two(sum(@node1_read_bandwidth)/@node1_read_bandwidth);
    $results->{'sum_node1_read_bandwidth'} = sum(@node1_read_bandwidth);
    $results->{'max_node1_read_bandwidth'} = max(@node1_read_bandwidth) or die "Didn't get any PCM samples";
    $results->{'min_node1_read_bandwidth'} = min(@node1_read_bandwidth) or die "Didn't get any PCM samples";
    $results->{'median_node1_read_bandwidth'} = median(@node1_read_bandwidth);
    $results->{'avg_total_read_bandwidth'} = round_two(sum(@total_read_bandwidth)/@total_read_bandwidth);
    $results->{'sum_total_read_bandwidth'} = sum(@total_read_bandwidth);
    $results->{'max_total_read_bandwidth'} = max(@total_read_bandwidth) or die "Didn't get any PCM samples";
    $results->{'min_total_read_bandwidth'} = min(@total_read_bandwidth) or die "Didn't get any PCM samples";
    $results->{'median_total_read_bandwidth'} = median(@total_read_bandwidth);
  }
  if((scalar(@node0_write_bandwidth) > 0) and (scalar(@node1_write_bandwidth) > 0)) {
    $results->{'avg_node0_write_bandwidth'} = round_two(sum(@node0_write_bandwidth)/@node0_write_bandwidth);
    $results->{'sum_node0_write_bandwidth'} = sum(@node0_write_bandwidth);
    $results->{'max_node0_write_bandwidth'} = max(@node0_write_bandwidth) or die "Didn't get any PCM samples";
    $results->{'min_node0_write_bandwidth'} = min(@node0_write_bandwidth) or die "Didn't get any PCM samples";
    $results->{'median_node0_write_bandwidth'} = median(@node0_write_bandwidth);
    $results->{'avg_node1_write_bandwidth'} = round_two(sum(@node1_write_bandwidth)/@node1_write_bandwidth);
    $results->{'sum_node1_write_bandwidth'} = sum(@node1_write_bandwidth);
    $results->{'max_node1_write_bandwidth'} = max(@node1_write_bandwidth) or die "Didn't get any PCM samples";
    $results->{'min_node1_write_bandwidth'} = min(@node1_write_bandwidth) or die "Didn't get any PCM samples";
    $results->{'median_node1_write_bandwidth'} = median(@node1_write_bandwidth);
    $results->{'avg_total_write_bandwidth'} = round_two(sum(@total_write_bandwidth)/@total_write_bandwidth);
    $results->{'sum_total_write_bandwidth'} = sum(@total_write_bandwidth);
    $results->{'max_total_write_bandwidth'} = max(@total_write_bandwidth) or die "Didn't get any PCM samples";
    $results->{'min_total_write_bandwidth'} = min(@total_write_bandwidth) or die "Didn't get any PCM samples";
    $results->{'median_total_write_bandwidth'} = median(@total_write_bandwidth);
  }
}

# Accepts a filename of a file that contains numastat output. Second
# argument is a reference to a hash with which to fill with results.
# Only stores one numastat output, not multiple.
sub parse_one_numastat {
  my $filename = shift;
  my $results = shift; # This is a hash ref

  $results->{'mcdram_free'} = 0.0;
  $results->{'ddr_free'} = 0.0;
  $results->{'total_free'} = 0.0;

  $results->{'node2_free'} = 0.0;
  $results->{'node1_free'} = 0.0;
  $results->{'node0_free'} = 0.0;
  $results->{'total_free'} = 0.0;

  open(my $file, '<', $filename)
    or return;

  while(<$file>) {
    chomp;
    if(/MemFree\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)/) {
      $results->{'node0_free'} = $1;
      $results->{'node1_free'} = $2;
      $results->{'node2_free'} = $2;
      $results->{'total_free'} = $3;
    } elsif(/MemFree\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)/) {
      $results->{'ddr_free'} = $1;
      $results->{'mcdram_free'} = $2;
      $results->{'node0_free'} = $1;
      $results->{'node1_free'} = $2;
      $results->{'total_free'} = $3;
    }
  }
  close($file);
}

# Accepts a filename of a file that contains numastat output. Second
# argument is a reference to a hash with which to fill with results.
# This expects multiple numastat outputs, which it aggregates into
# more meaningful stats.
sub parse_numastat {
  my $filename = shift;
  my $results = shift; # This is a hash ref

  my @ddr_free;
  my @mcdram_free;
  my @total_free;

  $results->{'avg_ddr_free'} = 0.0;
  $results->{'avg_mcdram_free'} = 0.0;
  $results->{'avg_aep_free'} = 0.0;
  $results->{'avg_total_free'} = 0.0;

  $results->{'max_ddr_free'} = 0.0;
  $results->{'max_mcdram_free'} = 0.0;
  $results->{'max_aep_free'} = 0.0;
  $results->{'max_total_free'} = 0.0;

  $results->{'min_ddr_free'} = -1;
  $results->{'min_mcdram_free'} = -1;
  $results->{'min_aep_free'} = -1;
  $results->{'min_total_free'} = -1;

  open(my $file, '<', $filename)
    or return;

  while(<$file>) {
    chomp;
    if(/MemFree\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)/) {
      push(@ddr_free, $1);
      push(@mcdram_free, $2);
      push(@total_free, $3);

      # Max
      if($1 > $results->{'max_ddr_free'}) {
        $results->{'max_ddr_free'} = $1;
      }
      if($2 > $results->{'max_mcdram_free'}) {
        $results->{'max_mcdram_free'} = $2;
      }
      if($3 > $results->{'max_total_free'}) {
        $results->{'max_total_free'} = $3;
      }

      # Min
      if(($1 < $results->{'min_ddr_free'}) or ($results->{'min_ddr_free'} == -1)) {
        $results->{'min_ddr_free'} = $1;
      }
      if(($2 < $results->{'min_mcdram_free'}) or ($results->{'min_mcdram_free'} == -1)) {
        $results->{'min_mcdram_free'} = $2;
      }
      if(($3 < $results->{'min_total_free'}) or ($results->{'min_total_free'} == -1)) {
        $results->{'min_total_free'} = $3;
      }
    }
  }

  if((scalar(@ddr_free) > 0) and (scalar(@mcdram_free) > 0) and (scalar(@total_free) > 0)) {
    $results->{'avg_ddr_free'} = round_two(sum(@ddr_free)/@ddr_free);
    $results->{'avg_mcdram_free'} = round_two(sum(@mcdram_free)/@mcdram_free);
    $results->{'avg_total_free'} = round_two(sum(@total_free)/@total_free);
  }

  close($file);
}


# First argument is the filename
# Second argument is the reference to a hash
# Third argument is the benchmark name
# Expects the other parsing functions to have been run, grabs
# results from them
sub parse_fom {
  my $filename = shift;
  my $results = shift;
  my $bench = shift;

  my @qmcpack_numerator_terms;
  my $qmcpack_denominator;
  my $qmcpack_numerator = 1;

  open(my $file, '<', $filename)
    or return;

  $results->{'fom'} = 0.0;

  while(<$file>) {
    if($bench eq "lulesh") {
      if(/FOM\s+=\s+([\d\.]+)\s+\(z\/s\)/) {
        $results->{'fom'} = $1;
      }
    } elsif($bench eq "amg") {
      if(/Figure of Merit \(FOM_2\):\s+(\S*)/) {
        $results->{'fom'} = $1;
      }
    } elsif($bench eq "qmcpack") {
      if(/blocks\s+=\s+(\d+)/) {
        push(@qmcpack_numerator_terms, $1);
      } elsif(/steps\s+=\s+(\d+)/) {
        push(@qmcpack_numerator_terms, $1);
      } elsif(/walkers\/mpi\s+=\s+(\d+)/) {
        push(@qmcpack_numerator_terms, $1);
      } elsif(/QMC Execution time = ([\d\.e\+]+) secs/) {
        $qmcpack_denominator = $1;
      }
    } elsif($bench eq "snap") {
      if(/Grind Time \(nanoseconds\)\s+([\d\.E\+]+)/) {
        $results->{'fom'} = 1 / $1;
      }
    }
  }
  if($bench eq "qmcpack") {
    $qmcpack_numerator *= $_ foreach @qmcpack_numerator_terms;
    $results->{'fom'} = $qmcpack_numerator / $qmcpack_denominator;
  }
  if($results->{'fom'} == 0.0) {
    print(STDERR "WARNING: Didn't find a FOM in file $filename\n");
  }

}

# Accepts a filename of a file that contains PEBS output. Second
# argument is a reference to a hash with which to fill with results.
# This expects one PEBS output.
sub parse_pebs {
  my $filename = shift;
  my $results = shift; # This is a hash ref

  $results->{'num_sites'} = 0;

  open(my $file, '<', $filename)
    or return;

  my $in_pebs_results = 0;
  my $in_arena = 0;
  my $in_event = 0;
  my @tmp_sites;
  my $tmp_event = "";
  while(<$file>) {
    chomp;
    if(/===== PEBS RESULTS =====/) {
      $in_pebs_results = 1;
    } elsif($in_pebs_results and /(\d+) sites: ([\d\s]+)/) {
      # Stored in $1 is the number of sites in this arena
      # Stored in $2 is the list of site IDs, delimited by spaces
      $results->{'num_sites'}++;
      @tmp_sites = ();
      foreach(split(/ /, $2)) {
        push(@tmp_sites, $_);
        $results->{'sites'}{$_} = {};
        $results->{'sites'}{$_}{'num_events'} = 0;
      }
      $in_arena = 1;
      $in_event = 0;
    } elsif($in_arena and /Peak RSS: ([\d]+)/) {
      foreach(@tmp_sites) {
        $results->{'sites'}{$_}{'peak_rss'} = $1;
      }
      $in_event = 0;
    } elsif($in_arena and /Number of intervals: ([\d]+)/) {
      foreach(@tmp_sites) {
        $results->{'sites'}{$_}{'num_intervals'} = $1;
      }
      $in_event = 0;
    } elsif($in_arena and /First interval: ([\d]+)/) {
      foreach(@tmp_sites) {
        $results->{'sites'}{$_}{'first_interval'} = $1;
      }
      $in_event = 0;
    } elsif($in_arena and /Event: (.+)/) {
      foreach(@tmp_sites) {
        $results->{'sites'}{$_}{'num_events'}++;
        if(not defined($results->{'sites'}{$_}{'events'})) {
          $results->{'sites'}{$_}{'events'} = {};
        }
        $results->{'sites'}{$_}{'events'}{$1} = {};
      }
      $in_event = 1;
      $tmp_event = $1;
    } elsif($in_arena and $in_event and /Total: ([\d]+)/) {
      foreach(@tmp_sites) {
        $results->{'sites'}{$_}{'events'}{$tmp_event}{'total'} = $1;
      }
    } elsif($in_arena and $in_event and /^[\s]*([\d]+)/) {
      foreach(@tmp_sites) {
        if(not defined($results->{'sites'}{$_}{'events'}{$tmp_event}{'intervals'})) {
          $results->{'sites'}{$_}{'events'}{$tmp_event}{'intervals'} = ();
          # Backfill 0-access intervals if it didn't start at the beginning
          foreach my $interval(0..$results->{'sites'}{$_}{'first_interval'}) {
            push(@{$results->{'sites'}{$_}{'events'}{$tmp_event}{'intervals'}}, 0);
          }
        }
        push(@{$results->{'sites'}{$_}{'events'}{$tmp_event}{'intervals'}}, $1);
      }
    }
  }

  close($file);
}

1; # Truthiest module there is
