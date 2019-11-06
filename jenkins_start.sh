#!/bin/bash -ex

# Add server-manager reimage commands here if REIMAGE is 1. Use sshpass
if [ $REIMAGE -eq 1 ]
then 
    sshpass -p 'c0ntrail123' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l root 10.204.217.158 "bash -s" <./reimage.sh
fi

# Add nodea4 ssh-pass 
echo "Jenkins Workspace: $WORKSPACE"


sshpass -p 'c0ntrail123' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l root $COMMAND_SERVER_IP << EOF
    set -ex

    if [ -d "/root/Nuthan_jenkins" ]
    then
        rm -rf /root/Nuthan_jenkins
    fi
EOF

sshpass -p 'c0ntrail123' scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r $WORKSPACE/ root@${COMMAND_SERVER_IP}:/root/Nuthan_jenkins

sshpass -p 'c0ntrail123' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l root $COMMAND_SERVER_IP "(

    export WORKSPACE=$WORKSPACE
    export INSECURE=$INSECURE 
    export TAG=$TAG 
    export CONTRAIL_VERSION=$CONTRAIL_VERSION
    export COMMAND_SERVER_IP=$COMMAND_SERVER_IP
    export CONTAINER_REGISTRY_USERNAME=$CONTAINER_REGISTRY_USERNAME
    export CONTAINER_REGISTRY_PASSWORD=$CONTAINER_REGISTRY_PASSWORD
    export PROVISION=$PROVISION
    export IMPORT=$IMPORT
    export VIRTUAL_SETUP=$VIRTUAL_SETUP 
    export REIMAGE=$REIMAGE
    export COMMAND_SERVERS_FILE=$COMMAND_SERVERS_FILE
    export INSTANCES_FILE=$INSTANCES_FILE
    export WORKING_DIR=$WORKING_DIR

    set -x
    docker stop contrail_command contrail_psql
    docker system prune -f
    
    source ${WORKING_DIR}/exports.sh
    source ${WORKING_DIR}/provision_contrail_command.sh
    
)"

# source exports.sh
# source provision_contrail_command.sh
# If the above two doesn't work, think of copying JENKINS WORKSPACE into the node
