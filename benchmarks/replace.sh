#!/bin/bash

for file in `find snap/ -name "snap_firsttouch_*"`; do
  NEWNAME=$(echo $file | awk '{gsub(/snap/, "pennant"); print;}');
	echo $NEWNAME;
  cat $file | awk '{gsub(/snap/, "pennant"); print;}' > $NEWNAME;
  chmod +x $NEWNAME;
done
