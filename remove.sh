set -x

if [ -d "/root/Nuthan_jenkins" ]
then
    rm -rf /root/Nuthan_jenkins
fi

docker stop $(docker ps -a -q) || true
docker system prune -f
docker rmi $(docker images -a -q) || true
    

