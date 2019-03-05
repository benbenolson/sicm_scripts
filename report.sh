#!/bin/bash -l

module load sicm-high-develop-gcc-7.2.0-bz67eff

./all/report.pl "$@"
