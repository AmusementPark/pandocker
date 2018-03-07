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
docker images | fgrep 'ilpan/apache-hadoop' 1>/dev/null 2>&1
if [ $? -ne 0 ]; then
    docker pull ilpan/apache-hadoop
fi


# 2)设置网络，给容器分配同一网段的ip
hadoop_master_ip="172.18.0.2"
hadoop_slave1_ip="172.18.0.3"
hadoop_slave2_ip="172.18.0.4"
hadoop_slave3_ip="172.18.0.5"
docker network ls | fgrep 'hadoop-network' 1>/dev/null 2>&1
if [ $? -ne 0 ]; then
    docker network create --subnet=172.18.0.0/16 hadoop-network
fi

# 3)运行容器
# 防止启动失败 1)添加前台进程(-ti) 2)添加衔接输入流(/bin/bash)
# run hadoop-master
echo "runing hadoop-master"
docker run -itd --net hadoop-network --ip ${hadoop_master_ip} -p 50070:50070 -p 8088:8088 --add-host hadoop-slave1:${hadoop_slave1_ip} --add-host hadoop-slave2:${hadoop_slave2_ip} --add-host hadoop-slave3:${hadoop_slave3_ip} -v /data/hadoop-master/data:/data --name hadoop-master -h hadoop-master ilpan/apache-hadoop /bin/bash 
# run hadoop-slaves
# 总是会出现一两个 Address Already used，
echo "running hadoop-slave1"
docker run -itd --net hadoop-network --ip ${hadoop_slave1_ip} --name hadoop-slave1 -h hadoop-slave1 --add-host hadoop-master:${hadoop_master_ip} --add-host hadoop-slave2:${hadoop_slave2_ip} --add-host hadoop-slave3:${hadoop_slave3_ip} -P -v /data/hadoop-slave1/data:/data ilpan/apache-hadoop /bin/bash 
echo "running hadoop-slave2"
docker run -itd --net hadoop-network --ip ${hadoop_slave2_ip} --name hadoop-slave2 -h hadoop-slave2 --add-host hadoop-master:${hadoop_master_ip} --add-host hadoop-slave1:${hadoop_slave1_ip} --add-host hadoop-slave3:${hadoop_slave3_ip} -P -v /data/hadoop-slave2/data:/data ilpan/apache-hadoop /bin/bash 
echo "running hadoop-salve3"
docker run -itd --net hadoop-network --ip ${hadoop_slave3_ip} --name hadoop-slave3 -h hadoop-slave3 --add-host hadoop-master:${hadoop_master_ip} --add-host hadoop-slave1:${hadoop_slave1_ip} --add-host hadoop-slave2:${hadoop_slave2_ip} -P -v /data/hadoop-slave3/data:/data ilpan/apache-hadoop /bin/bash


# 4)在容器内进行相关配置
hadoops=("hadoop-master" "hadoop-slave1" "hadoop-slave2" "hadoop-slave3")
# 尝试手动开启ssh服务, 针对ssh connection refused
for hadoop in ${hadoop[@]}
do
    docker exec -it ${hadoop} /bin/bash -c "sudo /usr/sbin/sshd"
done

for hadoop in ${hadoops[@]}
do
    docker cp ./run-in-docker.sh ${hadoop}:/home/hdp/
    docker exec -it ${hadoop} /home/hdp/run-in-docker.sh
done


# 5)初始化hdfs并启动集群
# 在上面使用sudo /usr/sbin/sshd 后还是会出现connection refused
# 不解,在容器内直接操作命令就可以正常 ssh 连接了
# 再添加一次尝试
for hadoop in ${hadoop[@]}
do
    docker exec -it ${hadoop} /bin/bash -c "sudo /usr/sbin/sshd"
done

# 输入 yes，密码 123456
docker exec -it hadoop-master /bin/bash -c "ssh-copy-id hadoop-slave1 && ssh-copy-id hadoop-slave2 && ssh-copy-id hadoop-slave3"
docker exec -it hadoop-slave1 /bin/bash -c "ssh-copy-id hadoop-master && ssh-copy-id hadoop-slave2 && ssh-copy-id hadoop-slave3"
docker exec -it hadoop-slave2 /bin/bash -c "ssh-copy-id hadoop-master && ssh-copy-id hadoop-slave1 && ssh-copy-id hadoop-slave3"
docker exec -it hadoop-slave3 /bin/bash -c "ssh-copy-id hadoop-master && ssh-copy-id hadoop-slave1 && ssh-copy-id hadoop-slave2"

# 初始化 namenode
docker exec -it hadoop-master /bin/bash -c "source /home/hdp/.jenv/bin/jenv-init.sh && hadoop namenode -format && jenv cd hadoop && sbin/start-all.sh && jps"
echo "###### ============================ ######"
echo "###### ============================ ######"
echo "###### HADOOP CLUSTER IS RUNNING... ######"
echo "###### ============================ ######"
echo "###### ============================ ######"
echo;
echo;

# 6) 如果出现失败，按以下步骤手动执行
echo "===================================================================="
echo "###### WARNNING: IF SUCCESSED, DO NOT RUN THESE INSTRUCTIONS #######"
echo "###### Please follow these instructions to continue start cluster"
echo "###### 1)依次进入hadoop-master 和 hadoop-slave[n]"
echo "###### 2)执行 sudo /usr/sbin/sshd"
echo "###### 3)执行 ssh-copy-id hadoop-[others]"
echo "###### 4)在hadoop-master执行命令 (docker exec -it hadoop-master /bin/bash -c \"source /home/hdp/.jenv/bin/jenv-init.sh && hadoop namenode -format && jenv cd hadoop && sbin/start-all.sh && jps\")"
echo "==================================================================="
echo;
echo;
