#!/usr/bin/perl
# stdin is the MBI results from the KNL
# First argument is the `contexts.txt` file from the KNL
# Second argument is the `contexts.txt` file from the AEP machine
# Third argument is the PEBS output on the AEP machine
# Fourth argument is the directory to output new MBI data to

use strict; use warnings;
use Data::Dumper;

# Takes an array, leaves only unique elements
sub uniq {
  my %seen;
  grep !$seen{$_}++, @_;
}

# Takes an input file and an output file
# Reads in a `contexts.txt`, demangles it, and caches the result in the output file.
sub get_context {
  my $context_filename = shift;
  my $cache_filename = shift;
  my $reverse = shift;
  my $cache_file;
  my %mangled_context;
  my %demangled_context;
  my $cur_context;

  $Data::Dumper::Purity = 1;

  # If we find the cache file already exists
  if(-e $cache_filename) {
    print("Reading $context_filename from the cache file...\n");
    open(my $cache_file, $cache_filename);
    my $str = do { local $/; <$cache_file> };
    close($cache_file);
    %demangled_context = eval($str);
  } else {
    # Read the context into memory
    print("Reading in ${context_filename}...\n");
    my $cur_site = -1;
    open(my $context_file, $context_filename);
    foreach(<$context_file>) {
      if(/^(\d+) (.*)$/s) {
        if($cur_site != -1) {
          # If we've just finished up another site
          # Demangle the context and put it in the hash
          push(@{$mangled_context{$cur_context}}, $cur_site);
        }
        $cur_site = $1;
        $cur_context = $2;
      } elsif($cur_site ne -1) {
        if(not /^\s*$/) {
          $cur_context .= $_;
        }
      }
    }
    push(@{$mangled_context{$cur_context}}, $cur_site);

    # Demangling time, print out a progress bar
    print("Demangling ${context_filename}...\n");
    my $progress = 0;
    my $raw_progress = 0;
    my $prev_progress = 0;
    my @unique_sites;
    foreach(keys(%mangled_context)) {
      $cur_context = $_;
      $prev_progress = $progress;
      $progress = int($raw_progress / keys(%mangled_context) * 10);
      if($progress gt $prev_progress) {
        print("[");
        print('|' x $progress);
        print(' ' x (10 - $progress));
        print("]\n");
      }
      (my $tmp_context = $cur_context) =~ s/__compass\d+//g;
      my $tmp_demangled_context = `echo '$tmp_context' | c++filt -n`;
      @unique_sites = uniq(@{$mangled_context{$cur_context}});
      if($reverse eq 0) {
        # Context is the key, site ID is the value
        $demangled_context{$tmp_demangled_context} = [@unique_sites];
      } else {
        # Site ID is the key, context is the value
        foreach(@unique_sites) {
          $demangled_context{$_} = $tmp_demangled_context;
        }
      }
      $raw_progress += 1;
    }
    open(my $cache_file, ">", $cache_filename);
    print($cache_file Data::Dumper->Dump([\%demangled_context], [qw(*demangled_context)]));
    close($cache_file);
  }

  return \%demangled_context;
}

# Arguments
my $knl_context_filename = $ARGV[0];
my $aep_context_filename = $ARGV[1];
my $aep_pebs_filename = $ARGV[2];
my $aep_mbi_dirname = $ARGV[3];

# Context
my %knl_context;
my %aep_context;

# PEBS data
my $aep_pebs_file;
my $num_aep_pebs_sites;
my %aep_pebs_sites;

# MBI data
my %mbi;

# Matches
my $num_matches;
my @no_match_sites;
my %matches;

# Misc
my $cur_site = -1;

# Read the MBI data into the %mbi hash
while(<STDIN>) {
  if(/===== MBI RESULTS FOR SITE (\d+) =====/) {
    $cur_site = $1;
    $mbi{$cur_site} = $_;
  }
  if($cur_site ne -1) {
    if(/Average bandwidth: ([\d\.]+) MB\/s/) {
      $mbi{$cur_site} .= $_;
    } elsif(/Maximum bandwidth: ([\d\.]+) MB\/s/) {
      $mbi{$cur_site} .= $_;
    } elsif(/===== END MBI RESULTS =====/) {
      $mbi{$cur_site} .= $_;
      $cur_site = -1;
    }
  }
}

# Read in the AEP PEBS sites
$cur_site = -1;
open($aep_pebs_file, $aep_pebs_filename);
foreach(<$aep_pebs_file>) {
  if(/1 sites: (\d+)/) {
    $cur_site = $1;
    $aep_pebs_sites{$cur_site} = -1;
  } elsif($cur_site ne -1) {
    if(/Accesses: (\d+)/) {
      $aep_pebs_sites{$cur_site} = $1;
    }
  }
}
$num_aep_pebs_sites = keys(%aep_pebs_sites);

# Read in the context
my $knl_context_ref = get_context($knl_context_filename, "/tmp/knl_demangled_context.txt", 0);
my $aep_context_ref = get_context($aep_context_filename, "/tmp/aep_demangled_context.txt", 1);
%knl_context = %$knl_context_ref;
%aep_context = %$aep_context_ref;

# Now match up the context
my $cur_aep_context;
foreach(keys(%aep_pebs_sites)) {
  $cur_aep_context = $aep_context{$_};
  if(exists($knl_context{$cur_aep_context})) {
    $matches{$_} = $knl_context{$cur_aep_context};
  } else {
    push(@no_match_sites, $_);
  }
}
print("Matches: " . keys(%matches) . "/" . keys(%aep_pebs_sites) . "\n");

my $aep_mbi_file;
my $aep_site;
my $aep_mbi_filename;
foreach(keys(%matches)) {
  $aep_site = $_;
  $aep_mbi_filename = $aep_mbi_dirname . "/$aep_site.txt";
  open($aep_mbi_file, ">", $aep_mbi_filename);
  foreach my $match(@{$matches{$_}}) {
    if(exists($mbi{$match})) {
      $mbi{$match} =~ s/===== MBI RESULTS FOR SITE (\d+) =====/===== MBI RESULTS FOR SITE $aep_site =====/g;
      print($aep_mbi_file $mbi{$match});
    }
  }
  close($aep_mbi_file);
}
