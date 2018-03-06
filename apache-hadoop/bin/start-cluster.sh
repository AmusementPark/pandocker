#!/bin/bash

# 使用root或者sudo运行
if [ `id -u` -ne 0 ]; then
    echo "Please use sudo or root to run it"
    exit 1
fi

hadoops=("hadoop-master" "hadoop-slave1" "hadoop-slave2" "hadoop-slave3")
for hadoop in ${hadoops[@]}
do
docker start ${docker}
done

# 直接进入hadoop-master
docker exec -it hadoop-master /bin/bash

# 相关操作提示符
