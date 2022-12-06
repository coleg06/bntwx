#!/bin/bash
# Created by BNTWX

name="$(echo $2)"
size="$(echo $1)"

qemu-img create -f qcow2 -o preallocation=off /mnt/nfs_share/bntwx/"$(echo $name)".qcow2 $size
sudo chmod 777 /mnt/nfs_share/bntwx/"$(echo $name)".qcow2
