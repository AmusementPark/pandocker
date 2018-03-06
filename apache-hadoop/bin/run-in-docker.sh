#!/bin/bash

hadoop-master-ip="172.18.0.2"
hadoop-slave1-ip="172.18.0.3"
hadoop-slave2-ip="172.18.0.4"
hadoop-slave3-ip="172.18.0.5"
hadoops=("hadoop-master" "hadoop-slave1" "hadoop-slave2" "hadoop-slave3")

function ssh_configure() {
    ssh-keygen -t rsa
    if [ !-f ${USER}/.ssh/authorized_keys ]; then
        touch ${USER}/.ssh/authorized_keys
    fi
    chmod 700 ${USER}/.ssh && chmod 600 ${USER}/.ssh/id_rsa && chmod 644 ${USER}/.ssh/authorized_keys 
}

ssh_configure

echo -n "${hadoop-salve1-ip}  ${hadoop-slave1}\n${hadoop-slave2-ip}  ${hadoop-slave2}\n${hadoop-slave3}  ${hadoop-salve3}\n" >> /etc/hosts

# 设置容器间的相关配置: /etc/hosts; ssh
for hadoop in ${hadoops[@]}
do
    if [ ${hadoop}!=${hostname} ]; then
        ssh-copy-id -i hdp@${hadoop}
        scp /etc/hosts hdp@${hadoop}:/etc/hosts
    fi
done
