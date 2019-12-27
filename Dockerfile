# Run the container on a secure machine.  This is assumed to be your machine
# and you secured it well.

# docker build -t dev-docker-dperiquet:v1 .
# docker run --name testb -h testb -p 2025:22 -p 5910:5910 -d dev-docker-dperiquet:v1
# ssh -p 2025 -o "StrictHostKeyChecking no" -i ~/.ssh/junk.id_rsa dperiquet@127.0.0.1

FROM dperique/ubuntu18-vnc-xfce4-ssh-dperiquet:v1

# Drop any private keys in if you need them.  For example, "vicky key" is used in
# certain work areas.  I put authorized keys and known_hosts as needed so I can
# login in a way similar to my other servers.
#
WORKDIR /home/dperiquet
RUN mkdir .ssh
ADD id_rsa_vicky ./.ssh/id_rsa
ADD authorized_keys ./.ssh
ADD known_hosts ./.ssh

USER root
RUN chmod 600 .ssh/id_rsa
RUN chown dperiquet .ssh/id_rsa
RUN chown dperiquet .ssh/known_hosts

USER dperiquet
RUN command mkdir /home/dperiquet/.vnc
USER root
ADD xstartup-xf /home/dperiquet/.vnc/xstartup
ADD vnc_pass /home/dperiquet/.vnc/passwd
RUN chown dperiquet /home/dperiquet/.vnc/xstartup
RUN chown dperiquet /home/dperiquet/.vnc/passwd

USER dperiquet
RUN echo "password" | vncpasswd -f > /home/dperiquet/.vnc/passwd
RUN echo "#!/bin/bash" > /home/dperiquet/vnc.sh
RUN echo "vncserver :31 -passwd /home/dperiquet/.vnc/passwd -geometry 1280x1024 -depth 24 -localhost no" >> /home/dperiquet/vnc.sh
RUN chmod a+x /home/dperiquet/vnc.sh
