#!/bin/bash -ex

# Add server-manager reimage commands here if REIMAGE is 1. Use sshpass
if [ $REIMAGE -eq 1 ]
then 
    sshpass -p 'c0ntrail123' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l root 10.204.217.158 "bash -s" <./reimage.sh
fi

# Add nodea4 ssh-pass 
echo "Jenkins Workspace: $WORKSPACE"


sshpass -p 'c0ntrail123' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l root $COMMAND_SERVER_IP "(
    set -ex

    if [ -d "/root/Nuthan_jenkins" ]
    then
        rm -rf /root/Nuthan_jenkins
    fi
)"

sshpass -p 'c0ntrail123' scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r $WORKSPACE/ root@${COMMAND_SERVER_IP}:/root/Nuthan_jenkins

sshpass -p 'c0ntrail123' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l root $COMMAND_SERVER_IP <./export_and_source.sh

# source exports.sh
# source provision_contrail_command.sh
# If the above two doesn't work, think of copying JENKINS WORKSPACE into the node
