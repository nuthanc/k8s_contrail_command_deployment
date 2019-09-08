check_registry_username=`cat $COMMAND_SERVERS_FILE | grep -w "# container_registry_username"`
echo $?
echo $check_registry_username
