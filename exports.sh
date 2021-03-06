#!/bin/sh -ex
export INSECURE=${INSECURE:-1} # Make this 0 if hub.juniper.net is used
export TAG=${TAG:-1911.18} # Use the appropriate tag for contrail-command
export CONTRAIL_VERSION=${CONTRAIL_VERSION:-1911.18}
export COMMAND_SERVER_IP=${COMMAND_SERVER_IP:-10.204.216.120} #THIS IS nodea4
# The below two if hub.juniper.net is used
export CONTAINER_REGISTRY_USERNAME=${CONTAINER_REGISTRY_USERNAME:-JNPR-Customer200}
export CONTAINER_REGISTRY_PASSWORD=${CONTAINER_REGISTRY_PASSWORD:-FSg0vLW^7oM#GZy8Ju*f}
export REIMAGE=${REIMAGE:-0}
export VIRTUAL_SETUP=${VIRTUAL_SETUP:-1} # Make this 0 if nodeg12 setup is used

export COMMAND_SERVERS_FILE=${COMMAND_SERVERS_FILE:-${HOME}/k8s_contrail_command_deployment/command_servers.yml}

if [ $VIRTUAL_SETUP -eq 1 ]
then 
    export INSTANCES_FILE=${INSTANCES_FILE:-${HOME}/k8s_contrail_command_deployment/instances_virtual.yml}
else
    # Change this to instances_mgmt.yml if management ip needs to be used
    export INSTANCES_FILE=${INSTANCES_FILE:-${HOME}/k8s_contrail_command_deployment/instances.yml}
fi
# Set both below as 0 when No Action is required
export PROVISION=${PROVISION:-0}
export IMPORT=${IMPORT:-0}
echo "INSECURE=$INSECURE, VIRTUAL_SETUP=$VIRTUAL_SETUP, TAG=$TAG, COMMAND_SERVER_IP=$COMMAND_SERVER_IP, PROVISION=$PROVISION, IMPORT=$IMPORT, C_FILE=$COMMAND_SERVERS_FILE, I_FILE=$INSTANCES_FILE"
