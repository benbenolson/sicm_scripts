#!/bin/bash
# Goes to each of the machines in this list and
# aggregates their `results` directories onto this machine

MACHINES=(peru1.eecs.utk.edu peru2.eecs.utk.edu peru3.eecs.utk.edu)

for machine in ${MACHINES[@]}; do
  echo $machine;
done
