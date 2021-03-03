#!/bin/bash

# Hack for figuring out the PID for PageDrift
export BENCH_EXE_NAME="./lulesh2.0"

export SMALL="./lulesh2.0 -s 220 -i 12 -r 11 -b 0 -c 64 -p"
export MEDIUM="./lulesh2.0 -s 340 -i 12 -r 11 -b 0 -c 64 -p"
export LARGE="./lulesh2.0 -s 420 -i 12 -r 11 -b 0 -c 64 -p"
export OLD="./lulesh2.0 -s 220 -i 5 -r 11 -b 0 -c 64 -p"

export SMALL_AEP="./lulesh2.0 -s 220 -i 12 -r 11 -b 0 -c 64 -p"
export MEDIUM_AEP="./lulesh2.0 -s 400 -i 6 -r 11 -b 0 -c 64 -p"
#export LARGE_AEP="./lulesh2.0 -s 780 -i 3 -r 11 -b 0 -c 64 -p"
export LARGE_AEP="./lulesh2.0 -s 690 -i 3 -r 11 -b 0 -c 64 -p"
#export HUGE_AEP="./lulesh2.0 -s 780 -i 3 -r 11 -b 0 -c 64 -p"
