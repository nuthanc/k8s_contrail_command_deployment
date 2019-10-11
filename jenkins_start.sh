#!/bin/bash -ex

sshpass -p 'c0ntrail123' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l root $SANITY_NODE "(
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