# Building a Development Environment in a Container

Most of us Kubernetes nuts like containers.  So everytime we want to do something, it ends
up in a container eventually.  This situation is no different.  I like to do development
of many types and as such, I need an enviroment to work with. The enviroments tend to be
headless on some cloud where I would use simple tools like vim to do all my work.

But, now I found VS code and gitkraken so now I need a screen.  To achieve this, I use
vncserver.

# How to build it

Build like this:

```
git clone https://github.com/dperique/dev-docker-env.git
cd dev-docker-env
docker build --build-arg mypassword=S0m3th1ngS3cu43! -t myimage:latest .
```

The `docker build` will take several minutes to build but you'll only have to do this once.

Sample output when the image is built:

```
$ docker images|grep myimage
myimage                                                     latest              292968e3b2da        13 seconds ago      2.56GB
```

# Startup the container

See how I map port 2024 to port 22 (ssh port) and vncserver port at 5910.  I also mount my
local downloads folder so I can access to those files from within the continaer.

```
$ docker run --name test1 -h test1 -p 2024:22 -p 5910:5910 -v ~/Downloads:/home/dperique/Downloads -d myimage:latest
9ff2c389f5e9b5ad67e9b494743f9a6b26cdcfc5203861e3f3aa0d04fa2c6d65

$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                          NAMES
9ff2c389f5e9        myimage:latest      "sudo /usr/sbin/sshd…"   4 seconds ago       Up 3 seconds        0.0.0.0:5910->5910/tcp, 0.0.0.0:2024->22/tcp   test1
```

If the `docker ps` output shows empty, you'll have to figure out what went wrong using commands
like:

```
docker ps -a
docker logs xxxx (where xxxx is the container name)
```

# Login to the container

You'll have to login using ssh on port 2024 so you can startup the vncserver on port
5910.

```
$ ssh -p 2024 -o "StrictHostKeyChecking no" dperiquet@127.0.0.1
```


docker run --name kuul18 -h kuul18 -p 2025:22 -p 5910:5910 -v ~/Downloads:/home/dperique/Downloads -d kuul-schubert:latest 
ssh -p 2025 -o "StrictHostKeyChecking no" -i ~/.ssh/junk.id_rsa dperiquet@127.0.0.1
