#!/bin/bash

./run.sh --bench=603.bwaves_s --size=train --config=pebs --args=128
./run.sh --bench=603.bwaves_s --size=ref --config=pebs --args=128
./run.sh --bench=619.lbm_s --size=train --config=pebs --args=128
./run.sh --bench=619.lbm_s --size=ref --config=pebs --args=128
./run.sh --bench=638.imagick_s --size=train --config=pebs --args=128
./run.sh --bench=638.imagick_s --size=ref --config=pebs --args=128
./run.sh --bench=644.nab_s --size=train --config=pebs --args=128
./run.sh --bench=644.nab_s --size=ref --config=pebs --args=128
./run.sh --bench=649.fotonik3d_s --size=train --config=pebs --args=128
./run.sh --bench=649.fotonik3d_s --size=ref --config=pebs --args=128
./run.sh --bench=654.roms_s --size=train --config=pebs --args=128
./run.sh --bench=654.roms_s --size=ref --config=pebs --args=128
./run.sh --bench=657.xz_s --size=train --config=pebs --args=128
./run.sh --bench=657.xz_s --size=ref --config=pebs --args=128

#./run.sh --memsys --bench=snap --size=medium_aep --config=firsttouch_all_exclusive_device --args=1,3
#./run.sh --memsys --bench=snap --size=medium_aep --config=pebs --args=128
#./run.sh --memsys --bench=snap --size=medium_aep --config=offline_pebs_guided --args=128,medium_aep,hotset,50,1,3
#./run.sh --memsys --bench=snap --size=medium_aep --config=offline_pebs_guided --args=128,medium_aep,hotset,40,1,3
#./run.sh --memsys --bench=snap --size=medium_aep --config=offline_pebs_guided --args=128,medium_aep,hotset,30,1,3
#./run.sh --memsys --bench=snap --size=medium_aep --config=offline_pebs_guided --args=128,medium_aep,hotset,20,1,3
#./run.sh --memsys --bench=snap --size=medium_aep --config=offline_pebs_guided --args=128,medium_aep,hotset,10,1,3
#
#./run.sh --memsys --bench=amg --size=medium_aep --config=firsttouch_all_exclusive_device --args=1,3
#./run.sh --memsys --bench=amg --size=medium_aep --config=pebs --args=128
#./run.sh --memsys --bench=amg --size=medium_aep --config=offline_pebs_guided --args=128,medium_aep,hotset,50,1,3
#./run.sh --memsys --bench=amg --size=medium_aep --config=offline_pebs_guided --args=128,medium_aep,hotset,40,1,3
#./run.sh --memsys --bench=amg --size=medium_aep --config=offline_pebs_guided --args=128,medium_aep,hotset,30,1,3
#./run.sh --memsys --bench=amg --size=medium_aep --config=offline_pebs_guided --args=128,medium_aep,hotset,20,1,3
#./run.sh --memsys --bench=amg --size=medium_aep --config=offline_pebs_guided --args=128,medium_aep,hotset,10,1,3
