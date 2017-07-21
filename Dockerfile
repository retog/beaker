FROM node:6.2.1-onbuild
# Expose the SSH port
EXPOSE 22

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server \
    x11-apps xterm libgtk2.0-0 libxss1 libgconf-2-4 libnss3 libasound2 \
    libtool m4 automake make g++

# Create OpenSSH privilege separation directory
RUN mkdir /var/run/sshd 

RUN adduser --disabled-password --gecos "User" --uid 2000 user

# to allow adding the public key e.g. with docker exec -i beaker /bin/bash -c 'cat > /home/user/.ssh/authorized_keys' < ~/.ssh/id_rsa.pub
RUN mkdir /home/user/.ssh/

RUN echo X11UseLocalhost no >> /etc/ssh/sshd_config
RUN echo PermitRootLogin without-password >> /etc/ssh/sshd_config
RUN echo PermitRootLogin yes >> /etc/ssh/sshd_config
RUN echo "root:beaker" | chpasswd
# RUN cd /usr/src/app && npm run rebuild
RUN cat /etc/ssh/sshd_config  | grep -v without- > /etc/ssh/sshd_config-new \
        && rm /etc/ssh/sshd_config && mv /etc/ssh/sshd_config-new /etc/ssh/sshd_config
VOLUME /home/user

# Start SSH
CMD mkdir -p /home/user/.ssh/ && chown -R user:user /home/user \ 
    && /usr/sbin/sshd -D