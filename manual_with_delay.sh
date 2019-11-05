#!/bin/sh -x

sleep $1m
# nodeg12 10.204.217.52     and    vm1 10.204.218.103
export SANITY_NODE=10.204.218.103
# Make INSECURE 0 for hub.juniper.net and 1 for insecure along with its registry
export INSECURE=1
export INSECURE_REGISTRY=10.204.217.152:5000
export CONTRAIL_VERSION=1911.14
# nodea4 10.204.216.120     and     nodea35 10.204.216.31
export COMMAND_SERVER_IP=10.204.216.31
# Use instances_virtual.yml with nodea35 for virtual setup and instances.yml for physical setup
export INSTANCES_FILE=/root/Nuthan_jenkins/instances_virtual.yml

source run_sanity.sh

