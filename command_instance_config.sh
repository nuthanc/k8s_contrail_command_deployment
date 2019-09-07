#!/bin/bash
# Insecure and secure logic
if [ $INSECURE -eq 1 ]
then
    # Changes in the command_servers.yml file and note the single quote and double quote differences
    sed -i 's/registry_insecure\: false/registry_insecure\: true/g' $COMMAND_SERVERS_FILE
    echo "Modify this as this doesn't work when INSECURE is used twice"
    sed -i "s/container_registry_username/# container_registry_username/g" $COMMAND_SERVERS_FILE
    sed -i "s/container_registry_password/# container_registry_password/g" $COMMAND_SERVERS_FILE
    sed -i 's/hub.juniper.net\/contrail-nightly/10.204.217.152:5000/g' $COMMAND_SERVERS_FILE
    sed -i "s/container_tag: .*/container_tag: ${TAG}/g" $COMMAND_SERVERS_FILE

    # Changes in instances.yml file
    sed -i "s/registry: .*/registry: 10.204.217.152:5000/g" $INSTANCES_FILE
    sed -i "s/version: .*/version: ${CONTRAIL_VERSION}/g" $INSTANCES_FILE
    sed -i "s/REGISTRY_PRIVATE_INSECURE: .*/REGISTRY_PRIVATE_INSECURE: True/g" $INSTANCES_FILE
    sed -i "s/CONTAINER_REGISTRY: .*/CONTAINER_REGISTRY: 10.204.217.152:5000/g" $INSTANCES_FILE
    sed -i "s/CONTAINER_REGISTRY_USERNAME/# CONTAINER_REGISTRY_USERNAME/g" $INSTANCES_FILE
    sed -i "s/CONTAINER_REGISTRY_PASSWORD/# CONTAINER_REGISTRY_PASSWORD/g" $INSTANCES_FILE
    sed -i "s/CONTRAIL_VERSION: .*/CONTRAIL_VERSION: ${CONTRAIL_VERSION}/g" $INSTANCES_FILE

else
    # Changes in the command_servers.yml file and note the single quote and double quote differences
    sed -i 's/registry_insecure\: true/registry_insecure\: false/g' $COMMAND_SERVERS_FILE
    sed -i 's/# container_registry_username/container_registry_username/g' $COMMAND_SERVERS_FILE
    sed -i 's/# container_registry_password/container_registry_password/g' $COMMAND_SERVERS_FILE
    sed -i 's/10.204.217.152:5010/hub.juniper.net\/contrail-nightly/g' $COMMAND_SERVERS_FILE
    sed -i "s/container_tag: .*/container_tag: ${TAG}/g" $COMMAND_SERVERS_FILE

    # Changes in instances.yml file
    sed -i "s/registry: .*/registry: hub.juniper.net\/contrail-nightly/g" $INSTANCES_FILE
    sed -i "s/version: .*/version: ${CONTRAIL_VERSION}/g" $INSTANCES_FILE
    sed -i "s/REGISTRY_PRIVATE_INSECURE: .*/REGISTRY_PRIVATE_INSECURE: False/g" $INSTANCES_FILE
    sed -i "s/CONTAINER_REGISTRY: .*/CONTAINER_REGISTRY: hub.juniper.net\/contrail-nightly/g" $INSTANCES_FILE
    sed -i 's/# CONTAINER_REGISTRY_USERNAME/CONTAINER_REGISTRY_USERNAME/g' $INSTANCES_FILE
    sed -i 's/# CONTAINER_REGISTRY_PASSWORD/CONTAINER_REGISTRY_PASSWORD/g' $INSTANCES_FILE
    sed -i "s/CONTRAIL_VERSION: .*/CONTRAIL_VERSION: ${CONTRAIL_VERSION}/g" $INSTANCES_FILE
fi
