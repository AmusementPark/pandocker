#!/bin/bash

print_usage() {
    echo "Run hbase distributed cluster based on hdfs with Zookeeper on docker use docker-compose"
    echo ""
    echo "Usage: $0 [init|start|stop|remove]"
    echo ""
    echo "    -i|init   : Init and start hbase cluster"
    echo "    -s|start  : Start hbase cluster"
    echo "    -S|stop   : Stop hbase cluster"
    echo "    -r|remove : Remove hbase cluster and related settings"
}

if [ $# -ne 1 ]; then
    print_usage
    exit 1
fi


hbases=("hbase-master" "hbase-regionserver1" "hbase-regionserver2" "hbase-regionserver3")

# 创建并启动容器
function create_cluster() {
    docker-compose up -d hmaster 
}


# 配置容器间免密登录
function login_without_passwd() {
    for hbase in ${hbases[@]}
    do
        docker exec -it ${hbase} bash -c "sudo mkdir -p /data/ && sudo chown -R hdp:hadoop /data/"
        docker exec -it ${hbase} bash -c "sudo sed -i 's/.*StrictHostKeyChecking ask/StrictHostKeyChecking no/' /etc/ssh/ssh_config"
        docker exec -it ${hbase} bash -c "ssh-keygen &&  chmod 700 /home/hdp/.ssh && chmod 600 /home/hdp/.ssh/id_rsa && cat /home/hdp/.ssh/id_rsa.pub >> /home/hdp/.ssh/authorized_keys && chmod 644 /home/hdp/.ssh/authorized_keys"
    done
    # hadoop-master & hadoop-slave* 是主机名，为了与 ilpan/apache-hadoop中的配置一致 (虽然也可以修改)
    docker exec -it hbase-master bash -c "ssh-copy-id hadoop-slave1 && ssh-copy-id hadoop-slave2 && ssh-copy-id hadoop-slave3"
    docker exec -it hbase-regionserver1 bash -c "ssh-copy-id hadoop-master && ssh-copy-id hadoop-slave2 && ssh-copy-id hadoop-slave3"
    docker exec -it hbase-regionserver2 bash -c "ssh-copy-id hadoop-master && ssh-copy-id hadoop-slave1 && ssh-copy-id hadoop-slave3"
    docker exec -it hbase-regionserver3 bash -c "ssh-copy-id hadoop-master && ssh-copy-id hadoop-slave1 && ssh-copy-id hadoop-slave2"
}

# cd 后面的指令还是在当前目录下执行的
# 手动进入zookeeper目录启动
function start_zk_cluster() {
#    # 直接通过判断是否存在 zk network来判断是否存在zk cluster
#    cd ../../apache-hbase/compose/
#    docker network ls | grep 'compose_zookeeper-network'
#    if [ $? -ne 0 ]; then
#        ./compose.sh -i
#    else
#        ./compose.sh -S
#        ./compose.sh -s
#    fi
#    # 回到原来的目录
#    cd ../../apache-hbase/compose
    echo "请进入apache-zookeeper/compose目录使用./compose.sh [-i|-s](初始化|启动) zk 集群"
}

function start_daemon() {
    # 1) 启动 hadoop 集群
    docker exec -it hbase-master bash -c "source /home/hdp/.jenv/bin/jenv-init.sh && jenv cd hadoop && sbin/start-all.sh && jps"
    # 2) 启动 zookeeper 集群
    start_zk_cluster
    # 3) 启动hbase
    docker exec -it hbase-master bash -c "source /home/hdp/.jenv/bin/jenv-init.sh && start-hbase.sh && jps"
    # 启动 backup master
    # docker exec -it hbase-regionserver1 bash -c "source /home/hdp/.jenv/bin/jenv-init.sh && hbase-daemon.sh start master && jps"
}

# 初始化
function init() {
    docker exec -it hbase-master bash -c "source /home/hdp/.jenv/bin/jenv-init.sh && hadoop namenode -format"
    start_daemon
}

function init_cluster() {
    create_cluster
    login_without_passwd
    init
}


function start_cluster() {
    docker-compose start
    start_daemon
}

function stop_zk_cluster() {
#    cd ../../apache-zookeeper/compose/
#    ./compose.sh -S
#    cd ../../apache-hbase/compose/
    echo "请进入 apache-zookeeper/compose 使用 ./compose -s 停止zk集群"
}

function stop_daemon() {
    # 关闭 backup master
    # docker exec -it hbase-regionserver1 bash -c "source /home/hdp/.jenv/bin/jenv-init.sh && hbase-daemon.sh stop master"
    # 1）关闭 hbase
    docker exec -it hbase-master bash -c "source /usr/local/.jenv/bin/jenv-init.sh && stop-hbase.sh"
    # 2) 关闭 ZK cluster
    stop_zk_cluster
    # 3）关闭 hadoop 集群
    docker exec -it hbase-master bash -c "source /home/hdp/.jenv/bin/jenv-init.sh && stop-hbase.sh && jenv cd hadoop && sbin/stop-all.sh"
}

function stop_cluster() {
    stop_daemon
    docker-compose stop
}

# 只删除 hbase 集群，不影响 zookeeper 集群
function remove_cluster() {
    docker-compose down
}


case "$1" in
    "-i"|"init")
        init_cluster
        ;;
    "-s"|"start")
        start_cluster
        ;;
    "-S"|"stop")
        stop_cluster
        ;;
    "-r"|"remove")
        remove_cluster
        ;;
    "-h"|"help")
        print_usage
        exit 0
        ;;
    *)
        print_usage
        exit 1
        ;;
esac