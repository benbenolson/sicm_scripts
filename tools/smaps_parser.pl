#!/usr/bin/perl

my $not_objmap = 0;
my $objmap = 0;
my $val = 0;

while(<>) {
  if(/Rss:\s+(\d+) kB/) {
    $val = $1;
  } elsif(/ObjectMap: No/) {
    $not_objmap += $val;
  } elsif(/ObjectMap: Yes/) {
    $objmap += $val;
  }
}

print("OBJMAP: $objmap\n");
print("NOT OBJMAP: $not_objmap\n");
