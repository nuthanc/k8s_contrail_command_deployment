#!/bin/sh

export COMMAND_SERVER_IP=10.204.216.120
export INSTANCES_FILE=/root/Nuthan_jenkins/instances_mgmt.yml

export PYTHONPATH=./scripts:./fixtures 
export TEST_CONFIG_FILE=contrail_test_input.yaml
export MX_GW_TEST=1
export EMAIL_SUBJECT=Micro-services-Multi-Interface-Kubernetes-HA-Sanity-Ansible

sshpass -p 'c0ntrail123' scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r root@${COMMAND_SERVER_IP}:${INSTANCES_FILE} /contrail-test/contrail_test_input.yaml

bash -x run_tests.sh -m -U -T k8s_sanity -t