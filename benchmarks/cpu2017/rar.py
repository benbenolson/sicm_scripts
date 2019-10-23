#!/usr/bin/env python
import sys
import os

def main(args):

  bench = args[1]
  core = bench.split(".")[1].split("_")[0]

  src = ("%s/%s_sizes.sh" % (bench, core))
  dst = ("%s/%s_sizes.sh" % (bench, bench))
  print ("%s --> %s" % (src,dst))
  os.rename(src, dst)

  src = ("%s/%s_build.sh" % (bench, core))
  dst = ("%s/%s_build.sh" % (bench, bench))
  print ("%s --> %s" % (src,dst))
  os.rename(src, dst)

if __name__ == "__main__":
  main(sys.argv)
