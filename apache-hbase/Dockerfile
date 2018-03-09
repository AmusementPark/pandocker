# apache hbase

FROM ilpan/apache-hadoop
MAINTAINER ilpan<ilpan.dev@outlook.com>

USER hdp
WORKDIR /home/hdp

ENV CANDIDATES /usr/local/.jenv/candidates/
ENV HBASE_HOME ${CANDIDATES}/hbase/current/
ENV ZOOKEEPER_HOME ${CANDIDATES}/zookeeper/current/

# install hbase and zookeeper
# zookeeper 3.4.x and hadoop 2.7.1+ for hbase 2.x or 1.x
RUN source "${HOME}/.jenv/bin/jenv-init.sh" && \
    jenv install zookeeper 3.4.10 && \
    mkdir ${CANDIDATES}/hbase && cd /usr/local/.jenv/archives/ && \ 
    wget -c http://mirrors.hust.edu.cn/apache/hbase/1.4.1/hbase-1.4.1-bin.tar.gz && \
    tar -xzf hbase-1.4.1-bin.tar.gz -C ${CANDIDATES}/hbase/ && \
    cd ${CANDIDATES}/hbase && mv hbase-1.4.1 1.4.1 && jenv default hbase 1.4.1 && \
    rm -rf /usr/local/.jenv/archives/*

COPY ./conf/zoo.cfg ${ZOOKEEPER_HOME}/conf/
COPY ./conf/hbase-env.sh ${HBASE_HOME}/conf/
COPY ./conf/hbase-site.xml ${HBASE_HOME}/conf/
COPY ./conf/regionservers ${HBASE_HOME}/conf/
COPY ./conf/backup-masters ${HBASE_HOME}/conf/

# 16000: hbase.master.port
# 16010: hbase.master.info.port(web ui)
EXPOSE 16000
EXPOSE 16010
# 16020: hbase.regionserver.port
# 16030: hbase.RegionServer.info.port(web ui)
EXPOSE 16020
EXPOSE 16030
