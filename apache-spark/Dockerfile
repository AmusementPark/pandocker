# apache spark

FROM ilpan/base-java
MAINTAINER ilpan<pna.dev@outlook.com>

ENV CANDIDATES /usr/local/.jenv/candidates
ENV SPARK_HOME $CANDIDATES/spark/current/

RUN cd /tmp && \
    wget -c http://mirrors.hust.edu.cn/apache/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz && \
    mkdir $CANDIDATES/spark && \
    tar -xzf spark-2.3.0-bin-hadoop2.7.tgz -C ${CANDIDATES}/spark/ && \
    cd $CANDIDATES && mv ./spark/spark-2.3.0-bin-hadoop2.7 ./spark/2.3.0-hadoop2.7 && \
    source "${HOME}/.jenv/bin/jenv-init.sh" && \
    jenv default spark 2.3.0-hadoop2.7 && \
    rm -rf /tmp/*
