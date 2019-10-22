#!/bin/bash -ex
# Insecure and secure logic
if [ $INSECURE -eq 1 ]
then
    # Changes in the command_servers.yml file and note the single quote and double quote differences
    sed -i 's/registry_insecure\: false/registry_insecure\: true/g' $COMMAND_SERVERS_FILE
    echo "Modify this as this doesn't work when INSECURE is used twice"

    check_comment_registry=`cat $COMMAND_SERVERS_FILE | grep -w "# container_registry_username"`
    if [ $? -eq 1 ] # $? is 0 if commented registry is found
    then
        sed -i "s/container_registry_username/# container_registry_username/g" $COMMAND_SERVERS_FILE
        sed -i "s/container_registry_password/# container_registry_password/g" $COMMAND_SERVERS_FILE
    fi

    sed -i "s/container_registry: .*/container_registry: \"${INSECURE_REGISTRY}\"/g" $COMMAND_SERVERS_FILE
    sed -i "s/container_tag: .*/container_tag: ${TAG}/g" $COMMAND_SERVERS_FILE

    # Changes in instances.yml file
    sed -i "s/registry: .*/registry: \"${INSECURE_REGISTRY}\"/g" $INSTANCES_FILE
    sed -i "s/version: .*/version: ${CONTRAIL_VERSION}/g" $INSTANCES_FILE
    sed -i "s/REGISTRY_PRIVATE_INSECURE: .*/REGISTRY_PRIVATE_INSECURE: True/g" $INSTANCES_FILE
    sed -i "s/CONTAINER_REGISTRY: .*/CONTAINER_REGISTRY: \"${INSECURE_REGISTRY}\"/g" $INSTANCES_FILE

    check_comment_registry=`cat $INSTANCES_FILE | grep -w "# CONTAINER_REGISTRY_USERNAME"`
    if [ $? -eq 1 ]
    then
        sed -i "s/CONTAINER_REGISTRY_USERNAME/# CONTAINER_REGISTRY_USERNAME/g" $INSTANCES_FILE
        sed -i "s/CONTAINER_REGISTRY_PASSWORD/# CONTAINER_REGISTRY_PASSWORD/g" $INSTANCES_FILE
    fi
    sed -i "s/CONTRAIL_VERSION: .*/CONTRAIL_VERSION: ${CONTRAIL_VERSION}/g" $INSTANCES_FILE

else
    # Changes in the command_servers.yml file and note the single quote and double quote differences
    sed -i 's/registry_insecure\: true/registry_insecure\: false/g' $COMMAND_SERVERS_FILE

    check_comment_registry=`cat $COMMAND_SERVERS_FILE | grep -w "# container_registry_username"`
    if [ $? -eq 0 ] # If commented registry present, uncomment it
    then
        sed -i 's/# container_registry_username/container_registry_username/g' $COMMAND_SERVERS_FILE
        sed -i 's/# container_registry_password/container_registry_password/g' $COMMAND_SERVERS_FILE
    fi

    sed -i "s/container_registry: .*/container_registry: hub.juniper.net\/contrail-nightly/g" $COMMAND_SERVERS_FILE
    sed -i "s/container_tag: .*/container_tag: ${TAG}/g" $COMMAND_SERVERS_FILE

    # Changes in instances.yml file
    sed -i "s/registry: .*/registry: hub.juniper.net\/contrail-nightly/g" $INSTANCES_FILE
    sed -i "s/version: .*/version: ${CONTRAIL_VERSION}/g" $INSTANCES_FILE
    sed -i "s/REGISTRY_PRIVATE_INSECURE: .*/REGISTRY_PRIVATE_INSECURE: False/g" $INSTANCES_FILE
    sed -i "s/CONTAINER_REGISTRY: .*/CONTAINER_REGISTRY: hub.juniper.net\/contrail-nightly/g" $INSTANCES_FILE

    check_comment_registry=`cat $INSTANCES_FILE | grep -w "# CONTAINER_REGISTRY_USERNAME"`
    if [ $? -eq 0 ] # If commented registry present, uncomment it
    then
        sed -i 's/# CONTAINER_REGISTRY_USERNAME/CONTAINER_REGISTRY_USERNAME/g' $INSTANCES_FILE
        sed -i 's/# CONTAINER_REGISTRY_PASSWORD/CONTAINER_REGISTRY_PASSWORD/g' $INSTANCES_FILE
    fi
    sed -i "s/CONTRAIL_VERSION: .*/CONTRAIL_VERSION: ${CONTRAIL_VERSION}/g" $INSTANCES_FILE
fi