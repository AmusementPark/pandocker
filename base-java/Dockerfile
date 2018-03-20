FROM ilpan/base-ssh
MAINTAINER ilpan<pna.dev@outlook.com>

# install jenv
RUN curl -L -s get.jenv.io | bash && \ 
    source "${HOME}/.jenv/bin/jenv-init.sh" && \ 
    jenv selfupdate && jenv config auto true && \ 
    mv ${HOME}/.jenv /usr/local/ && ln -s /usr/local/.jenv ${HOME}/.jenv

# install java
RUN bash -c "source ~/.jenv/bin/jenv-init.sh && jenv install java 1.8.0_112 && rm -rf /usr/local/.jenv/archives/*"
