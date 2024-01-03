#!/bin/bash

# must first confirm drive /dev/sdb1 is mounted to /media/external, then sync can commence.
# if error in mount or rsync, error logged to /var/log/backup.log

volume=/dev/sdb1
mnt_point=/media/external
backup_point=/home/server/backups/

echo "Script is running">>/var/log/backup.log

if ! mount | grep -q $volume; then
    echo $volume not mounted, will attempt to mount now
    sudo mount -t ntfs-3g $volume $mnt_point && echo $(date '+%Y-%m-%d %H:%M:%S') - Succesfully mounted drive $volume to $mnt_point>>/var/log/backup.log || echo $(date '+%Y-%m-%d %H:%M:%S') - ERROR: Could not mount $volume to $mnt_point,exited>>/var/log/backup.log; exit 1;

fi

# drive /dev/sdb1 is mounted to /media/external, then sync can commence

sudo rsync -aPvh --delete --dry-run $backup_point $mnt_point/Natojs

if [ $? -eq 0 ]; then
    echo $(date '+%Y-%m-%d %H:%M:%S') -  Succesfull sync of backup directory $backup_point to drive $volume>>/var/log/backup.log

else
    echo $(date '+%Y-%m-%d %H:%M:%S') - ERROR: Could not sync backup directory $backup_point to drive $volume>>/var/log/backup.log

fi

# un mount drive
sudo umount $mnt_point
echo $(date '+%Y-%m-%d %H:%M:%S')- volume $volume un mounted>>/var/log/backup.log

echo $?