#!/bin/sh

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
    echo "{"insecure-registries": ["10.204.217.152:5010","10.204.217.152:5000"]}" > /etc/docker/daemon.json
    systemctl reload docker
    export CCD_IMAGE=10.204.217.152:5010/contrail-command-deployer:$TAG
    sed -i "s/container_tag: .*/container_tag: ${TAG}/g" $COMMAND_SERVERS_FILE
    # sed -i 's/registry_insecure\: false/registry_insecure\: true/g' command_servers.yml

else
    export CCD_IMAGE=hub.juniper.net/contrail-nightly/contrail-command-deployer:$TAG
    docker login hub.juniper.net -u $CONTAINER_REGISTRY_USERNAME -p $CONTAINER_REGISTRY_PASSWORD

    # Changes in the command_servers.yml file
    sed -i 's/registry_insecure\: true/registry_insecure\: false/g' $COMMAND_SERVERS_FILE
    sed -i 's/# container_registry_username/container_registry_username/g' $COMMAND_SERVERS_FILE
    sed -i 's/# container_registry_password/container_registry_password/g' $COMMAND_SERVERS_FILE
    sed -i 's/10.204.217.152:5010/hub.juniper.net\/contrail-nightly/g' $COMMAND_SERVERS_FILE
    sed -i "s/container_tag: .*/container_tag: ${TAG}/g" $COMMAND_SERVERS_FILE

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
