#!/bin/bash

rm /tmp/*context*
cat /home/macslayer/mbi/* | ./all/convert_mbi.pl \
  /home/macslayer/knl_contexts.txt \
  /home/macslayer/aep_contexts.txt \
  /home/macslayer/results/qmcpack/small_aep/pebs_128/i0/stdout.txt \
  /home/macslayer/aep_mbi
