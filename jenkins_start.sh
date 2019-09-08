#!/bin/bash -ex

# Add server-manager reimage commands here if REIMAGE is 1. Use sshpass
if [ $REIMAGE -eq 1 ]
then 
    sshpass -p 'c0ntrail123' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l root 10.204.217.158 "(
    set -e 
    server-manager reimage --no_confirm --cluster_id k8s_nodeg12_ha_setup centos-7.6
    )"
fi

# Add nodea4 ssh-pass 
echo "Jenkins Workspace: $WORKSPACE"
sshpass -p 'c0ntrail123' scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r $WORKSPACE root@nodea4.englab.juniper.net:/root/jenkins_nuthan
sshpass -p 'c0ntrail123' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l root nodea4.englab.juniper.net "(
    cd /root/jenkins_nuthan
    echo $PROVISION
    echo `pwd`
)"

# source exports.sh
# source provision_contrail_command.sh
# If the above two doesn't work, think of copying JENKINS WORKSPACE into the node
