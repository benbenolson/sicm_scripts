#!/bin/bash

./run.sh --memsys --bench=snap --size=medium_aep --config=firsttouch_all_exclusive_device --args=1,3
./run.sh --memsys --bench=snap --size=medium_aep --config=pebs --args=128
./run.sh --memsys --bench=snap --size=medium_aep --config=offline_pebs_guided --args=128,medium_aep,hotset,50,1,3
./run.sh --memsys --bench=snap --size=medium_aep --config=offline_pebs_guided --args=128,medium_aep,hotset,40,1,3
./run.sh --memsys --bench=snap --size=medium_aep --config=offline_pebs_guided --args=128,medium_aep,hotset,30,1,3
./run.sh --memsys --bench=snap --size=medium_aep --config=offline_pebs_guided --args=128,medium_aep,hotset,20,1,3
./run.sh --memsys --bench=snap --size=medium_aep --config=offline_pebs_guided --args=128,medium_aep,hotset,10,1,3

./run.sh --memsys --bench=amg --size=medium_aep --config=firsttouch_all_exclusive_device --args=1,3
./run.sh --memsys --bench=amg --size=medium_aep --config=pebs --args=128
./run.sh --memsys --bench=amg --size=medium_aep --config=offline_pebs_guided --args=128,medium_aep,hotset,50,1,3
./run.sh --memsys --bench=amg --size=medium_aep --config=offline_pebs_guided --args=128,medium_aep,hotset,40,1,3
./run.sh --memsys --bench=amg --size=medium_aep --config=offline_pebs_guided --args=128,medium_aep,hotset,30,1,3
./run.sh --memsys --bench=amg --size=medium_aep --config=offline_pebs_guided --args=128,medium_aep,hotset,20,1,3
./run.sh --memsys --bench=amg --size=medium_aep --config=offline_pebs_guided --args=128,medium_aep,hotset,10,1,3
