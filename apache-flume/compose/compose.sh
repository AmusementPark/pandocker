#!/bin/bash

print_usage() {
    echo "Run Flume cluster on docker use docker-compose"
    echo ""
    echo "Usage: $0 [init|start|stop|remove]"
    echo ""
    echo "    -i|init   : Init and start flume cluster"
    echo "    -s|start  : Start flume cluster"
    echo "    -S|stop   : Stop flumme cluster"
    echo "    -r|remove : Remove flume cluster and related settings"
}

if [ $# -ne 1 ]; then
    print_usage
    exit 1
fi


tier1=("tier1-1" "tier1-2" "tier1-3" "tier1-4")
tier2=("tier2-1" "tier2-2")

conf_dir="/usr/local/.jenv/candidates/flume/current/conf/"
jenv_init="/usr/local/.jenv/bin/jenv_init.sh"

# 创建并启动容器
function create_cluster() {
    docker-compose up -d
}

function start_daemon() {
    for agent in ${tier2[@]}
    do
        docker exec -itd flume-${agent} bash -c "source ${jenv_init} && flume-ng agent -n a1 -c ${conf_dir} -f ${agent}.properties &"
    done
    
    for agent in ${tier1[@]}
    do
        docker exec -itd flume-${agent} bash -c "source ${jenv_init} && flume-ng agent -n a1 -c ${conf_dir} -f ${agent}.properties &"
    done
}

function init_cluster() {
    create_cluster
    start_daemon
}


function start_cluster() {
    docker-compose start
    start_daemon
}


function stop_cluster() {
    docker-compose stop
}


function remove_cluster() {
    docker-compose down
}


case "$1" in
    "-i"|"init")
        init_cluster
        echo "### flume 集群成功初始化并启动 ###"
        ;;
    "-s"|"start")
        start_cluster
        echo "### 成功启动 flume 集群 ###"
        ;;
    "-S"|"stop")
        stop_cluster
        echo "### 成功stop flume 集群 ###"
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
