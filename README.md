# Building a Development Environment in a Container

Most of us Kubernetes nuts like containers.  So every time we want to do something, it ends
up in a container eventually.  This situation is no different.  I like to do development
of many types and as such, I need an enviroment to work with. The enviroments tend to be
headless on some cloud where I would use simple tools like vim to do all my work.

But, now I found VS code and gitkraken so now I need a screen.  To achieve this, I use
vncserver.  I still want the environments to be containerized because I'd like to spin them
up quickly and tear them down as needed.

## Quick startup

There's a docker image already built that contains just ubuntu18, ssh, vnc (tigervnc) and xfce4.
I call this my "base" image.  So all you need to do is this:

```bash
docker run --name testb -h testb -p 2024:22 -p 5930:5930 -d dperique/ubuntu18-vnc-xfce4-ssh:v1
ssh -p 2024 ubuntu@127.0.0.1
login as ubuntu/ubuntu
./vnc.sh
```

The `/home/ubuntu/vnc.sh` script inside the container contains the command
`vncserver :30 -geometry 1280x1024 -depth 24 -localhost no"` so you don't have to remember how to
startup vncserver.

Point your vncviewer to 127.0.0.1:30 or `ssh -p 2024 ubuntu@127.0.0.1`

## My customizations

There's another docker image already built which is the "base" image above plus my username/account called
`dperiquet` and VS code, gitkracken, and firefox already installed.  The instructions are similar.  You can
build a similar image using the `Dockerfile.dperiquet` in this repo.  See that file at the top for instructions.

I then have `Dockerfile` which has all my special keys specific to my environment.  For obvious reasons, I
will not publish that image.  But you can use it as a guide to build one for yourself.

## Problems

I've tried Firefox, Chrome, and Chromium browsers and both eventually crash.  I don't know why.

Before starting gitkracken, set the default browser to be Firefox, start Firefox, quit Firefox.  Then
start gitkracken and when you select "Sign in with Github", it will be able to launch a browser page for
you to login.

## Use case

I use this container to build the `openshift-tests` binary when doing Openshift 4.x testing.

Put a clone of the https://github.com/openshift/origin repo in the mounted dir and realize we will
create the `openshift-tests` there.  It will build and you can run htop in another window.

Also note that I'm using go 1.20 -- but tweak it to use the latest compatible golang with that the `origin`
repo uses.

```
docker stop testb ; docker rm testb
docker run --name testb -h testb -v /Users/dperique/yada/origin:/origin -d dperique/ubuntu18-vnc-xfce4-ssh:v1
docker exec -ti testb bash
sudo su
apt update && apt install -y vim htop
wget https://go.dev/dl/go1.20.linux-amd64.tar.gz && rm -rf /usr/local/go && tar -C /usr/local -xzf go1.20.linux-amd64.tar.gz
exit
echo "export PATH=$PATH:/usr/local/go/bin" >> .bashrc
export PATH=$PATH:/usr/local/go/bin
cd /origin
echo `grep module go.mod |awk '{print $2}'`
go build -gcflags='-N -l' `grep "module " go.mod |awk '{print $2}'`/cmd/openshift-tests
go test -v -timeout 30s -run ^TestKnownBugEvents$ github.com/openshift/origin/pkg/synthetictestss
```

The `openshift-tests` binary will be there in your local machine's directory (but it will be built for ubuntu20).
