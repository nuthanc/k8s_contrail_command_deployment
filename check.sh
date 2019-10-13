#!/bin/sh
while [ $? -eq 0 ]
    do
        sleep 10
        server-manager status server --cluster_id k8s_nodeg12_ha_setup|grep "reimage_started\|restart_issued"
    done
    