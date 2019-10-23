#!/bin/bash

declare -a TEST_OUTPUT=(
  "cpu2006docs.tar-4-0.out"
  "cpu2006docs.tar-4-1.out"
  "cpu2006docs.tar-4-2.out"
  "cpu2006docs.tar-4-3e.out"
  "cpu2006docs.tar-4-4.out"
  "cpu2006docs.tar-4-4e.out"
  "cpu2006docs.tar-1-0.out"
  "cpu2006docs.tar-1-1.out"
  "cpu2006docs.tar-1-2.out"
  "cpu2006docs.tar-1-3e.out"
  "cpu2006docs.tar-1-4.out"
  "cpu2006docs.tar-1-4e.out"
  "cpu2006docs.tar-4-0.err"
  "cpu2006docs.tar-4-1.err"
  "cpu2006docs.tar-4-2.err"
  "cpu2006docs.tar-4-3e.err"
  "cpu2006docs.tar-4-4.err"
  "cpu2006docs.tar-4-4e.err"
  "cpu2006docs.tar-1-0.err"
  "cpu2006docs.tar-1-1.err"
  "cpu2006docs.tar-1-2.err"
  "cpu2006docs.tar-1-3e.err"
  "cpu2006docs.tar-1-4.err"
  "cpu2006docs.tar-1-4e.err"
)
declare -a TRAIN_OUTPUT=(
  "input.combined-40-8.out"
  "IMG_2560.cr2-40-4.out"
  "input.combined-40-8.err"
  "IMG_2560.cr2-40-4.err"
)
declare -a REF_OUTPUT=(
  "cpu2006docs.tar-6643-4.out"
  "cld.tar-1400-8.out"
  "cpu2006docs.tar-6643-4.err"
  "cld.tar-1400-8.err"
)

