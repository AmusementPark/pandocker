# Apache Zookeeper

FROM ilpan/base-java
MAINTAINER ilpan<pna.dev@outlook.com>

ENV JENV_HOME /usr/local/.jenv
ENV ZOOKEEPER_HOME $JENV_HOME/candidates/zookeeper

# install zookeeper
RUN mkdir -p ${ZOOKEEPER_HOME} && cd $JENV_HOME/archives/ && \
    wget -c https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz && \
    tar -xzf zookeeper-3.4.10.tar.gz && mv zookeeper-3.4.10 $ZOOKEEPER_HOME/3.4.10 && \
    bash -c "source ~/.jenv/bin/jenv-init.sh && jenv default zookeeper 3.4.10" && \
    rm -rf $JENV_HOME/archives/*

