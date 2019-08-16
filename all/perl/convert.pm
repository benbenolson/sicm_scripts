#!/usr/bin/perl
package convert;
use strict; use warnings;
use Data::Dumper;
use Storable;

# Export functions in this module
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(uniq
                 get_context
                 read_pebs);

# Takes an array, leaves only unique elements
sub uniq {
  my %seen;
  grep !$seen{$_}++, @_;
}

# Takes an input file and an output file
# Reads in a `contexts.txt`, demangles it, and caches the result in the output file.
sub get_context {
  my ($context_filename, $cache_filename, $reverse, $use_cache) = @_;
  my %demangled_context;
  my %mangled_context;
  my $cur_context;
  my $writing_cache = 0;
  
  # Return value
  my %rethash;
  my $retref = \%rethash;

  # If we find the cache file already exists
  if((-e $cache_filename) and ($use_cache)) {
    print("Reading $context_filename from the cache file...\n");
    $retref = retrieve($cache_filename);
  } else {
    $writing_cache = 1;
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
        # Add the site to the context if it's:
        # 1. Not a blank line
        if((not /^\s*$/)) {#and (not /^.*!dbg.*$/) and (not /^\s*%\d+\s+.*$/)) {
          $cur_context .= $_;

          # Remove any platform-specific stuff from the strings
          # Also remove any debugging label numbers (an integer starting with an exclamation point)
          $cur_context =~ s/\.omp_outlined\.\.(\d+)\.\d+/\.omp_outlined\.\.$1/g;
          $cur_context =~ s/i32 \d+,/ /g;
          $cur_context =~ s/%\d+/ /g;
          $cur_context =~ s/\s+!\d+\s+/ /g;
          $cur_context =~ s/\s+\S+x86_64-linux-gnu\S+\s+/ /g;
          $cur_context =~ s/\s+\S+x86_64-redhat-linux\S+\s+/ /g;
        }
      }
    }
    push(@{$mangled_context{$cur_context}}, $cur_site);

    # Demangling time, print out a progress bar
    my $num_sites = %mangled_context;
    print("Demangling ${context_filename} (${num_sites} sites)...\n");
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
      #my $tmp_demangled_context = `echo '$tmp_context' | c++filt -n`;
      my $tmp_demangled_context = $tmp_context;
      @unique_sites = uniq(@{$mangled_context{$cur_context}});
      push(@{$demangled_context{$tmp_demangled_context}}, @unique_sites);
      $raw_progress += 1;
    }
    print("Finished demangling.\n");

    # If the user chose to invert it, do that
    if($reverse) {
      my $key; my $value;
      while(($key, $value) = each %demangled_context) {
        foreach(@$value) {
          $retref->{$_} = $key;
        }
      }
    } else {
      my $key; my $value;
      while(($key, $value) = each %demangled_context) {
        $retref->{$key} = $value;
      }
    }

    store($retref, $cache_filename);
  }
  
  return $retref;
}

# Read in PEBS information
# First argument is the filename of the PEBS output
# Outputs a hash filled with the PEBS info
sub read_pebs {
  my $pebs_filename = shift;
  my %pebs_sites;
  my $cur_site = -1;
  open(my $pebs_file, $pebs_filename);
  foreach(<$pebs_file>) {
    if(/1 sites: (\d+)/) {
      $cur_site = $1;
    } elsif($cur_site ne -1) {
      if(/Accesses: (\d+)/) {
        $pebs_sites{$cur_site}{'accesses'} = $1;
      } elsif(/Peak RSS: (\d+)/) {
        $pebs_sites{$cur_site}{'peak_rss'} = $1;
      }
    }
  }
  return \%pebs_sites;
}
