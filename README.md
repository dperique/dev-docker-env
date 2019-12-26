# Building a Development Environment in a Container

Most of us Kubernetes nuts like containers.  So everytime we want to do something, it ends
up in a container eventually.  This situation is no different.  I like to do development
of many types and as such, I need an enviroment to work with. The enviroments tend to be
headless on some cloud where I would use simple tools like vim to do all my work.

But, now I found VS code and gitkraken so now I need a screen.  To achieve this, I use
vncserver.

## How to build it

Build like this:

```bash
git clone https://github.com/dperique/dev-docker-env.git
cd dev-docker-env
docker build --build-arg mypassword=S0m3th1ngS3cu43! -t myimage:latest .
```

The `docker build` will take several minutes to build but you'll only have to do this once.

Sample output when the image is built:

```bash
$ docker images|grep myimage
myimage                                                     latest              292968e3b2da        13 seconds ago      2.56GB
```

## Startup the container

Before starting up the container, consider giving your docker installation some extra RAM depending on
what you intend to run. I have mine 4G or RAM and 2 CPUs.

See how I map port 2024 to port 22 (ssh port) and vncserver port at 5910.  I also mount my
local downloads folder so I can access to those files from within the continaer.

```bash
$ docker run --name test1 -h test1 -p 2024:22 -p 5910:5910 -v ~/Downloads:/home/dperique/Downloads -d myimage:latest
9ff2c389f5e9b5ad67e9b494743f9a6b26cdcfc5203861e3f3aa0d04fa2c6d65

$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                          NAMES
9ff2c389f5e9        myimage:latest      "sudo /usr/sbin/sshd…"   4 seconds ago       Up 3 seconds        0.0.0.0:5910->5910/tcp, 0.0.0.0:2024->22/tcp   test1
```

If the `docker ps` output shows empty, you'll have to figure out what went wrong using commands
like:

```bash
docker ps -a
docker logs xxxx (where xxxx is the container name)
```

## Login to the container

You'll have to login using ssh on port 2024 so you can startup the vncserver on port
5910.

```bash
ssh -p 2024 -o "StrictHostKeyChecking no" dperiquet@127.0.0.1
```

In the container, you'll have to startup vncserver.  Note that we already made a vnc password
to help get you running -- it's "password".  Change it to make it more secure by running the
`vncpasswd` command while inside the container.

```bash
dperiquet@test1:~$ vncpasswd
Password: ((Sometime really strong))
Verify:
Would you like to enter a view-only password (y/n)? n
dperiquet@test1:~$
```

## Start vncserver

Start the vncserver like this:

```bash
vncserver :10 -geometry 1280x1024 -depth 24 -localhost no
```

I did this:

* Configured `:10` as the window since that's what I mapped in the `docker run` command
* Set the geometry, arbitrarily, as `1280x24` -- you can change it in the graphical UI
* Set the depth to be 24 since that seems to work well
* Configured the vncserver to listen on all interfaces of the container; this is so that
  I can point the vnc client to any address of the container.

## Start the vnc client

Go to [real vnc](https://www.realvnc.com/en/connect/download/viewer/macos/) to download a
vnc client.  I chose the one for OSX.

Point your vnc client to 127.0.0.1:10 and enter your password.

I set picture quality to "Medium".

## Fixup and Customize the Container

In the UI, I automatically ran `vncconfig -iconify` so that cut/paste will work across
your desktop and into the vnc session.  You can use shift-control-c and shift-control-v to
copy and paste respectively.

Once in the xfce4 UI:

* Click Applications->Settings->PreferredApplications, for web browser, select "Other ...", enter
`/usr/bin/google-chrome-stable --no-sandbox`, then click Close.
* Click the globe at the bottom to start Chrome
  * Make Chrome the default browser.
* Click Applications->TerminalEmulator to get a Terminal
  * From within the Terminal, type `code &` to start Visual Studio Code
  * From within the Terminal, type `gitkraken &` to start Gitkraken

## Problems

I've tried both Firefox and Chrome and both browsers crash on pages.  I don't know why.
