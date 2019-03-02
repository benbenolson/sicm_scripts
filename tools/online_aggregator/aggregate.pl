#!/usr/bin/env perl
use Array::Utils qw(:all);

my $init_time;
my $deinit_time;
my $total_time;
my @interval_gaps;
my @offline_hotset;
my @is_same_as_offline;
my @hotset_diffs;
my $boolean;

open(my $online_fh, "<", $ARGV[0]);
open(my $offline_fh, "<", $ARGV[1]);

while(<$offline_fh>) {
  @offline_hotset = split(" ", $_);
  break;
}

while(<$online_fh>) {
  if(/Online init: (\d+)/) {
    $init_time = $1;
    push(@interval_gaps, 0);
    push(@is_same_as_offline, 0);
    push(@hotset_diffs, ());
  } elsif(/Online deinit: (\d+)/) {
    $deinit_time = $1;
    push(@interval_gaps, $1 - $init_time - $interval_gaps[-1]);
    push(@is_same_as_offline, $boolean);
    push(@hotset_diffs, @hotset_diff);
  } elsif(/Timestamp: (\d+)/) {
    push(@interval_gaps, $1 - $init_time - $interval_gaps[-1]);
    push(@is_same_as_offline, $boolean);
    push(@hotset_diffs, @hotset_diff);
  } elsif(/Hot sites: ([\d ]+)/) {
    my @current_hotset = split(" ", $1);
    if(!array_diff(@current_hotset, @offline_hotset)) {
      $boolean = 1;
    } else {
      $boolean = 0;
    }
    my @hotset_diff = array_diff(@offline_hotset, @current_hotset);
    print("Difference between the offline and online:\n");
    foreach(@hotset_diff) {
      print("$_ ");
    }
    print("\n");
  }
}

$total_time = $deinit_time - $init_time;

print("Total runtime: ${total_time}s\n");
print("Offline hotset: ");
foreach(@offline_hotset) {
  print("$_ ");
}
print("\n");
print("Gaps:\n");
for my $i(0 .. $#interval_gaps) {
  printf("  %4u ", $interval_gaps[$i]);
  printf("  %1u ", $is_same_as_offline[$i]);
  printf("(");
  foreach(@hotset_diffs[$i]) {
    printf("$_ ");
  }
  printf(")\n");
}
print("\n");
