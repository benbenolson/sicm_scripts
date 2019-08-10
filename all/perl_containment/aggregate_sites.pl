#!/usr/bin/perl
use strict; use warnings;
use Data::Dumper;

my %sites;
my @print_after;

# Read in the PEBS sites
my $cur_site = -1;
foreach(<STDIN>) {
  if(/===== PEBS RESULTS =====/) {
  } elsif(/Totals: (\d+) \/ (\d+)/) {
    push(@print_after, $_);
  } elsif(/Number of RSS samples: (\d+)/) {
    push(@print_after, $_);
  } elsif(/===== END PEBS RESULTS =====/) {
  } elsif(/1 sites: (\d+)/) {
    $cur_site = $1;
    $sites{$cur_site}{'accesses'} = 0;
    $sites{$cur_site}{'accesses_per_sample'} = 0;
    $sites{$cur_site}{'peak_rss'} = 0;
    $sites{$cur_site}{'average_rss'} = 0;
  } elsif($cur_site ne -1) {
    if(/Accesses: (\d+)/) {
      $sites{$cur_site}{'accesses'} += $1;
    } elsif(/Accesses per sample: ([\d\.]+)/) {
      $sites{$cur_site}{'accesses_per_sample'} += $1;
    } elsif(/Peak RSS: (\d+)/) {
      $sites{$cur_site}{'peak_rss'} += $1;
    } elsif(/Average RSS: (\d+)/) {
      $sites{$cur_site}{'average_rss'} += $1;
    } else {
      print();
    }
  } else {
    print();
  }
}

# Print them out, aggregated
print("===== PEBS RESULTS =====\n");
foreach(keys(%sites)) {
  $cur_site = $_;
  print("1 sites: $cur_site\n");
  print("  Accesses: $sites{$cur_site}{'accesses'}\n");
  print("  Accesses per sample: $sites{$cur_site}{'accesses_per_sample'}\n");
  print("  Peak RSS: $sites{$cur_site}{'peak_rss'}\n");
  print("  Average RSS: $sites{$cur_site}{'average_rss'}\n");
}
foreach(@print_after) {
  print();
}
print("===== END PEBS RESULTS =====\n");
