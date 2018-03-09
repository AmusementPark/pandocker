#!/bin/bash

print_usage() {
    echo "Run hbase distributed cluster based on hdfs with Zookeeper on docker use docker-compose"
    echo ""
    echo "Usage: $0 [init|start|stop|remove]"
    echo ""
    echo "    -i|init   : Init and start hhbase cluster"
    echo "    -s|start  : Start hbase cluster"
    echo "    -S|stop   : Stop hbase cluster"
    echo "    -r|remove : Remove hbase cluseter and related settings"
}

if [ $# -ne 1 ]; then
    print_usage
    exit 1
fi


# 创建并启动容器
function create_cluster() {
    docker-compose up -d hmaster 
}

hbases=("hbase-master" "hbase-regionserver1" "hbase-regionserver2" "hbase-regionserver3")
zks=${hbases:1}
# 启动 Zookeeper 集群
function start_zk_cluster() {
    for zk in ${zks[@]}
    do
        docker exec -it ${zk} bash -c "source /home/hdp/.jenv/bin/jenv-init.sh && zkServer.sh start"
    done
}

# 配置容器间免密登录
function login_without_passwd() {
    for hbase in ${hbases[@]}
    do
        docker exec -it ${hbase} bash -c "ssh-keygen -t rsa -P '' &&  chmod 700 /home/hdp/.ssh && chmod 600 /home/hdp/.ssh/id_rsa && cat /home/hdp/.ssh/id_rsa.pub >> /home/hdp/.ssh/authorized_keys && chmod 644 /home/hdp/.ssh/authorized_keys"
    done
    # hadoop-master & hadoop-slave* 是主机名，为了与 ilpan/apache-hadoop中的配置一致 (虽然也可以修改)
    docker exec -it hbase-master bash -c "ssh-copy-id hadoop-slave1 && ssh-copy-id hadoop-slave2 && ssh-copy-id hadoop-slave3"
    docker exec -it hbase-regionserver1 bash -c "ssh-copy-id hadoop-master && ssh-copy-id hadoop-slave2 && ssh-copy-id hadoop-slave3"
    docker exec -it hbase-regionserver2 bash -c "ssh-copy-id hadoop-master && ssh-copy-id hadoop-slave1 && ssh-copy-id hadoop-slave3"
    docker exec -it hbase-regionserver3 bash -c "ssh-copy-id hadoop-master && ssh-copy-id hadoop-master && ssh-copy-id hadoop-slave2"
}

function start_daemon() {
    docker exec -it hbase-master bash -c "source /home/hdp/.jenv/bin/jenv-init.sh && jenv cd hadoop && sbin/start-all.sh && sbin/hadoop-daemon.sh start zkfc && start-hbase.sh && jps"
    # 启动 backup master
    docker exec -it hbase-regionserver1 bash -c "source /home/hdp/.jenv/bin/jenv-init.sh && hbase-daemon.sh start master && jps"
}

# 初始化
function init() {
    docker exec -it hbase-master bash -c "source /home/hdp/.jenv/bin/jenv-init.sh && hdfs zkfc -formatZK && hadoop namenode -format"
    start_daemon
}

function init_cluster() {
    create_cluster
    start_zk_cluster
    login_without_passwd
    init
}


function start_cluster() {
    docker-compose start
    start_zk_cluster
    start_daemon
}


function stop_daemon() {
    # 关闭 backup master
    docker exec -it hbase-regionserver1 bash -c "source /home/hdp/.jenv/bin/jenv-init.sh && hbase-daemon.sh stop master"
    docker exec -it hbase-master bash -c "source /home/hdp/.jenv/bin/jenv-init.sh && stop-hbase.sh && jenv cd hadoop && sbin/hadoop-daemon.sh stop zkfc && sbin/stop-all.sh && zkServer.sh stop"
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
