#!/bin/bash
# Created by BNTWX
# Every 5 seconds, this script will check to see what virtual machines are online.
# This script will create a file with the current seconds from 1970-01-01 00:00:00 UTC when it sees a VM boots
# When it becomes offline, it'll read that original file and subtract it from the current time from 1970. 
# Then, it'll send it via POST request to a webserver.


while sleep 5s;
do

tmpoutput="tmpvirsh"
# | tail -n -1
# Get all VM statuses
allvms="$(virsh -c qemu:///system list --all | tail -n +3)"

# Update last updated time
date="$(date +"%m/%d/%Y-%I:%M:%S-%p")"

# Get Hostname of server
hostname="$(hostname)"

# Parse Virt Data, echo for debugging
echo "$allvms" | while read line; do

# Set Active VM name for while statement
vmname="$(echo "$line" | xargs | awk '{if(NR == 1){print $2}}')"

# Get VM Status, export as variable.
status="$(virsh -c qemu:///system list --all| grep -E '(^|\s)'$vmname'($|\s)' | tr -s '[:space:]' '[\n*]' | tail -1)"
echo "$vmname status is $status"

if [ $status = "running" ]; then
   if [ ! -f "/home/cgood/scripts/statuses/$vmname.txt" ]; then
    echo "Online file does not exsist"
    echo "Creating online file"
    date +%s > /home/cgood/scripts/statuses/$vmname.txt
    echo "Removing Offline File"
    rm /home/cgood/scripts/statuses/$vmname-offline.txt
   else
    echo "Online file exsists"
    echo "Exiting online exsists"
   fi
    echo "Running status exited"
fi

if [ $status != "running" ]; then
   if [ -f "/home/bntwx/scripts/statuses/$vmname-offline.txt" ]; then
    echo "Offline file exsists"
   else
    echo "Offline file does not exsit"
    echo "Creating offline file"
    touch /home/bntwx/scripts/statuses/$vmname-offline.txt
    echo "Removing online file, calculating difference"
    starttime="$(cat /home/bntwx/scripts/statuses/$vmname.txt)"
    currenttime="$(date +%s)"
    preuptime="$(echo  $(( $currenttime - $starttime )))"
    uptime="$(echo $(( $preuptime / 60 )) | bc)"
    echo "Uptime is $uptime minutes"
    python3 -c "print($uptime*0.00015981735)" > result.txt
    result="$(cat result.txt)"
    rm result.txt
    echo "Cost is $result"
    rm /home/bntwx/scripts/statuses/$vmname.txt
    echo "Reporting to server"
    # Report to Server
    curl \
    --silent \
    -d '{"name":"'$vmname'","result":"'$result'"}' \
    -H "Content-Type: application/json" \
    -X POST http://{{URL REDACTED}}/vm3 \
    --output /dev/null

   fi
    echo "Not running exited"
fi

done
echo "Data updated at $(date)"
done
