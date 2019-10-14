#!/bin/bash

. $SPACK_DIR/share/spack/setup-env.sh
spack load gflags%clang@6.0.1
spack load snappy%clang@6.0.1

DB_DIR="$BENCH_DIR/rocksdb/run/db_${SIZE}"
NUM_KEYS="20000000"
VALUE_SIZE="800"
BLOCK_SIZE="4096"
MAX_BYTES_FOR_LEVEL_BASE="10485760"
CACHE_SIZE="34359738368"
DURATION="200"
OPEN_FILES="-1"
overlap=10
mcz=2
del=300000000
levels=6
ctrig=4
stop=12
wbn=3
mbc=20
mb=67108864
wbs=134217728
sync=0
si=0

function rocksdb_prerun {
  if [[ ! -d ${DB_DIR} ]]; then
    echo "Creating RockDB database at '${DB_DIR}' before run..."
  fi
#  ./db_bench \
#    --benchmarks=fillseq \
#    --disable_seek_compaction=1 \
#    --mmap_read=1 \
#    --statistics=1 \
#    --histogram=1 \
#    --num=${NUM_KEYS} \
#    --threads=${OMP_NUM_THREADS} \
#    --value_size=${VALUE_SIZE} \
#    --block_size=${BLOCK_SIZE} \
#    --cache_size=${CACHE_SIZE} \
#    --bloom_bits=10 \
#    --cache_numshardbits=6 \
#    --open_files=${OPEN_FILES} \
#    --verify_checksum=1 \
#    --db=$DB_DIR \
#    --sync=$sync \
#    --disable_wal=1 \
#    --compression_type=none \
#    --stats_interval=$si \
#    --compression_ratio=0.5 \
#    --write_buffer_size=$wbs \
#    --target_file_size_base=$mb \
#    --max_write_buffer_number=$wbn \
#    --max_background_compactions=$mbc \
#    --level0_file_num_compaction_trigger=$ctrig \
#    --level0_slowdown_writes_trigger=$delay \
#    --level0_stop_writes_trigger=$stop \
#    --num_levels=$levels \
#    --delete_obsolete_files_period_micros=$del \
#    --min_level_to_compress=$mcz \
#    --stats_per_interval=1 \
#    --max_bytes_for_level_base=${MAX_BYTES_FOR_LEVEL_BASE} \
#    --use_existing_db=0 &> /dev/null

  # Trick to get RocksDB to adhere to OpenMP variable
  export COMMAND="${COMMAND} --threads=${OMP_NUM_THREADS}"
}

export SMALL_AEP="./db_bench \
  --benchmarks=readrandom \
  --disable_seek_compaction=1 \
  --mmap_read=1 \
  --mmap_write=0 \
  --statistics=0 \
  --histogram=0 \
  --num=${NUM_KEYS} \
  --value_size=${VALUE_SIZE} \
  --block_size=${BLOCK_SIZE} \
  --cache_size=${CACHE_SIZE} \
  --bloom_bits=10 \
  --cache_numshardbits=6 \
  --open_files=${OPEN_FILES} \
  --verify_checksum=0 \
  --db=$DB_DIR \
  --sync=$sync \
  --disable_wal=1 \
  --duration=${DURATION} \
  --compression_type=none \
  --stats_interval=$si \
  --write_buffer_size=$wbs \
  --target_file_size_base=$mb \
  --max_write_buffer_number=$wbn \
  --max_background_compactions=$mbc \
  --level0_file_num_compaction_trigger=$ctrig \
  --level0_stop_writes_trigger=$stop \
  --num_levels=$levels \
  --min_level_to_compress=$mcz \
  --stats_per_interval=1 \
  --max_bytes_for_level_base=${MAX_BYTES_FOR_LEVEL_BASE} \
  --perf_level=0 \
  --use_existing_db=1"
