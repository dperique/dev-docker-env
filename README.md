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
