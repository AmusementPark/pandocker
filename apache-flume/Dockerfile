# Apache Zookeeper

FROM ilpan/base-java
MAINTAINER ilpan<pna.dev@outlook.com>

USER hdp

ENV JENV_HOME /usr/local/.jenv
ENV FLUME_HOME $JENV_HOME/candidates/flume

# install zookeeper
RUN source "${HOME}/.jenv/bin/jenv-init.sh" && \
    mkdir -p .jenv/candidates/flume/ && cd $JENV_HOME/archives/ && \
    wget -c https://mirrors.tuna.tsinghua.edu.cn/apache/flume/1.8.0/apache-flume-1.8.0-bin.tar.gz && \
    tar -xzf apache-flume-1.8.0-bin.tar.gz && mv apache-flume-1.8.0-bin $FLUME_HOME/1.8.0 && jenv default flume 1.8.0 && \
    rm -rf $JENV_HOME/archives/*

