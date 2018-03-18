#!/bin/bash

print_usage() {
    echo "Run Spark distributed cluster based on hdfs and YARN on docker use docker-compose"
    echo ""
    echo "Usage: $0 [init|start|stop|remove]"
    echo ""
    echo "    -i|init   : Init and start hspark cluster"
    echo "    -s|start  : Start spark cluster"
    echo "    -S|stop   : Stop spark cluster"
    echo "    -r|remove : Remove spark cluseter and related settings"
}

if [ $# -ne 1 ]; then
    print_usage
    exit 1
fi


# 创建并启动容器
function create_cluster() {
    docker-compose up -d spark-master
}

sparks=("spark-master" "spark-worker1" "spark-worker2" "spark-worker3")

# 配置容器间免密登录
function login_without_passwd() {
    for spark in ${sparks[@]}
    do
        # 顺便做些相关设置
        docker exec -it ${spark} bash -c "sudo mkdir -p /data/ && sudo chown -R hdp:hadoop /data/"
        docker exec -it ${spark} bash -c "sudo sed -i 's/#.*StrictHostKeyChecking ask/StrictHostKeyChecking no/' /etc/ssh/ssh_config"
        docker exec -it ${spark} bash -c "ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa &&  chmod 700 /home/hdp/.ssh && chmod 600 /home/hdp/.ssh/id_rsa && cat /home/hdp/.ssh/id_rsa.pub >> /home/hdp/.ssh/authorized_keys && chmod 644 /home/hdp/.ssh/authorized_keys"
    done
    docker exec -it spark-master bash -c "ssh-copy-id spark-worker1 && ssh-copy-id spark-worker2 && ssh-copy-id spark-worker3"
    docker exec -it spark-worker1 bash -c "ssh-copy-id spark-master && ssh-copy-id spark-worker2 && ssh-copy-id spark-worker3"
    docker exec -it spark-worker2 bash -c "ssh-copy-id spark-master && ssh-copy-id spark-worker1 && ssh-copy-id spark-worker3"
    docker exec -it spark-worker3 bash -c "ssh-copy-id spark-master && ssh-copy-id spark-worker1 && ssh-copy-id spark-worker2"
}

function start_daemon() {
    # 先偷个懒，start-all启动
    docker exec -it spark-master bash -c "source /home/hdp/.jenv/bin/jenv-init.sh && jenv cd spark && sbin/start-all.sh && jps"
}


function init_cluster() {
    create_cluster
    login_without_passwd
    start_daemon
}


function start_cluster() {
    docker-compose start
    start_daemon
}


function stop_daemon() {
    docker exec -it spark-master bash -c "source /home/hdp/.jenv/bin/jenv-init.sh && jenv cd spark && sbin/stop-all.sh"
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
