#!/bin/bash

print_usage() {
    echo "Run Kafka cluster on docker use docker-compose"
    echo ""
    echo "Usage: $0 [init|start|stop|remove]"
    echo ""
    echo "    -i|init   : Init and start kafka cluster"
    echo "    -s|start  : Start kafka cluster"
    echo "    -S|stop   : Stop kafka cluster"
    echo "    -r|remove : Remove kafka cluseter and related settings"
}

if [ $# -ne 1 ]; then
    print_usage
    exit 1
fi


ids=("0" "1" "2")
dataDir="/data/zookeeper/"

# 创建并启动容器
function create_cluster() {
    docker-compose up -d kafka0
}

function start_daemon() {
    for id in ${ids[@]}
    do
        docker exec -itd kafka$id bash -c "source /usr/local/.jenv/bin/jenv-init.sh && kafka-server-start.sh -daemon ~/server.properties"
    done
}

# 将server.properties传到相应的kafka节点
function init() {
    for id in ${ids[@]}
    do
        docker cp ../conf/server$id.properties kafka${id}:~/server.properties
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
    for id in ${ids[@]}
    do
        docker exec -itd kafka$id bash -c "source /usr/local/.jenv/bin/jenv-init.sh && kafka-server-stop.sh"
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
        echo "### 成功启动 kafka 集群 ###"
        ;;
    "-S"|"stop")
        stop_cluster
        echo "### 成功stop kafka 集群 ###"
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
