#!/bin/bash

init_sh="/usr/local/.jenv/bin/jenv-init.sh"

docker exec -it kafka0 bash -c "source $init_sh && kafka-topics.sh --create --zookeeper zk0:2181,zk1:2181,zk2:2181 --replication-factor 1 --partitions 3 --topic user_behavior"

docker exec -it kafka0 bash -c "source $init_sh && kafka-topics.sh --zookeeper zk0:2181,zk1:2181,zk2:2181 --describe --topic user_behavior"
