#!/bin/bash

# 使用root或者sudo运行
if [ `id -u` -ne 0 ]; then
    echo "Please use sudo or root to run it"
    exit 1
fi

hadoops=("hadoop-master" "hadoop-slave1" "hadoop-slave2" "hadoop-slave3")
for hadoop in ${hadoops[@]}
do
    docker start ${hadoop}
    docker exec -it ${hadoop} /bin/bash -c "sudo /usr/sbin/sshd"
done

# 通过hadoop-master启动集群
docker exec -it hadoop-master /bin/bash -c "source /home/hdp/.jenv/bin/jenv-init.sh && jenv cd hadoop && sbin/start-all.sh && jps"

# 相关操作提示符
