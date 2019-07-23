#!/usr/bin/env perl
package graph;
# This module generates jgraph code, then uses jgraph
# to generate a postscript file of a graph.
my $jgraph = "$ENV{'SCRIPTS_DIR'}/tools/jgraph/jgraph -P ";

# Export functions in this module
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(graph);

use Data::Dumper qw(Dumper);
use File::Temp qw/ tempfile /;

my @colors = (
  "1.00000000000000000000 .70196078431372549019 0",
  ".50196078431372549019 .24313725490196078431 .45882352941176470588",
  "1.00000000000000000000 .40784313725490196078 0",
  ".65098039215686274509 .74117647058823529411 .84313725490196078431",
  ".75686274509803921568 0 .12549019607843137254",
  ".80784313725490196078 .63529411764705882352 .38431372549019607843",
  ".50588235294117647058 .43921568627450980392 .40000000000000000000",
  "0 .49019607843137254901 .20392156862745098039",
  ".96470588235294117647 .46274509803921568627 .55686274509803921568",
  "0 .32549019607843137254 .54117647058823529411",
  "1.00000000000000000000 .47843137254901960784 .36078431372549019607",
  ".32549019607843137254 .21568627450980392156 .47843137254901960784",
  "1.00000000000000000000 .55686274509803921568 0",
  ".70196078431372549019 .15686274509803921568 .31764705882352941176",
  ".95686274509803921568 .78431372549019607843 0",
  ".49803921568627450980 .09411764705882352941 .05098039215686274509",
  ".57647058823529411764 .66666666666666666666 0",
  ".34901960784313725490 .20000000000000000000 .08235294117647058823",
  ".94509803921568627450 .22745098039215686274 .07450980392156862745",
  ".13725490196078431372 .17254901960784313725 .08627450980392156862",
);

# This function generates a line graph of PEBS event totals over time, per arena.
# It selects the first event (essentially random), so only use one event.
# It expects PEBS data as input.
sub per_interval_per_site_event_graph {
  my $results_ref = shift;
  my %results = %$results_ref;
  my $jgraph_code;


  my @sites = keys(%results);
  my $first_site = (keys %results)[0];
  my $event = (keys %{$results{$first_site}{'events'}})[0];
  my $max_val = 0;
  my $max_interval = 2000;
  my $i = 0;

  # We need the sites to be sorted by their size
  my @sorted_sites = sort { $results{$b}{'events'}{$event}{'total'} <=> $results{$a}{'events'}{$event}{'total'} } keys %results;
  my @top_sites = @sorted_sites[0..10];
  foreach my $site(@top_sites) {
    print(STDERR "$site $results{$site}{'events'}{$event}{'total'}\n");
  }

  # Determine the maximum value
  foreach my $site(@top_sites) {
    $i = 0;
    foreach(@{$results{$site}{'events'}{$event}{'intervals'}}) {
      if($i > $max_interval) {
        last;
      }
      if($_ > $max_val) {
        $max_val = $_;
      }
      $i++;
    }
  }
  print(STDERR "Maximum value: $max_val\n");

  $jgraph_code = "newgraph\n";
  $jgraph_code .= "xaxis size 5.666 min 0 max $num_intervals
  hash_labels fontsize 7
  label fontsize 8 : Intervals\n";
  $jgraph_code .= "yaxis size 2 min 0 max $max_val
  hash_labels fontsize 7
  label fontsize 8 : Accesses\n";

  my $color_index = 0;
  my $color;
  foreach my $site(@top_sites) {
    if(not defined($colors[$color_index])) {
      print(STDERR "Ran out of colors!\n");
      last;
    }
    $color = $colors[$color_index];
    $jgraph_code .= "newcurve marktype none linetype solid\n";
    $jgraph_code .= "color $color\n";
    $jgraph_code .= "pts\n";
    my $i = 0;
    foreach(@{$results{$site}{'events'}{$event}{'intervals'}}) {
      if($i > $max_interval) {
        last;
      }
      $jgraph_code .= "$i $_\n";
      $i++;
    }
    $color_index++;
  }
  

  my ($fh, $filename) = tempfile();
  print($fh $jgraph_code);
  system("$jgraph $filename");
}

# This function generates a line graph of PEBS event totals over time
# It expects PEBS data as input.
sub per_interval_total_event_graph {
  my $results_ref = shift;
  my %results = %$results_ref;
  my $jgraph_code;

  # This is going to store the per-event totals
  # event => (list of a total for each interval)
  my %totals;

  # One line per event. Figure out the events from the first site.
  my @sites = keys(%results);
  my $num_intervals;
  my $max_val = 0;
  foreach my $event (keys(%{$results{$sites[0]}{'events'}})) {
    $num_intervals = $results{$sites[0]}{'num_intervals'};
    $totals{$event} = ();
    for my $interval(0..$num_intervals) {
      # Sum up this interval's values from each of the sites
      my $sum = 0;
      foreach my $site (@sites) {
        $sum += $results{$site}{'events'}{$event}{'intervals'}[$interval];
      }
      push(@{$totals{$event}}, $sum);
      if($sum > $max_val) {
        $max_val = $sum;
      }
    }
  }

  $jgraph_code = "newgraph\n";
  $jgraph_code .= "xaxis size 5.666 min 0 max $num_intervals
  hash_labels fontsize 7
  label fontsize 8 : Intervals\n";
  $jgraph_code .= "yaxis size 2 min 0 max $max_val
  hash_labels fontsize 7
  label fontsize 8 : Accesses\n";

  foreach my $event(keys(%totals)) {
    $jgraph_code .= "newcurve marktype none linetype solid\n";
    $jgraph_code .= "pts\n";
    my $i = 0;
    foreach(@{$totals{$event}}) {
      $jgraph_code .= "$i $_\n";
      $i++;
    }
  }

  # Write the jgraph code to a temporary file
  my ($fh, $filename) = tempfile();
  print($fh $jgraph_code);
  system("$jgraph $filename");
}

# This function plots per-site RSS, one plot per benchmark.
# It expects PEBS data as input.
sub per_site_rss_graph {
  my $results_ref = shift;
  my %results = %$results_ref;
  my $jgraph_code;
  my $x_axis_labels;
  my $i;

  # We need the sites to be sorted by their size
  my @sorted_sites = sort { $results{$a}{'peak_rss'} <=> $results{$b}{'peak_rss'} } keys %results;
  foreach my $site(@sorted_sites) {
    print(STDERR "$site $results{$site}{'peak_rss'}\n");
  }

  # Find out the limits of the x-axis
  # That is, what's the minimum and maximum site ID?
  my $min_site = 999999999;
  my $max_site = 0;
  foreach my $site(keys(%results)) {
    if($site > $max_site) {
      $max_site = $site;
    }
    if($site < $min_site) {
      $min_site = $site;
    }
  }
  $max_site += 1;
  $min_site -= 1;

  # Find out the limits of the y-axis
  # That is, what's the maximum RSS of a site?
  my $max_rss = 0;
  foreach my $site(keys(%results)) {
    if(($results{$site}{'peak_rss'} / 1024 / 1024) > $max_rss) {
      $max_rss = $results{$site}{'peak_rss'} / 1024 / 1024;
    }
  }
  my $nearest = $max_rss / 200;
  $nearest += 1;
  $nearest *= 200;
  $max_rss = $nearest;

  # Generate the hash labels and ticks for the x axis
  my $x_axis_labels = "";
  $i = 1;
  foreach my $site(@sorted_sites) {
    $x_axis_labels .= "  hash_at $i hash_label at $i : $site\n";
    $i += 1;
  }

  # Generate the hash labels and ticks for the y axis
  my $y_axis_labels = "";
  $i = 0;
  while($i <= $max_rss) {
    $y_axis_labels .= "  hash_at $i hash_label at $i : $i\n";
    $i += 400;
  }
  $max_rss += 200;

  # The axes
  $jgraph_code = "newgraph\n";
  $jgraph_code .= "xaxis size 5.666 min $min_site max $max_site
  no_auto_hash_labels no_auto_hash_marks
  hash_labels fontsize 7
  label fontsize 8 : Sites\n";
  $jgraph_code .= $x_axis_labels;
  $jgraph_code .= "yaxis size 2 min 0 max $max_rss
  no_auto_hash_labels no_auto_hash_marks
  hash_labels fontsize 7
  label fontsize 8 : Peak RSS (MB)\n";
  $jgraph_code .= $y_axis_labels;

  # One bar for each site
  $i = 1;
  foreach my $site(@sorted_sites) {
    my $peak_rss_mb = $results{$site}{'peak_rss'} / 1024 / 1024;
    $jgraph_code .= "newcurve
    marktype xbar cfill .26 .62 .82 marksize 0.8 4
    pts 
    $i $peak_rss_mb\n";
    $i += 1;
  }

  my ($fh, $filename) = tempfile();
  print($fh $jgraph_code);
  system("$jgraph $filename");
}

# Just forwards graph calls to the appropriate graph function
sub graph {
  my $results_ref = shift;
  my %results = %$results_ref;
  my $graph = shift;

  if($graph eq 'per_site_rss') {
    # Generates one plot per config/bench combination
    foreach my $cfg(keys(%results)) {
      foreach my $bench(keys(%{$results{$cfg}})) {
        per_site_rss_graph($results{$cfg}{$bench}{'sites'});
      }
    }
  } elsif($graph eq 'per_interval_total_event') {
    # Generates one plot per config/bench combination
    foreach my $cfg(keys(%results)) {
      foreach my $bench(keys(%{$results{$cfg}})) {
        per_interval_total_event_graph($results{$cfg}{$bench}{'sites'});
      }
    }
  } elsif($graph eq 'per_interval_per_site_event') {
    # Generates one plot per config/bench combination
    foreach my $cfg(keys(%results)) {
      foreach my $bench(keys(%{$results{$cfg}})) {
        per_interval_per_site_event_graph($results{$cfg}{$bench}{'sites'});
      }
    }
  }
}

1; # Truthiest module there is
