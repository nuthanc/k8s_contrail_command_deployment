#!/bin/sh -x

sleep $1m
# nodeg12 10.204.217.52     and    vm1 10.204.218.103
export SANITY_NODE=10.204.217.52
export INSECURE=1
export INSECURE_REGISTRY=10.204.217.152:5000
export CONTRAIL_VERSION=1911.8
# nodea4 10.204.216.120     and     nodea35 10.204.216.31
export COMMAND_SERVER_IP=10.204.216.120
# Use instances_virtual.yml with nodea35 for virtual setup
export INSTANCES_FILE=/root/Nuthan_jenkins/instances.yml

source run_sanity.sh

