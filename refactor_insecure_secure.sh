function command_server_changes() {
  REGISTRY_INSECURE_TRUE="registry_insecure: true"
  REGISTRY_INSECURE_FALSE="registry_insecure: false"
  BNG_ARTIFACTORY="bng-artifactory.juniper.net"
  HUB_JUNIPER="hub.juniper.net"
  COMMENTED_USERNAME="# container_registry_username"
  UNCOMMENTED_USERNAME="container_registry_username"
  COMMENTED_PASSWORD="# container_registry_password"
  UNCOMMENTED_PASSWORD="container_registry_password"
  OLD_CONTAINER_TAG="container_tag: .*"
  CONTAINER_TAG="container_tag: \"${TAG}\""

  # For bng repo
  if [ $INSECURE -eq 1 ]
  then
    is_registry_commented=`cat command_servers.yml | grep -w "# container_registry_username"`
    if [ $? -eq 1 ] # If it is uncommented, comment it
    then
      sed -i -e "s/${UNCOMMENTED_USERNAME}/${COMMENTED_USERNAME}/g" \
      -e "s/${UNCOMMENTED_PASSWORD}/${COMMENTED_PASSWORD}/g" command_servers.yml
    fi
    sed -i -e "s/${REGISTRY_INSECURE_FALSE}/${REGISTRY_INSECURE_TRUE}/g" \
    -e "s/${HUB_JUNIPER}/${BNG_ARTIFACTORY}/g" \
    -e "s/${OLD_CONTAINER_TAG}/${CONTAINER_TAG}/g" command_servers.yml
    
  # For hub.juniper repo
  else
    is_registry_commented=`cat command_servers.yml | grep -w "# container_registry_username"`
    if [ $? -eq 0 ] # If commented registry present, uncomment it
    then
      sed -i -e "s/${COMMENTED_USERNAME}/${UNCOMMENTED_USERNAME}/g" \
      -e "s/${COMMENTED_PASSWORD}/${UNCOMMENTED_PASSWORD}/g" command_servers.yml
    fi

    sed -i -e "s/${REGISTRY_INSECURE_TRUE}/${REGISTRY_INSECURE_FALSE}/g" \
    -e "s/${BNG_ARTIFACTORY}/${HUB_JUNIPER}/g" \
    -e "s/${OLD_CONTAINER_TAG}/${CONTAINER_TAG}/g" command_servers.yml
  fi
}

function instances_changes() {
  OLD_REGISTRY="registry: .*"
  OLD_VERSION="version: .*"
  VERSION="version: \"${CONTRAIL_VERSION}\""
  OLD_REGISTRY_PRIVATE_INSECURE="REGISTRY_PRIVATE_INSECURE: .*"
  OLD_CONTAINER_REGISTRY="CONTAINER_REGISTRY: .*"
  COMMENTED_USERNAME="# CONTAINER_REGISTRY_USERNAME"
  UNCOMMENTED_USERNAME="CONTAINER_REGISTRY_USERNAME"
  COMMENTED_PASSWORD="# CONTAINER_REGISTRY_PASSWORD"
  UNCOMMENTED_PASSWORD="CONTAINER_REGISTRY_PASSWORD"
  OLD_CONTRAIL_VERSION="CONTRAIL_VERSION: .*"
  CONTRAIL_VERSION="CONTRAIL_VERSION: \"${CONTRAIL_VERSION}\""
  # For bng repo
  if [ $INSECURE -eq 1 ]
  then
    REGISTRY="registry: bng-artifactory.juniper.net\/contrail-nightly"
    REGISTRY_PRIVATE_INSECURE="REGISTRY_PRIVATE_INSECURE: True"
    CONTAINER_REGISTRY="CONTAINER_REGISTRY: bng-artifactory.juniper.net\/contrail-nightly"

    is_registry_commented=`cat $INSTANCES_FILE | grep -w "# CONTAINER_REGISTRY_USERNAME"`
    if [ $? -eq 1 ]
    then
        sed -i -e "s/${UNCOMMENTED_USERNAME}/${COMMENTED_USERNAME}/g" \
        -e "s/${UNCOMMENTED_PASSWORD}/${COMMENTED_PASSWORD}/g" \
        -e "s/${OLD_VERSION}/${VERSION}/g" \
        -e "s/${OLD_CONTRAIL_VERSION}/${CONTRAIL_VERSION}/g" $INSTANCES_FILE
    fi
    sed -i -e "s/${OLD_REGISTRY}/${REGISTRY}/g" \
    -e "s/${OLD_REGISTRY_PRIVATE_INSECURE}/${REGISTRY_PRIVATE_INSECURE}/g" \
    -e "s/${OLD_CONTAINER_REGISTRY}/${CONTAINER_REGISTRY}/g" $INSTANCES_FILE

  # For hub.juniper
  else
    REGISTRY="registry: hub.juniper.net\/contrail-nightly"
    REGISTRY_PRIVATE_INSECURE="REGISTRY_PRIVATE_INSECURE: False"
    CONTAINER_REGISTRY="CONTAINER_REGISTRY: hub.juniper.net\/contrail-nightly"

    is_registry_commented=`cat $INSTANCES_FILE | grep -w "# CONTAINER_REGISTRY_USERNAME"`
    if [ $? -eq 0 ]
    then
        sed -i -e "s/${COMMENTED_USERNAME}/${UNCOMMENTED_USERNAME}/g" \
        -e "s/${COMMENTED_PASSWORD}/${UNCOMMENTED_PASSWORD}/g" \
        -e "s/${OLD_VERSION}/${VERSION}/g" \
        -e "s/${OLD_CONTRAIL_VERSION}/${CONTRAIL_VERSION}/g" $INSTANCES_FILE
    fi
    sed -i -e "s/${OLD_REGISTRY}/${REGISTRY}/g" \
    -e "s/${OLD_REGISTRY_PRIVATE_INSECURE}/${REGISTRY_PRIVATE_INSECURE}/g" \
    -e "s/${OLD_CONTAINER_REGISTRY}/${CONTAINER_REGISTRY}/g" $INSTANCES_FILE

  fi
}


function insecure_secure_config() {
  if [ $INSECURE -eq 1 ]
  then
    echo '{"insecure-registries": ["bng-artifactory.juniper.net","svl-artifactory.juniper.net"]}' > /etc/docker/daemon.json
    systemctl reload docker
    export CCD_IMAGE=bng-artifactory.juniper.net/contrail-nightly/contrail-command-deployer:$TAG
  else
    export CCD_IMAGE=hub.juniper.net/contrail-nightly/contrail-command-deployer:$TAG
    docker login hub.juniper.net -u $CONTAINER_REGISTRY_USERNAME -p $CONTAINER_REGISTRY_PASSWORD
    # Changes in instances.yml file
  fi
  command_server_changes
  instances_changes
}

function change_contrail_branch_in_instances(){
  OLD_BRANCH="branch: .*"
  BRANCH="branch: ${CONTRAIL_VERSION%%.*}"
  sed -i "s/${OLD_BRANCH}/${BRANCH}/g" $INSTANCES_FILE
}

change_contrail_branch_in_instances