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

# Context
my $context;
my $site;
my %input_context;
my %output_context;
my $input_context_ref;
my $output_context_ref;

# PEBS
my %input_pebs;

# Matches
my $num_matches;
my @no_match_sites;
my %matches;

# Misc
my $cur_site = -1;

# Read in PEBS data for each
my $input_pebs_ref = read_pebs($input_pebs_filename);
%input_pebs = %$input_pebs_ref;

# Read in the context for each
$input_context_ref = get_context($input_context_filename, "/tmp/input_demangled_context.txt", 1);
$output_context_ref = get_context($output_context_filename, "/tmp/output_demangled_context.txt", 0);
%input_context = %$input_context_ref;
%output_context = %$output_context_ref;

# Match up the demangled sites
my @output_sites;
foreach my $input_site(keys(%input_pebs)) {
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
    print("WARNING: Couldn't find a match for site ${input_site}.\n");
  }
}

# Now output some PEBS with the new site numbers
print("===== PEBS RESULTS =====\n");
my @used_output_sites;
foreach my $input_site(keys(%input_pebs)) {
  my $output_site;

  # If there's a match for it, continue on
  if(not exists $matches{$input_site}) {
    next;
  }

  # If this specific numerical ID is already a match for this input site, 
  # use that. Otherwise, grab a random one and use that.
  if($input_site ~~ @{$matches{$input_site}}) {
    $output_site = $input_site;
    push(@used_output_sites, $output_site);
  } else {
    foreach(@{$matches{$input_site}}) {
      # If the site isn't already used, grab it randomly
      if(not ($_ ~~ @{$matches{$input_site}})) {
        $output_site = $_;
      }
    }
  }

  # Output the PEBS data
  print("1 sites: $output_site\n");
  print("  Accesses: $input_pebs{$input_site}{'accesses'}\n");
  print("  Peak RSS: $input_pebs{$input_site}{'peak_rss'}\n");
}
print("===== END PEBS RESULTS =====\n");
