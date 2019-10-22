#!/bin/sh -x
server-manager reimage --no_confirm --server_id nodeg12 centos-7.7
server-manager reimage --no_confirm --server_id nodeg31 centos-7.7
server-manager reimage --no_confirm --server_id nodec58 centos-7.7
server-manager reimage --no_confirm --server_id nodec60 centos-7.7
server-manager reimage --no_confirm --server_id nodec61 centos-7.7

sleep 14.5m

server-manager status server --cluster_id k8s_nodeg12_ha_setup|grep "reimage_started\|restart_issued"
status=$?

while [ $status -eq 0 ]
do
    sleep 10
    server-manager status server --cluster_id k8s_nodeg12_ha_setup|grep "reimage_started\|restart_issued"
    status=$?
done