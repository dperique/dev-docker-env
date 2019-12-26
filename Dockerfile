# Run the container on a secure machine.  This is assumed to be your machine
# and you secured it well.

# docker build --build-arg mypassword=S0m3th1ngS3cu43!
# docker run --name kuul18 -h kuul18 -p 2025:22 -p 5910:5910 -v ~/Downloads:/home/dperique/Downloads -d kuul-schubert:latest 
# ssh -p 2025 -o "StrictHostKeyChecking no" -i ~/.ssh/junk.id_rsa dperiquet@127.0.0.1

FROM ubuntu:18.04

# Pass in your password.
#
ARG mypassword

RUN apt-get update
RUN apt-get upgrade

# Install some tools that you might want to use (feel free to tweak this list)
#
RUN apt-get -y install jq
RUN apt-get -y install python3 python-tox python-pip
RUN apt-get -y install sudo libgnutls30
RUN apt-get -y install vim vim-common vim-runtime
RUN apt-get -y install curl
RUN apt-get -y install --only-upgrade bash sudo
RUN apt-get -y install --only-upgrade libgnutls30 libseccomp2
RUN apt-get -y install --only-upgrade curl
RUN apt-get -y install --only-upgrade libdb5.3 libexpat1
RUN apt-get -y install --only-upgrade bzip2 libbz2-1.0
RUN apt-get -y install --only-upgrade vim-common vim vim-runtime
RUN apt-get -y install --only-upgrade libseccomp2 libsqlite3-0

RUN pip install --upgrade tox
RUN pip install --upgrade pip
RUN pip install pyyaml
RUN pip install ansible-modules-hashivault>=3.9.4

RUN apt-get install -y vim tree inetutils-ping git tcpdump psmisc sudo curl net-tools moreutils

# Install kubectl.
#
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.4/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl

# Install older ansible for kubespray work.
#
RUN pip install ansible\<=2.4.1

# Turn on ssh so you can login.  Note the password is NOT secure so use at own risk.
#
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo "root:${mypassword}" | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Add some favorite users and some ssh enviroments for them.
# You can comment any of these lines out if you don't need any extra keys, etc.
#
RUN useradd -rm -d /home/bonnyci   -s /bin/bash -g root -G sudo -u 1000 bonnyci
RUN useradd -rm -d /home/dperiquet -s /bin/bash -g root -G sudo -u 1009 dperiquet
USER bonnyci
WORKDIR /home/bonnyci
RUN mkdir .ssh
ADD id_rsa_github ./.ssh/id_rsa_github
ADD authorized_keys ./.ssh
ADD id_rsa ./.ssh
RUN mkdir periodics
ADD build_it.sh ./periodics

# Drop any private keys in if you need them.  For example, "vicky key" is used in
# certain work areas.  I put authorized keys and known_hosts as needed so I can
# login in a way similar to my other servers.
#
USER dperiquet
WORKDIR /home/dperiquet
RUN mkdir .ssh
ADD id_rsa_vicky ./.ssh/id_rsa
ADD authorized_keys ./.ssh
ADD known_hosts ./.ssh

USER root
WORKDIR /home/bonnyci
RUN chown bonnyci .ssh/id_rsa_github
RUN chown bonnyci .ssh/id_rsa
RUN chmod 600 .ssh/id_rsa_github
RUN chmod 600 .ssh/id_rsa
RUN chmod 644 .ssh/authorized_keys

WORKDIR /home/dperiquet
RUN chmod 600 .ssh/id_rsa
RUN chown dperiquet .ssh/id_rsa
RUN chown dperiquet .ssh/known_hosts

# Install tigervnc as your vnc server.
#
RUN sudo apt-get -y install tigervnc-standalone-server tigervnc-xorg-extension tigervnc-viewer

# use xfce4 as a light window manager that seems to work ok in a container.
#
RUN sudo DEBIAN_FRONTEND=noninteractive  apt -y install xfce4 xfce4-goodies
RUN sudo apt -y install xfce4 xfce4-goodies

# Clean what you can via cli on xfce4.
#
RUN sudo apt-get -y install software-properties-common
RUN sudo apt -y purge xscreensaver

# Install chrome, VS code, gitkraken.
# You will have to download these and put them into your current directory so the images
# can be installed.
#
# Note: you have to run chrome like this: "google-chrome-stable --no-sandbox"
#
RUN wget -nv https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN mv google-chrome-stable_current_amd64.deb /tmp
COPY code_1.41.1-1576681836_amd64.deb /tmp
COPY gitkraken-amd64.deb /tmp
RUN sudo apt -y install /tmp/google-chrome-stable_current_amd64.deb
RUN sudo apt -y install /tmp/code_1.41.1-1576681836_amd64.deb
RUN sudo apt -y install /tmp/gitkraken-amd64.deb

RUN echo "bonnyci:${mypassword}" | chpasswd
RUN adduser bonnyci sudo
RUN echo "dperiquet:${mypassword}" | chpasswd
RUN adduser dperiquet sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN mkdir /home/dperiquet/.vnc
RUN chown dperiquet /home/dperiquet/.vnc
ADD xstartup-xf /home/dperiquet/.vnc/xstartup
RUN chown dperiquet /home/dperiquet/.vnc/xstartup
RUN chmod a+x /home/dperiquet/.vnc/xstartup
ADD vnc_pass /home/dperiquet/.vnc/passwd
RUN chown dperiquet /home/dperiquet/.vnc/passwd


# Can't do this since it asks for password.
#
# vncserver :10 -geometry 1280x1024 -depth 24 -localhost no

# SSH login fix. Otherwise user is kicked off after login
CMD sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

#EXPOSE 22
CMD ["sudo", "/usr/sbin/sshd", "-D"]

USER dperiquet
WORKDIR /home/dperiquet
#ENTRYPOINT ["./keriodic.sh", "zfs-patching"]