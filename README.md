## deCONZ Docker Image

This image containerizes the deCONZ software from Dresden Elektronik, which controls a ZigBee network using a Conbee USB or RaspBee serial interface. _Note: Currently, only the Conbee USB device is supported by this image; support for RaspBee will be added soon._

This image currently supports Conbee on both `amd64` and `armhf` (i.e. RaspberryPi 2/3) architectures.

Current deCONZ version: **2.05.08**

### Running the deCONZ Container

#### Command Line

```bash
docker run -d \
    --name=deconz \
    --net=host \
    --restart=always \
    --privileged \
    -v /opt/deconz:/root/.local/share/dresden-elektronik/deCONZ \
    --device=/dev/ttyUSB0 \
    -e DECONZ_WEB_PORT=8080 \
    -e DECONZ_WS_PORT=8443 \
    marthoc/deconz
```

#### Command line Options:  

`--name deconz`: Names the container "deconz".  
`--net=host`: Uses host networking mode for proper uPNP functionality; by default, the web UIs listen on port 80 and the websockets service listens on port 443. If these ports conflict with other services on your host, you can change them through the environment variables DECONZ_WEB_PORT and DECONZ_WS_PORT described below.  
`--restart=always`: Start the container when Docker starts (i.e. on boot/reboot).  
`--privileged`: Required; from previous testing privilege mode only became necessary in the late .90's series of deCONZ beta releases, but now the container must be privileged or deCONZ will fail to start.  
`-v /opt/deconz:/root/.local/share/dresden-elektronik/deCONZ`: Bind mount /opt/deconz (or the directory of your choice) into the container for persistent storage.  
`--device=/dev/ttyUSB0`: Pass the serial device at ttyUSB0 (i.e. a Conbee USB device) into the container for use by deCONZ.  
`marthoc/deconz`: This image uses a manifest list for multiarch support; specifying marthoc/deconz (i.e. marthoc/deconz:latest) will pull the correct version for your arch.

#### Environment Variables:

`-e DECONZ_WEB_PORT=8080`: By default, the web UIs (Wireless Light and Phoscon) listen on port 80; only set this environment variable if you wish to change the listen port.  
`-e DECONZ_WS_PORT=8443`: By default, the websockets service listens on port 443; only set this environment variable if you wish to change the listen port.  
`-e DEBUG_INFO=1`: Sets the level of the deCONZ command-line flag --dbg-info (default 1).  
`-e DEBUG_APS=0`: Sets the level of the deCONZ command-line flag --dbg-aps (default 0).  
`-e DEBUG_ZCL=0`: Sets the level of the deCONZ command-line flag --dbg-zcl (default 0).  
`-e DEBUG_ZDP=0`: Sets the level of the deCONZ command-line flag --dbg-zdp (default 0).  
`-e DEBUG_OTAU=0`: Sets the level of the deCONZ command-line flag --dbg-otau (default 0).  

#### Docker-Compose:

A docker-compose.yml file is provided in the root of this image's GitHub repo. You may also copy/paste the following into your existing docker-compose.yml, modifying the options as required (omit the `version` and `services` lines as your docker-compose.yml will already contain these).

```yaml
version: "2"
services: 
  deconz:
    image: marthoc/deconz
    container_name: deconz
    network_mode: host
    restart: always
    privileged: true
    volumes:
      - /opt/deconz:/root/.local/share/dresden-elektronik/deconz
    devices:
      - /dev/ttyUSB0
    environment:
      - DECONZ_WEB_PORT=80
      - DECONZ_WS_PORT=443
      - DEBUG_INFO=1
      - DEBUG_APS=0
      - DEBUG_ZCL=0
      - DEBUG_ZDP=0
      - DEBUG_OTAU=0
```

Then, you can do `docker-compose pull` to pull the latest marthoc/deconz image, `docker-compose up -d` to start the deconz container service, and `docker-compose down` to stop the deconz service and delete the container. Note that these commands will also pull, start, and stop any other services defined in docker-compose.yml.

#### Running on Docker for Mac / Docker for Windows:

The `--net=host` option is not yet supported on Mac/Windows. To run this container on those platforms, explicitly specify the ports in the run command and omit `--net=host`:

```bash
docker run -d \
    --name=deconz \
    -p 80:80 \
    -p 443:443 \
    --restart=always \
    --privileged \
    -v /opt/deconz:/root/.local/share/dresden-elektronik/deCONZ \
    --device=/dev/ttyUSB0 \
    -e DECONZ_WEB_PORT=80 \
    -e DECONZ_WS_PORT=443 \
    marthoc/deconz
```

### Gotchas / Known Issues

armhf is not yet supported, but will be soon.

RaspBee is not yet supported, but will be soon.

Firmware updates from the web UI do not work (they will fail silently and the USB device will stay at its current firmware level).

Over-the-air update functionality is currently untested.

### Issues / Contributing

Please raise any issues with this container at its GitHub repo: https://github.com/marthoc/docker-deconz. Please check the "Gotchas / Known Issues" section above before raising an Issue on GitHub in case the issue is already known.

To contribute, please fork the GitHub repo, create a feature branch, and raise a Pull Request; for simple changes/fixes, it may be more effective to raise an Issue instead.

### Building Locally

Pulling `marthoc/deconz` from Docker Hub is the recommended way to obtain this image. However, you can build this image locally by:

```bash
git clone https://github.com/marthoc/docker-deconz.git
cd docker-deconz
docker build -t "[your-user]/deconz[:local]" ./amd64
```

Where:  
`[your-user]`: Your username (optional).  
`[node-red]`: The name you want the built Docker image to have on your system (default: deconz).  
`[local]`: Adds the tag `:local` to the image (to help differentiate between this image and your locally built image) (optional).  

### Acknowledgments

Dresden Elektronik for making deCONZ and the Conbee and RaspBee hardware.

@krallin for his "tini" container init process: https://github.com/krallin/tini.