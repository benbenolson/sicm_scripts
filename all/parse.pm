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
    or print("WARNING: '$filename' does not exist.\n") and return;

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
  my @ddr_bandwidth; # Used before aggregating
  my @mcdram_bandwidth; # Used before aggregating
  my @node0_bandwidth;
  my @node1_bandwidth;
  my @total_bandwidth;

  # DDR
  $results->{'avg_ddr_bandwidth'} = 0.0;
  $results->{'max_ddr_bandwidth'} = 0.0;
  $results->{'min_ddr_bandwidth'} = 0.0;
  $results->{'median_ddr_bandwidth'} = 0.0;

  # MCDRAM
  $results->{'avg_mcdram_bandwidth'} = 0.0;
  $results->{'max_mcdram_bandwidth'} = 0.0;
  $results->{'min_mcdram_bandwidth'} = 0.0;
  $results->{'median_mcdram_bandwidth'} = 0.0;

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

  open(my $file, '<', $filename)
    or print("WARNING: '$filename' does not exist.\n") and return;

  # Collect all samples into @*_bandwidth arrays
  while(<$file>) {
    chomp;
    if(/^\|\-\-\s+DDR4 Memory \(MB\/s\)\s+\:\s+(\d+)\.(\d\d)\s+\-\-\|\|\-\-\s+MCDRAM \(MB\/s\)\s+\:\s+(\d+)\.(\d\d)\s+\-\-\|$/) {
      # First and second are DDR bandwidth (before and after decimal point)
      # Third and fourth are MCDRAM
      # Convert to GB/s
      push(@ddr_bandwidth, $1 + ($2 / 100));
      push(@mcdram_bandwidth, $3 + ($4 / 100));
      push(@node0_bandwidth, $1 + ($2 / 100));
      push(@node1_bandwidth, $3 + ($4 / 100));
    } elsif(/^\|\-\-\s+System Memory Throughput\(MB\/s\)\:\s+(\d+)\.(\d\d)\s+\-\-\|$/) {
      push(@total_bandwidth, $1 + ($2 / 100));
    }
  }
  close($file);

  # Now aggregate the results into single numbers
  if((scalar(@ddr_bandwidth) > 0) and (scalar(@mcdram_bandwidth) > 0)) {
    $results->{'avg_ddr_bandwidth'} = round_two(sum(@ddr_bandwidth)/@ddr_bandwidth);
    $results->{'max_ddr_bandwidth'} = max(@ddr_bandwidth) or die "Didn't get any PCM samples";
    $results->{'min_ddr_bandwidth'} = min(@ddr_bandwidth) or die "Didn't get any PCM samples";
    $results->{'median_ddr_bandwidth'} = median(@ddr_bandwidth);
    $results->{'avg_mcdram_bandwidth'} = round_two(sum(@mcdram_bandwidth)/@mcdram_bandwidth);
    $results->{'max_mcdram_bandwidth'} = max(@mcdram_bandwidth) or die "Didn't get any PCM samples";
    $results->{'min_mcdram_bandwidth'} = min(@mcdram_bandwidth) or die "Didn't get any PCM samples";
    $results->{'median_mcdram_bandwidth'} = median(@mcdram_bandwidth);
    $results->{'avg_total_bandwidth'} = round_two(sum(@total_bandwidth)/@total_bandwidth);
    $results->{'max_total_bandwidth'} = max(@total_bandwidth) or die "Didn't get any PCM samples";
    $results->{'min_total_bandwidth'} = min(@total_bandwidth) or die "Didn't get any PCM samples";
    $results->{'median_total_bandwidth'} = median(@total_bandwidth);
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
    or print("WARNING: '$filename' does not exist.\n") and return;

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
    or print("WARNING: '$filename' does not exist.\n") and return;

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

# Accepts a filename of a file that contains PEBS output. Second
# argument is a reference to a hash with which to fill with results.
# This expects one PEBS output.
sub parse_pebs {
  my $filename = shift;
  my $results = shift; # This is a hash ref

  $results->{'num_sites'} = 0;
  $results->{'sites'} = ();

  open(my $file, '<', $filename)
    or print("WARNING: '$filename' does not exist.\n") and return;

  my $in_pebs_results = 0;
  while(<$file>) {
    chomp;
    if(/===== PEBS RESULTS =====/) {
      $in_pebs_results = 1;
    } elsif(/(\d+) sites: ([\d\s]+)/) {
      # Stored in $1 is the number of sites in this arena
      # Stored in $2 is the list of site IDs, delimited by spaces
      $results->{'num_sites'}++;
      foreach(split(/ /, $2)) {
        push(@{$results->{'sites'}}, $_);
      }
    }
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
    or print("WARNING: '$filename' does not exist.\n") and return;

  $results->{'fom'} = 0.0;

  while(<$file>) {
    if($bench eq "lulesh") {
      if(/FOM\s+=\s+([\d\.]+)\s+\(z\/s\)/) {
        $results->{'fom'} = $1;
      }
    } elsif($bench eq "amg") {
      if(/Figure of Merit \(FOM_2\):\s+(.*)/) {
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
}

1; # Truthiest module there is
