#!/bin/bash -ex

sshpass -p 'c0ntrail123' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l root $SANITY_NODE <<EOF
set -ex
Fix applied from 1911.7
# kubectl patch deployment coredns -n kube-system -p '{"spec":{"template":{"spec":{"containers":[{"name":"coredns", "image":"coredns/coredns:1.2.6"}]}}}}'

if [ $INSECURE -eq 0 ]
then
    docker run --entrypoint /bin/bash --network=host -i hub.juniper.net/contrail-nightly/contrail-test-test:$CONTRAIL_VERSION
else
    docker run --entrypoint /bin/bash --network=host -i 10.204.217.152:5000/contrail-test-test:$CONTRAIL_VERSION
fi
set -x
sshpass -p c0ntrail123 scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r root@${COMMAND_SERVER_IP}:${INSTANCES_FILE} /contrail-test/contrail_test_input.yaml
export PYTHONPATH=./scripts:./fixtures TEST_CONFIG_FILE=contrail_test_input.yaml
export MX_GW_TEST=0
export EMAIL_SUBJECT=Micro-services-Multi-Interface-Kubernetes-HA-Sanity-Ansible
cd contrail-test
bash -x run_tests.sh -m -U -T k8s_sanity -t
EOF
