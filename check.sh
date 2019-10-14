#!/bin/sh

docker exec contrail_command tail --pid=$$ -f /var/log/ansible.log | while read file;do grep "failed=1";done
