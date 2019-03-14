#!/usr/bin/env perl
package parse;
use List::Util qw(sum max min);
use POSIX qw(ceil);
use Data::Dumper qw(Dumper);

# Export functions in this module
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(parse_gnu_time parse_pcm_memory);

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

  open(my $file, '<', $filename)
    or print("WARNING: '$filename' does not exist.\n") and return;

  while(<$file>) {
    chomp;
    if(/Elapsed \(wall clock\) time \(h:mm:ss or m:ss\): (\d+):(\d+)\.(\d+)/) {
      # Convert m:ss to seconds
      $results->{'runtime'} = ($1 * 60) + $2;
    } elsif(/Maximum resident set size \(kbytes\): (\d+)/) {
      # Convert kilobytes to gigabytes, truncate to two decimal places
      $results->{'rss'} = round_two($1 / 1024 / 1024)
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
    } elsif(/^\|\-\-\s+System Memory Throughput\(MB\/s\)\:\s+(\d+)\.(\d\d)\s+\-\-\|$/) {
      push(@total_bandwidth, $1 + ($2 / 100));
    }
  }
  close($file);

  # Now aggregate the results into single numbers
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

1; # Truthiest module there is
