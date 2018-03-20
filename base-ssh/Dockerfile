FROM ubuntu:16.04
MAINTAINER ilpan<pna.dev@outlook.com>

RUN apt-get update && apt-get install -y unzip net-tools \ 
    openssh-server openssh-client rsync wget axel tar curl && \ 
    apt-get clean

RUN echo 'root:root' |chpasswd

# change default shell
RUN usermod -s /bin/bash root

# ssh service
RUN mkdir -p /var/run/sshd

RUN sed -i 's/.*session.*required.*pam_limits.so.*/session optional pam_limits.so/g' /etc/pam.d/sshd
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/.*StrictHostKeyChecking ask/StrictHostKeyChecking no/' /etc/ssh/ssh_config

# 直接在此处设置免密登录,便于后续的操作
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \ 
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 700 ~/.ssh && \
    chmod 600 ~/.ssh/id_rsa && \
    chmod 644 ~/.ssh/authorized_keys

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
