# apache hadoop

FROM ilpan/base-java
MAINTAINER ilpan<pna.dev@outlook.com>

RUN bash -c "source ~/.jenv/bin/jenv-init.sh && jenv install hadoop 2.7.2" && \ 
    rm -rf /usr/local/.jenv/archives/*

ENV HADOOP_HOME /usr/local/.jenv/candidates/hadoop/current/

COPY ./conf/hadoop-env.sh $HADOOP_HOME/etc/hadoop/
COPY ./conf/core-site.xml $HADOOP_HOME/etc/hadoop/
COPY ./conf/hdfs-site.xml $HADOOP_HOME/etc/hadoop/
COPY ./conf/mapred-site.xml $HADOOP_HOME/etc/hadoop/
COPY ./conf/yarn-site.xml $HADOOP_HOME/etc/hadoop/
COPY ./conf/slaves $HADOOP_HOME/etc/hadoop/

# 持久化存储
VOLUME ["/data/hadoop/tmp","/data/hadoop/dfs/name","/data/hadoop/dfs/data","/data/hadoop/dfs/namesecondary"]

EXPOSE 50070
EXPOSE 8088
