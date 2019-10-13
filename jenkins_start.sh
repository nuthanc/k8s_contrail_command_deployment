#!/bin/bash -ex

# Add server-manager reimage commands here if REIMAGE is 1. Use sshpass
if [ $REIMAGE -eq 1 ]
then 
    sshpass -p 'c0ntrail123' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l root 10.204.217.158 "(
    set -x 
    server-manager reimage --no_confirm --server_id nodeg12 centos-7.7
    server-manager reimage --no_confirm --server_id nodeg31 centos-7.7
    server-manager reimage --no_confirm --server_id nodec58 centos-7.7
    server-manager reimage --no_confirm --server_id nodec60 centos-7.7
    server-manager reimage --no_confirm --server_id nodec61 centos-7.7
    )"

    sleep 1m

    server-manager status server --cluster_id k8s_nodeg12_ha_setup|grep "reimage_started\|restart_issued"

    while [ $? -eq 0 ]
    do
        sleep 10
        server-manager status server --cluster_id k8s_nodeg12_ha_setup|grep "reimage_started\|restart_issued"
    done
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
    docker stop contrail_command contrail_psql contrail_command_deployer
    docker system prune -f
    set -e
    source ${WORKING_DIR}/exports.sh
    source ${WORKING_DIR}/provision_contrail_command.sh
    
)"

sshpass -p 'c0ntrail123' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l root $SANITY_NODE "(
    kubectl patch deployment coredns -n kube-system -p '{"spec":{"template":{"spec":{"containers":[{"name":"coredns", "image":"coredns/coredns:1.2.6"}]}}}}'

    if [ $INSECURE -eq 0 ]
    then
        docker run --entrypoint /bin/bash --network=host -it hub.juniper.net/contrail-nightly/contrail-test-test:$CONTRAIL_VERSION
    else
        docker run --entrypoint /bin/bash --network=host -it 10.204.217.152:5000/contrail-test-test:$CONTRAIL_VERSION
    fi
    sshpass -p 'c0ntrail123' scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r root@${COMMAND_SERVER_IP}:${INSTANCES_FILE} /contrail-test/contrail_test_input.yaml
    export PYTHONPATH=./scripts:./fixtures TEST_CONFIG_FILE=contrail_test_input.yaml
    export MX_GW_TEST=1
    export EMAIL_SUBJECT=Micro-services-Multi-Interface-Kubernetes-HA-Sanity-Ansible
    bash -x run_tests.sh -m -U -T k8s_sanity -t
)"