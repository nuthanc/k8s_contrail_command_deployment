#!/bin/sh -x

sleep $1m

export SANITY_NODE=10.204.217.52
export INSECURE=1
export INSECURE_REGISTRY=10.204.217.152:5000
export CONTRAIL_VERSION=1911.2
export COMMAND_SERVER_IP=10.204.216.120
export INSTANCES_FILE=/root/Nuthan_jenkins/instances.yml

source run_sanity.sh

