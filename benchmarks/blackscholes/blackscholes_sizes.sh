#!/bin/bash

export MEDIUM_AEP="./blackscholes ${OMP_NUM_THREADS} in_100M.txt prices.txt"
export LARGE_AEP="./blackscholes ${OMP_NUM_THREADS} in_1B.txt prices.txt"

function blackscholes_prerun {
}
