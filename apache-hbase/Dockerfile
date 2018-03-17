# apache hbase

FROM ilpan/apache-hadoop
MAINTAINER ilpan<ilpan.dev@outlook.com>

USER hdp

ENV CANDIDATES /usr/local/.jenv/candidates/
ENV HBASE_HOME ${CANDIDATES}/hbase/current/

# install hbase
# zookeeper 3.4.x and hadoop 2.7.1+ for hbase 2.x or 1.x
RUN source "${HOME}/.jenv/bin/jenv-init.sh" && \
    cd /usr/local/.jenv/archives/ && \ 
    wget -c http://mirrors.hust.edu.cn/apache/hbase/1.4.1/hbase-1.4.1-bin.tar.gz && \
    tar -xzf hbase-1.4.1-bin.tar.gz -C ${CANDIDATES}/hbase/ && \
    cd ${CANDIDATES}/hbase && mv hbase-1.4.1 1.4.1 && jenv default hbase 1.4.1 && \
    rm -rf /usr/local/.jenv/archives/*
