**For Testing Only**

deCONZ version: **2.05.12**

```
docker run -d \
    --name=deconz \
    -p 10800:80 \
    -p 443:443 \
    -v /opt/deconz:/root/.local/share/dresden-elektronik/deCONZ \
    --device=/dev/ttyUSB0 \
    --privileged \
    roflmao/deconz:2.05.10
```

Running with --net=host is also possible to allow for uPNP discovery on the network:

```
docker run -d \
     --name=deconz \
     --net=host \
     -v /opt/deconz:/root/.local/share/dresden-elektronik/deCONZ \
     --device=/dev/ttyUSB0 \
     --privileged \
     -e DECONZ_WEB_PORT=8080 \
     -e DECONZ_WS_PORT=8443 \
     roflmao/deconz:2.05.10
```

It's not necessary to specify DECONZ_WEB_PORT and DECONZ_WS_PORT if the defaults (80 and 443) are acceptable for your setup. But if there is a conflict, change those environment variables to specify the ports you want the web and websockets services to run under.

Notes: 
- `--privileged` is required; from previous testing this only became necessary in the late .90's series of deCONZ beta releases, but now the container must be created with --privileged or deCONZ will fail to start.
- deCONZ is run with --dbg-info --dbg-error and --dbg-aps flags, generating a lot of debug output in the Docker log to help with testing.
- Currently only amd64 and Conbee are supported; armhf and RaspBee support will be added soon.
