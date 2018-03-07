#!/bin/bash

hadoop_master_ip="172.18.0.2"
hadoop_slave1_ip="172.18.0.3"
hadoop_slave2_ip="172.18.0.4"
hadoop_slave3_ip="172.18.0.5"
hadoops=("hadoop-master" "hadoop-slave1" "hadoop-slave2" "hadoop-slave3")

function ssh_configure() {
    ssh-keygen -t rsa
    if [ ! -f /home/hdp/.ssh/authorized_keys ]; then
        touch /home/hdp/.ssh/authorized_keys
    fi
    chmod 700 /home/hdp/.ssh && chmod 600 /home/hdp/.ssh/id_rsa && chmod 644 /home/hdp/.ssh/authorized_keys && cat /home/hdp/.ssh/id_rsa.pub >> /home/hdp/.ssh/authorized_keys
}

# 直接在此处修改/data的权限(也可在Dockerfile中修改)
function init_data_dir() {
    sudo mkdir -p /data/
    sudo chown -R hdp:hadoop /data/
}

ssh_configure
init_data_dir

# sudo echo -n "${hadoop_salve1_ip}  hadoop-slave1\n${hadoop_slave2_ip} hadoop-slave2\n${hadoop_slave3_ip}  hadoop-salve3\n" >> /etc/hosts

# 设置容器间的相关配置: /etc/hosts; ssh
# 由于connection refused (sshd未成功启动)
# 故此段操作直接在四个容器内依次运行
# for hadoop in ${hadoops[@]}
# do
#    if [ ${hadoop}!=${hostname} ]; then
#        ssh-copy-id hdp@${hadoop}
#        sudo scp /etc/hosts hdp@${hadoop}:/etc/hosts
#    fi
# done
