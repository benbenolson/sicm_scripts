#!/bin/bash

rm *.OU *.ER
ls | grep -P ".*\.e\d\d\d\d" | xargs rm
ls | grep -P ".*\.o\d\d\d\d" | xargs rm
