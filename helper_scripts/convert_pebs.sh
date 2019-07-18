#!/bin/bash

export PERLLIB="$(readlink -f ./all):$PERLLIB"

./all/convert_pebs.pl "$@"
