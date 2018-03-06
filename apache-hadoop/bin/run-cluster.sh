#!/bin/bash

# 0)相关检查
# 检查用户
if [ `id -u` -ne 0 ]; then
    echo "Please use root"
    exit 1
fi
# 检查目录
data_dirs=("/data/hadoop/tmp" "/data/hadoop/dfs/name" "/data/hadoop/dfs/data" "/data/hadoop/dfs/namesecondary")
for data_dir in ${data_dirs[@]}
do
    if [ -d ${data_dir} ]; then
        echo "${data_dir} 目录已存在，请慎重确认是否可以删除"
        exit 2
    fi
done

# 1)拉取镜像
# 也可尝试将当前用户加入到docker组
# sudo gpasswd -a ${USER} docker
docker pull ilpan/apache-hadoop


# 2)设置网络，给容器分配同一网段的ip
docker network create --subnet=172.18.0.0/16 hadoop-network
hadoop-master-ip="172.18.0.2"
hadoop-slave1-ip="172.18.0.3"
hadoop-slave2-ip="172.18.0.4"
hadoop-slave3-ip="172.18.0.5"

# 3)运行容器
# run hadoop-master
docker run -d --net hadoop-network --ip hadoop-master-ip -p 50070:50070 -p 8088:8088 -v /data/hadoop-master/data:/data ---name hadoop-master -h hadoop-master ilpan/apache-hadoop
# run hadoop-slaves
docker run -d --net hadoop-network --ip hadoop-slave1-ip -P --name hadoop-slave1 -h hadoop-slave1 -v /data/hadoop-slave1/data:/data ilpan/apache-hadoop
docker run -d --net hadoop-network --ip hadoop-slave1-ip -P --name hadoop-slave2 -h hadoop-slave2 -v /data/hadoop-slave2/data:/data ilpan/apache-hadoop
docker run -d --net hadoop-network --ip hadoop-slave3-ip -P --name hadoop-slave3 -h hadoop-slave3 -v /data/hadoop-slave3/data:/data ilpan/apache-hadoop



# 4)在容器内进行相关配置
hadoops=("hadoop-master" "hadoop-slave1" "hadoop-slave2" "hadoop-slave3")
for hadoop in ${hadoops[@]}
do
    docker cp ./run-in-docker.sh ${hadoop}:${USER}/
    docker exec -d ${hadoop} ~/run-in-docker.sh
done

# 6)初始化hdfs并启动集群
docker exec -it hadoop-master /bin/bash
hdfs namenode -format
jenv cd hadoop && sbin/start-all.sh
jps
