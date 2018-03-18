# pandocker


## How to use

First of all: clone this rep</br>
**Recommends**：`$ docker pull ilpan/base-java` before you run the following clusters


### usage example ( flume+kafka+spark+hbase+zookeeper )

0. run zookeeper
`$ cd apache-zookeeper/compose && ./compose.sh -i`
1. run kafka
`$ cd apache-kafka/compose && ./compose.sh -i`
2. run flume
`$ cd apache-flume/compose && ./compose.sh -i`
3. run spark
`$ cd apache-spark/compose && ./compose.sh -i`
4. run hbase
`$ cd apache-hbase/compose && ./compose.sh -i`

if it's not your first time to run these cluster, you can replace '-i' with '-s'

And you can enter `$ ./compose.sh -h` for more usage about compose.sh.

---

### running results
`$ dokcer ps`</br>
![docker_ps](./images/docker_ps_result.png)
`$ ping`</br>
![ping_info](./images/ping_result.png)

---

### HOW TO STOP THESE CLUSTERS
0. stop spark
`$ cd apache-spark && ./compose.sh -S`
1. stop flume
`$ cd apache-flume && ./compose.sh -S`
2. stop kafka
`$ cd apache-kafka && ./compose.sh -S`
3. stop hbase
`$ cd apache-hbase && ./compose.sh -S`
4. stop zookeeper
`$ cd apache-zookeeper && ./compose.sh -S`

---
***have fun!***
