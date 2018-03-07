#!/bin/bash

# WARNING: 慎重使用
# 使用root或者sudo运行
if [ `id -u` -ne 0  ]; then
    echo "Please use sudo or root to run it"
    exit 1
fi


v_exists=0
function exists() {
    docker ps -a | fgrep $1 1>/dev/null 2>&1
    if [ $? -eq 0 ]; then
	v_exists=1	
    fi
}

v_is_running=0
function is_running() {
    docker ps | fgrep $1 1>/dev/null 2>&1
    if [ $? -eq 0 ]; then
	v_is_running=1
    fi
}

echo "Deleting Cluster"

hadoops=("hadoop-master" "hadoop-slave1" "hadoop-slave2" "hadoop-slave3")
for hadoop in ${hadoops[@]}
do
    exists ${hadoop} 
#    echo "v_exists ${v_exists}"
    if [ ${v_exists} -eq 1 ]; then
	is_running ${hadoop}
#	echo "v_is_running ${v_is_running}"
	if [ ${v_is_running} -eq 1 ]; then
    	    echo "stoping ${hadoop}"
            docker stop ${hadoop} 1>/dev/null 2>&1
            echo "${hadoop} stoped"
	fi
	echo "deleting ${hadoop}"
    	docker rm ${hadoop} 1>/dev/null 2>&1
    	echo "${hadoop} deleted"
    fi
done

echo "Cluster Deleted "
