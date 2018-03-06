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


function ssh_configure() {
    ssh-keygen -t rsa
    if [ !-f ${USER}/.ssh/authorized_keys ]; then
        touch ${USER}/.ssh/authorized_keys
    fi
    chmod 700 ${USER}/.ssh && chmod 600 ${USER}/.ssh/id_rsa && chmod 644 ${USER}/.ssh/authorized_keys 
}


# 4)更新配置文件:/etc/hosts
hadoops=("hadoop-master" "hadoop-slave1" "hadoop-slave2" "hadoop-slave3")
docker exec -it hadoop-master /bin/bash
ssh_configure

echo -n "${hadoop-salve1-ip}  ${hadoop-slave1}\n${hadoop-slave2-ip}  ${hadoop-slave2}\n${hadoop-slave3}  ${hadoop-salve3}\n" >> /etc/hosts

# 尚未验证此写法可行性(进入进入容器并在容器中操作后退出)
for slaves in ${hadoops:1}
do
    ssh-copy-id -i ${hadoop}
    scp /etc/hosts hdp@${hadoop}:/etc/hosts
done

# ssh-copy-id -i hadoop-slave1
# ssh-copy-id -i hadoop-slave2
# ssh-copy-id -i hadoop-slave3
exit


# 5)设置容器间免密登录
# hadoop-master在上已配
# hadoop-slaves
for hadoop-slave in ${hadoops:1}
do
    docker exec -it ${hadoop-slave} /bin/bash
    ssh_configure
    for hadoop in ${hadoops[@]}
    do
        if [ ${hadoop} != "hadoop-slave1" ]; then
            ssh-copy-id -i ${hadoop}
        fi
    done
    exit
done

# 6)初始化hdfs并启动集群
docker exec -it hadoop-master /bin/bash
hdfs namenode -format
jenv cd hadoop && sbin/start-all.sh
jps
