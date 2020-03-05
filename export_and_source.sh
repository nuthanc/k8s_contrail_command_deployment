export WORKSPACE=$WORKSPACE
export INSECURE=$INSECURE 
export TAG=$TAG 
export CONTRAIL_VERSION=$CONTRAIL_VERSION
export COMMAND_SERVER_IP=$COMMAND_SERVER_IP
export CONTAINER_REGISTRY_USERNAME=$CONTAINER_REGISTRY_USERNAME
export CONTAINER_REGISTRY_PASSWORD=$CONTAINER_REGISTRY_PASSWORD
export PROVISION=$PROVISION
export IMPORT=$IMPORT
export VIRTUAL_SETUP=$VIRTUAL_SETUP 
export REIMAGE=$REIMAGE
export COMMAND_SERVERS_FILE=$COMMAND_SERVERS_FILE
export INSTANCES_FILE=$INSTANCES_FILE
export WORKING_DIR=$WORKING_DIR

set -x
ver=`docker -v`
doc_text="Docker version"
if [[ $ver =~ $doc_text ]]
then
    docker stop $(docker ps -a -q) 
    docker system prune -f
    docker rmi $(docker images -a -q)
fi

source ${WORKING_DIR}/exports.sh
source ${WORKING_DIR}/provision_contrail_command.sh
