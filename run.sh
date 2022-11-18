#!/bin/bash

# TODO:
# - take the instance name from the terminal
# - take the volume name from the terminal
read -p "Please enter the instance name: " INSTANCE_NAME
read -p "Please enter the volume name: " VOLUME_NAME

# TODO:
# - check if storage pool with name 'docker' exist or not
# - if exist do nothing
# - else create a new one
STORAGE_POOL_NAME="docker"
STATE=1

if [ $STATE -eq 1 ];
then
    STORAGE_POOL=$(lxc storage create ${STORAGE_POOL_NAME} btrfs 2>&1 > /dev/null)
fi

if [ -z "${STORAGE_POOL}" ]; 
then
    echo "Creating storage pool with name 'docker'"
    echo
else
    echo "Storage pool with name 'docker' exist!"
    echo
fi

# TODO:
# - create a new lxc instance
echo "Creating container $INSTANCE_NAME..."
INSTANCE=$(lxc launch images:ubuntu/20.04 $INSTANCE_NAME 2>&1 > /dev/null)
echo $INSTANCE

# TODO:
# - create a new storage volume for the instance
echo "Creating volume $VOLUME_NAME..."
VOLUME=$(lxc storage volume create ${STORAGE_POOL_NAME} ${VOLUME_NAME} 2>&1 > /dev/null)
echo $VOLUME

# TODO:
# - attach the volume to the container
# - add additional configuration for supporting docker inside lxd
# - restart the instance
echo "Attaching ${VOLUME_NAME} to ${INSTANCE_NAME}"
lxc config device add $INSTANCE_NAME docker disk pool=docker source=$VOLUME_NAME path=/var/lib/docker
sleep 1

echo "Adding additional configuration to container"
lxc config set $INSTANCE_NAME security.nesting=true security.syscalls.intercept.mknod=true security.syscalls.intercept.setxattr=true
sleep 1

echo "Restarting ${INSTANCE_NAME}"
lxc restart $INSTANCE_NAME
sleep 1

# flushed the FORWARD table and changed default policy to ACCEPT
sudo iptables -F FORWARD
sudo iptables -P FORWARD ACCEPT