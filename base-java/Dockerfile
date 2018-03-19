FROM ilpan/base-ssh
MAINTAINER ilpan<pna.dev@outlook.com>

# add user hdp
RUN groupadd -r hadoop && useradd -r hdp -g hadoop -d /home/hdp && \ 
        mkdir /home/hdp && chown -R hdp:hadoop /home/hdp && \ 
        sed -i '/root.*ALL=(ALL.*).*ALL/a\hdp ALL=(ALL) NOPASSWD:ALL' /etc/sudoers && \ 
        echo 'hdp: ' | chpasswd
USER hdp
WORKDIR /home/hdp

# install jenv
RUN curl -L -s get.jenv.io | bash && \ 
        source "${HOME}/.jenv/bin/jenv-init.sh" && \ 
        jenv selfupdate && jenv config auto true && \ 
        sudo mv ${HOME}/.jenv /usr/local/ && ln -s /usr/local/.jenv ${HOME}/.jenv

# install java
RUN  source "${HOME}/.jenv/bin/jenv-init.sh" && \ 
        jenv install java 1.8.0_112 && \ 
        rm -rf /usr/local/.jenv/archives/*

# enable ssh service here again
CMD ["sudo /usr/sbin/sshd", "-D"]
