SICM Scripts
============

These are a set of scripts to run various benchmarks with SICM, for testing.
They assume that you have two environment variables set, but not anything else.
You can optionally use the directory `pbs_scripts` to use a command such as
`qsub` to launch the scripts as PBS jobs.

The four environment variables that you should place in your environment are:
```
export SICM_DIR="foo"
export SCRIPTS_DIR="foo"
export BENCH_DIR="foo"
export SPACK_DIR="foo"
```
The first is the location where SICM is installed. The second is where this
repository is installed. The third is where the benchmarks are installed.
The fourth is where Spack is installed.
These four paths are necessary to link SICM and the scripts
together, especially when using a queueing system that requires absolute directories.
They are also necessary due to the decoupling of SICM from these high-level scripts.
