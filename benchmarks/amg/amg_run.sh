#!/bin/bash

SMALL="./amg -problem 2 -n 180 180 180"
MEDIUM="./amg -problem 2 -n 340 340 340"
LARGE="./amg -problem 2 -n 520 520 520"
HUGE="./amg -problem 2 -n 600 600 600"

function amg_prerun {
  export SH_MAX_SITES="8800"
}
