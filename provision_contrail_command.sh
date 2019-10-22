#!/bin/sh -ex 

# This file is until step 9
# Install docker
ver=`docker -v`
doc_text="Docker version"
if [[ $ver =~ $doc_text ]]
then
    echo "Docker already installed"
else
    yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum install -y docker-ce-18.03.1.ce
    systemctl start docker
fi

sed -i "s/ip: .*/ip: ${COMMAND_SERVER_IP}/g" $COMMAND_SERVERS_FILE

# Insecure and secure logic
if [ $INSECURE -eq 1 ]
then
    echo '{"insecure-registries": ["10.204.217.152:5010","10.204.217.152:5000","10.84.5.81:5010"]}' > /etc/docker/daemon.json
    systemctl reload docker
    export CCD_IMAGE=$INSECURE_REGISTRY/contrail-command-deployer:$TAG

    # Changes in the command_servers.yml file and note the single quote and double quote differences
    sed -i 's/registry_insecure\: false/registry_insecure\: true/g' $COMMAND_SERVERS_FILE

    check_comment_registry=`cat $COMMAND_SERVERS_FILE | grep -w "# container_registry_username"`
    if [ $? -eq 1 ] # $? is 0 if commented registry is found
    then
        sed -i "s/container_registry_username/# container_registry_username/g" $COMMAND_SERVERS_FILE
        sed -i "s/container_registry_password/# container_registry_password/g" $COMMAND_SERVERS_FILE
    fi

    sed -i "s/container_registry: .*/container_registry: \"${INSECURE_REGISTRY}\"/g" $COMMAND_SERVERS_FILE
    sed -i "s/container_tag: .*/container_tag: \"${TAG}\"/g" $COMMAND_SERVERS_FILE

    # Changes in instances.yml file
    sed -i "s/registry: .*/registry: \"${INSECURE_REGISTRY}\"/g" $INSTANCES_FILE
    sed -i "s/version: .*/version: \"${CONTRAIL_VERSION}\"/g" $INSTANCES_FILE
    sed -i "s/REGISTRY_PRIVATE_INSECURE: .*/REGISTRY_PRIVATE_INSECURE: True/g" $INSTANCES_FILE
    sed -i "s/CONTAINER_REGISTRY: .*/CONTAINER_REGISTRY: \"${INSECURE_REGISTRY}\"/g" $INSTANCES_FILE

    check_comment_registry=`cat $INSTANCES_FILE | grep -w "# CONTAINER_REGISTRY_USERNAME"`
    if [ $? -eq 1 ]
    then
        sed -i "s/CONTAINER_REGISTRY_USERNAME/# CONTAINER_REGISTRY_USERNAME/g" $INSTANCES_FILE
        sed -i "s/CONTAINER_REGISTRY_PASSWORD/# CONTAINER_REGISTRY_PASSWORD/g" $INSTANCES_FILE
    fi
    sed -i "s/CONTRAIL_VERSION: .*/CONTRAIL_VERSION: \"${CONTRAIL_VERSION}\"/g" $INSTANCES_FILE
else
    export CCD_IMAGE=hub.juniper.net/contrail-nightly/contrail-command-deployer:$TAG
    docker login hub.juniper.net -u $CONTAINER_REGISTRY_USERNAME -p $CONTAINER_REGISTRY_PASSWORD

    # Changes in the command_servers.yml file and note the single quote and double quote differences
    sed -i 's/registry_insecure\: true/registry_insecure\: false/g' $COMMAND_SERVERS_FILE

    check_comment_registry=`cat $COMMAND_SERVERS_FILE | grep -w "# container_registry_username"`
    if [ $? -eq 0 ] # If commented registry present, uncomment it
    then
        sed -i 's/# container_registry_username/container_registry_username/g' $COMMAND_SERVERS_FILE
        sed -i 's/# container_registry_password/container_registry_password/g' $COMMAND_SERVERS_FILE
    fi

    sed -i "s/container_registry: .*/container_registry: hub.juniper.net\/contrail-nightly/g" $COMMAND_SERVERS_FILE
    sed -i "s/container_tag: .*/container_tag: \"${TAG}\"/g" $COMMAND_SERVERS_FILE

    # Changes in instances.yml file
    sed -i "s/registry: .*/registry: hub.juniper.net\/contrail-nightly/g" $INSTANCES_FILE
    sed -i "s/version: .*/version: \"${CONTRAIL_VERSION}\"/g" $INSTANCES_FILE
    sed -i "s/REGISTRY_PRIVATE_INSECURE: .*/REGISTRY_PRIVATE_INSECURE: False/g" $INSTANCES_FILE
    sed -i "s/CONTAINER_REGISTRY: .*/CONTAINER_REGISTRY: hub.juniper.net\/contrail-nightly/g" $INSTANCES_FILE

    check_comment_registry=`cat $INSTANCES_FILE | grep -w "# CONTAINER_REGISTRY_USERNAME"`
    if [ $? -eq 0 ] # If commented registry present, uncomment it
    then
        sed -i 's/# CONTAINER_REGISTRY_USERNAME/CONTAINER_REGISTRY_USERNAME/g' $INSTANCES_FILE
        sed -i 's/# CONTAINER_REGISTRY_PASSWORD/CONTAINER_REGISTRY_PASSWORD/g' $INSTANCES_FILE
    fi
    sed -i "s/CONTRAIL_VERSION: .*/CONTRAIL_VERSION: \"${CONTRAIL_VERSION}\"/g" $INSTANCES_FILE
fi

docker pull $CCD_IMAGE

if [ $PROVISION -eq 1 ]
then
    docker run -t --net host -e orchestrator=kubernetes -e action=provision_cluster -v $COMMAND_SERVERS_FILE:/command_servers.yml -v $INSTANCES_FILE:/instances.yml -d --privileged --name contrail_command_deployer $CCD_IMAGE
elif [ $IMPORT -eq 1 ]
then
    docker run -t --net host -e orchestrator=kubernetes -e action=import_cluster -v $COMMAND_SERVERS_FILE:/command_servers.yml -v $INSTANCES_FILE:/instances.yml -d --privileged --name contrail_command_deployer $CCD_IMAGE
else
    docker run -td --net host -v $COMMAND_SERVERS_FILE:/command_servers.yml --privileged --name contrail_command_deployer $CCD_IMAGE
fi
