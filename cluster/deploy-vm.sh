#!/bin/bash
# Created by BNTWX

name="$(echo $1)"
memory="$(echo $2)"
vcpus="$(echo $3)"

if [ $vcpus = "1" ]
then
  cores="1"
  threads="0"
fi

if [ $vcpus = "2" ]
then
  cores="2"
  threads="0"
fi

if [ $vcpus = "4" ]
then
  cores="2"
  threads="2"
fi

if [ $vcpus = "6" ]
then
  cores="3"
  threads="2"
fi

if [ $vcpus = "8" ]
then
  cores="4"
  threads="2"
fi

virt-install \
-n $name \
--osinfo=ubuntujammy \
--memory=$memory \
--vcpus=$vcpus,sockets=1,cores=$cores,threads=$threads \
--cpu host \
--network type=direct,source={{VLAN REDACTED}},source_mode=bridge,model=virtio \
--disk='/mnt/nfs_share/bntwx/'$name'.qcow2',bus=virtio \
--location=/mnt/md0/disk-images/jammy-live-server-amd64-latest.iso,kernel=casper/vmlinuz,initrd=casper/initrd \
--extra-args='autoinstall ds=nocloud-net;s=http://{{IMAGE SERVER REDACTED}}/image-server/' \
--features kvm_hidden=on \
--noautoconsole
