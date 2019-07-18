#!/usr/bin/perl
# First argument is the `contexts.txt` file to input
# Second argument is the `contexts.txt` file of the output machine
# Third argument is the PEBS input
# Stdout is the output PEBS

use strict; use warnings;
use Data::Dumper;
use convert;

# Arguments
my $input_context_filename = $ARGV[0];
my $output_context_filename = $ARGV[1];
my $input_pebs_filename = $ARGV[2];
my $output_pebs_filename = $ARGV[3];

# Context
my $context;
my $site;
my %input_context;
my %output_context;
my $input_context_ref;
my $output_context_ref;

# PEBS
my %input_pebs;
my %output_pebs; # Isn't used except for analysis

# Matches
my $num_matches;
my @no_match_sites;
my %matches;

my $num_matched = 0;
my $num_id_matched = 0;
my $num_unmatched = 0;
my $num_surplus = 0;
my $num_guesses = 0;
my $guessed_accesses = 0;
my $guessed_capacity = 0;

# Misc
my $cur_site = -1;

# Read in PEBS data for each
my $input_pebs_ref = read_pebs($input_pebs_filename);
%input_pebs = %$input_pebs_ref;
my $output_pebs_ref = read_pebs($output_pebs_filename);
%output_pebs = %$output_pebs_ref;

# Read in the context for each
$input_context_ref = get_context($input_context_filename, "/tmp/input_demangled_context.txt", 1, 0);
$output_context_ref = get_context($output_context_filename, "/tmp/output_demangled_context.txt", 0, 0);
%input_context = %$input_context_ref;
%output_context = %$output_context_ref;

# Match up the demangled sites
my $unmatched_accesses = 0;
my $unmatched_capacity = 0;
my $total_accesses = 0;
my $total_capacity = 0;
foreach my $input_site(keys(%input_pebs)) {
  # If this site has 0 accesses, ignore it
  if($input_pebs{$input_site}{'accesses'} == 0) {
    next;
  }

  # First check if we can find the site in the input context
  if(not exists $input_context{$input_site}) {
    # The site is in the PEBS output, but not the context
    print("WARNING: Site $input_site isn't in the input context.\n");
    next;
  }
  $context = $input_context{$input_site};

  # Now find the context and which site on the output machine it matches
  if(exists $output_context{$context}) {
    @{$matches{$input_site}} = @{$output_context{$input_context{$input_site}}};
  } else {
    $unmatched_accesses += $input_pebs{$input_site}{'accesses'};
    $unmatched_capacity += $input_pebs{$input_site}{'peak_rss'};
    print("WARNING: Couldn't find a match for site ${input_site} ($input_pebs{$input_site}{'accesses'} accesses).\n");
  }
  $total_accesses += $input_pebs{$input_site}{'accesses'};
  $total_capacity += $input_pebs{$input_site}{'peak_rss'};
}

# Now output some PEBS with the new site numbers
#print("===== PEBS RESULTS =====\n");
my @used_output_sites;
foreach my $input_site(keys(%input_pebs)) {
  my $output_site;

  # If there's no match for it, continue on
  if(not exists $matches{$input_site}) {
    $num_unmatched++;
    next;
  }

  if(scalar(@{$matches{$input_site}}) eq 1) {
    $output_site = $matches{$input_site}[0];
  } elsif(($input_site ~~ @{$matches{$input_site}}) and (defined($output_pebs{$input_site}))) {
    # If the context strings match, the numerical IDs match, *and*
    # the site exists in the destination machine's PEBS.
    $num_id_matched++;
    $output_site = $input_site;
  } else {
    $output_site = -1;
    foreach(@{$matches{$input_site}}) {
      # Grab the first site that isn't used and is in the destination PEBS
      if((not ($_ ~~ @used_output_sites)) and (defined($output_pebs{$_}))) {
        $output_site = $_;
        $guessed_accesses += $input_pebs{$input_site}{'accesses'};
        $guessed_capacity += $input_pebs{$input_site}{'peak_rss'};
        $num_guesses++;
      }
    }
  }

  if($output_site == -1) {
    $num_unmatched++;
    next;
  } else {
    $num_matched++;
    push(@used_output_sites, $output_site);
  }

  # Output the PEBS data
  #print("1 sites: $output_site\n");
  #print("  Accesses: $input_pebs{$input_site}{'accesses'}\n");
  #print("  Peak RSS: $input_pebs{$input_site}{'peak_rss'}\n");
}
#print("===== END PEBS RESULTS =====\n");
#

my $num_output_sites = %output_pebs;
my $num_input_sites = keys(%input_pebs);
my $unmatched_output_accesses = 0;
my $unmatched_output_capacity = 0;
foreach(keys(%output_pebs)) {
  if(not $_ ~~ @used_output_sites) {
    $unmatched_output_accesses += $output_pebs{$_}{'accesses'};
    $unmatched_output_capacity += $output_pebs{$_}{'peak_rss'};
  }
}
print("Stats:\n");
print("  On destination:\n");
print("    Total sites: $num_output_sites\n");
print("    Matched sites: $num_matched\n");
print("    Unmatched accesses: $unmatched_output_accesses\n");
print("    Unmatched capacity: $unmatched_output_capacity\n");
print("  On source:\n");
print("    Total sites: $num_input_sites\n");
print("    ID matched: $num_id_matched\n");
print("    Guessed: $num_guesses\n");
print("    Guessed accesses: $guessed_accesses\n");
print("    Guessed capacity: $guessed_capacity\n");
print("    Unmatched: $num_unmatched\n");
print("    Unmatched accesses: $unmatched_accesses\n");
print("    Unmatched capacity: $unmatched_capacity\n");
