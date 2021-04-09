#!/bin/bash

sudo mount -t tmpfs none /sys/fs/cgroup
sudo mkdir /sys/fs/cgroup/unified
sudo mount -t cgroup2 none /sys/fs/cgroup/unified
sudo mkdir /sys/fs/cgroup/unified/0
echo "+memory" | sudo tee /sys/fs/cgroup/unified/cgroup.subtree_control
