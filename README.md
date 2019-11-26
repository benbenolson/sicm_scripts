SICM Scripts
============

These are a set of scripts to run various benchmarks with SICM, for testing.
They assume that you have two environment variables set, but not anything else.

The four environment variables that you should place in your environment are:
```
export SICM_DIR="foo"
export SCRIPTS_DIR="foo"
export BENCH_DIR="foo"
export SPACK_DIR="foo"
export RESULTS_DIR="foo"
```
The first is the location where SICM is installed. The second is where this
repository is installed. The third is where the benchmarks are installed.
The fourth is where Spack is installed.
These four paths are necessary to link SICM and the scripts
together, especially when using a queueing system that requires absolute directories.
They are also necessary due to the decoupling of SICM from these high-level scripts.

To start, simply run `source setup.sh` to compile and install GCC, and set the
new compiler up with Spack. This is so that you can be guaranteed for the SICM
compile to succeed, since I've tried compiling it with GCC 7.2.0 on many
systems.  Unfortunately, this script requires being `source`d, since the module
command doesn't seem to work properly from within this shell. Once you've done
that, you can run `./build.sh` to compile SICM itself. Since it depends on LLVM,
this will take a while.

https://github.com/lanl/SICM.git (high_dev branch)
https://github.com/benbenolson/sicm_scripts.git
https://gitlab.com/molson5/sicm-benchmarks.git
https://github.com/benbenolson/spack.git
