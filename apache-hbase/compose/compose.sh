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

function start_daemon() {
    # 1) 启动 hadoop 集群
    docker exec -it hbase-master bash -c "source ~/.jenv/bin/jenv-init.sh && jenv cd hadoop && sbin/start-all.sh && jps"

    echo "Starting HBase ......"

    # 2) 启动hbase, 最后的bash用于阻塞防止master自动关闭, 也便于hbase shell操作
    docker exec -it hbase-master bash -c "source ~/.jenv/bin/jenv-init.sh && start-hbase.sh && jps && bash"
    # 启动 backup master
    # docker exec -it hbase-regionserver1 bash -c "source /home/hdp/.jenv/bin/jenv-init.sh && hbase-daemon.sh start master && jps"
}

# 初始化
function init() {
    docker exec -it hbase-master bash -c "source /usr/local/.jenv/bin/jenv-init.sh && hadoop namenode -format"
    start_daemon
}

function init_cluster() {
    create_cluster
    init
}


function start_cluster() {
    docker-compose start
    start_daemon
}


function stop_daemon() {
    # 关闭 backup master
    # docker exec -it hbase-regionserver1 bash -c "source /home/hdp/.jenv/bin/jenv-init.sh && hbase-daemon.sh stop master"
    # 1）关闭 hbase
    docker exec -it hbase-master bash -c "source /usr/local/.jenv/bin/jenv-init.sh && stop-hbase.sh"

    # 2）关闭 hadoop 集群
    docker exec -it hbase-master bash -c "source ~/.jenv/bin/jenv-init.sh && stop-hbase.sh && jenv cd hadoop && sbin/stop-all.sh"
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
