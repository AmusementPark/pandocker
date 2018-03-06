FROM centos:6.6
MAINTAINER ilpan<pna.dev@outlook.com>

RUN yum install -y unzip which tar sudo net-tools \ 
        openssh-server openssh-clients rsync wget axel && \ 
        yum clean all

# ssh service
RUN mkdir -p /var/run/sshd

RUN ssh-keygen -t rsa -P '' -f /etc/ssh/ssh_host_rsa_key && \ 
        ssh-keygen -t dsa -P '' -f /etc/ssh/ssh_host_dsa_key && \ 
        ssh-keygen -t ecdsa -P '' -f /etc/ssh/ssh_host_ecdsa_key
#        ssh-keygen -t ed25519 -P '' -f /etc/ssh/ssh_host_ed25519_key 

RUN /bin/sed -i 's/.*session.*required.*pam_limits.so.*/session    optional     pam_limits.so/g' /etc/pam.d/sshd

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
