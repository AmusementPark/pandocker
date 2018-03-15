#!/bin/bash

print_usage() {
    echo "Run ZK cluster on docker use docker-compose"
    echo ""
    echo "Usage: $0 [init|start|stop|remove]"
    echo ""
    echo "    -i|init   : Init and start ZK cluster"
    echo "    -s|start  : Start ZK cluster"
    echo "    -S|stop   : Stop ZK cluster"
    echo "    -r|remove : Remove ZK cluseter and related settings"
}

if [ $# -ne 1 ]; then
    print_usage
    exit 1
fi


zks=("0" "1" "2")
dataDir="/data/zookeeper/"

# 创建并启动容器
function create_cluster() {
    docker-compose up -d zk0
}

function start_daemon() {
    for id in ${zks[@]}
    do
        docker exec -itd zk$id bash -c "source /usr/local/.jenv/bin/jenv-init.sh && zkServer.sh start && zkServer.sh status"
    done
}

# 给各个zk创建myid
function init() {
    for id in ${zks[@]}
    do
        docker exec -itd zk$id bash -c "sudo chown -R hdp:hadoop /data/ && echo $id > $dataDir/myid"
    done
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
    for id in ${zks[@]}
    do
        docker exec -itd zk$id bash -c "source /usr/local/.jenv/bin/jenv-init.sh && zkServer.sh stop && zkServer.sh status"
    done
}

function stop_cluster() {
    stop_daemon
    docker-compose stop
}


function remove_cluster() {
    docker-compose down
}


case "$1" in
    "-i"|"init")
        init_cluster
        echo "### zookeeper 集群成功初始化并启动 ###"
        ;;
    "-s"|"start")
        start_cluster
        echo "### 成功启动 zookeeper 集群 ###"
        ;;
    "-S"|"stop")
        stop_cluster
        echo "### 成功stop ZK 集群 ###"
        ;;
    "-r"|"remove")
        remove_cluster
        echo "### 集群移除成功 ###"
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
