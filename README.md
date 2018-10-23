## deCONZ Docker Image

[![Build Status](https://travis-ci.org/marthoc/docker-deconz.svg?branch=master)](https://travis-ci.org/marthoc/docker-deconz)

This Docker image containerizes the deCONZ software from Dresden Elektronik, which controls a ZigBee network using a Conbee USB or RaspBee GPIO serial interface. This image runs deCONZ in "minimal" mode, for control of the ZigBee network via the WebUIs ("Wireless Light Control" and "Phoscon") and over the REST API and Websockets.

Conbee is supported on `amd64` and `armhf` (i.e. RaspberryPi 2/3) architectures; RaspBee is supported on `armhf` (and see the "Configuring Raspbian for RaspBee" section below for instructions to configure Raspbian to allow access to the RaspBee serial hardware).

This image is available on (and should be pulled from) Docker Hub: `marthoc/deconz`.

Current deCONZ version: **2.05.42**

### Running the deCONZ Container

#### Command Line

```bash
docker run -d \
    --name=deconz \
    --net=host \
    --restart=always \
    --/etc/localtime:/etc/localtime:ro \
    -v /opt/deconz:/root/.local/share/dresden-elektronik/deCONZ \
    --device=/dev/ttyUSB0 \
    marthoc/deconz
```

#### Command line Options

|Parameter|Description|
|---------|-----------|
|`--name=deconz`|Names the container "deconz".|
|`--net=host`|Uses host networking mode for proper uPNP functionality; by default, the web UIs and REST API listen on port 80 and the websockets service listens on port 443. If these ports conflict with other services on your host, you can change them through the environment variables DECONZ_WEB_PORT and DECONZ_WS_PORT described below.|
|`--restart=always`|Start the container when Docker starts (i.e. on boot/reboot).|
|`-v /etc/localtime:/etc/localtime:ro`|Ensure the container has the correct local time (alternatively, use the TZ environment variable, see below).|
|`-v /opt/deconz:/root/.local/share/dresden-elektronik/deCONZ`|Bind mount /opt/deconz (or the directory of your choice) into the container for persistent storage.|
|`--device=/dev/ttyUSB0`|Pass the serial device at ttyUSB0 (i.e. a Conbee USB device) into the container for use by deCONZ (if using RaspBee, use /dev/ttyAMA0).|
|`marthoc/deconz`|This image uses a manifest list for multiarch support; specifying marthoc/deconz (i.e. marthoc/deconz:latest) will pull the correct version for your arch.|

#### Environment Variables

Use these environment variables to change the default behaviour of the container.

|Parameter|Description|
|---------|-----------|
|`-e DECONZ_WEB_PORT=8080`|By default, the web UIs ("Wireless Light Control" and "Phoscon") and the REST API listen on port 80; only set this environment variable if you wish to change the listen port.|
|`-e DECONZ_WS_PORT=8443`|By default, the websockets service listens on port 443; only set this environment variable if you wish to change the listen port.|
|`-e DEBUG_INFO=1`|Sets the level of the deCONZ command-line flag --dbg-info (default 1).|
|`-e DEBUG_APS=0`|Sets the level of the deCONZ command-line flag --dbg-aps (default 0).|
|`-e DEBUG_ZCL=0`|Sets the level of the deCONZ command-line flag --dbg-zcl (default 0).|
|`-e DEBUG_ZDP=0`|Sets the level of the deCONZ command-line flag --dbg-zdp (default 0).|
|`-e DEBUG_OTAU=0`|Sets the level of the deCONZ command-line flag --dbg-otau (default 0).|
|`-e DECONZ_DEVICE=/dev/ttyUSB1`|By default, deCONZ searches for RaspBee at /dev/ttyAMA0 and Conbee at /dev/ttyUSB0; when using other USB devices (e.g. a Z-Wave stick) deCONZ may not find RaspBee/Conbee properly. Set this environment variable to the same string passed to --device to force deCONZ to use the specific USB device.|
|`-e TZ=America/Toronto`|Set the local time zone so deCONZ has the correct time.|

#### Docker-Compose

A docker-compose.yml file is provided in the root of this image's GitHub repo. You may also copy/paste the following into your existing docker-compose.yml, modifying the options as required (omit the `version` and `services` lines as your docker-compose.yml will already contain these).

```yaml
version: "2"
services:
  deconz:
    image: marthoc/deconz
    container_name: deconz
    network_mode: host
    restart: always
    volumes:
      - /opt/deconz:/root/.local/share/dresden-elektronik/deCONZ
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

#### Running on Docker for Mac / Docker for Windows

The `--net=host` option is not yet supported on Mac/Windows. To run this container on those platforms, explicitly specify the ports in the run command and omit `--net=host`:

```bash
docker run -d \
    --name=deconz \
    -p 80:80 \
    -p 443:443 \
    --restart=always \
    -v /opt/deconz:/root/.local/share/dresden-elektronik/deCONZ \
    --device=/dev/ttyUSB0 \
    -e DECONZ_WEB_PORT=80 \
    -e DECONZ_WS_PORT=443 \
    marthoc/deconz
```

### Configuring Raspbian for RaspBee

By default, Raspbian enables Bluetooth and configures a login shell over serial (tty); you must disable BT, disable the tty, and enable the serial port hardware to allow RaspBee to work properly under Docker.

On a fresh install of Raspbian:
1. `echo 'dtoverlay=pi3-disable-bt' | sudo tee -a /boot/config.txt`
2. `sudo raspi-config`
3. Select `Interfacing Options`
4. Select `Serial`
5. “Would you like a login shell to be accessible over serial?” Select `No`
6. “Would you like the serial port hardware to be enabled?” Select `Yes`
7. Exit raspi-config and reboot

### Updating Conbee/RaspBee Firmware

Firmware updates from the web UI will fail silently. Instead, an interactive utility script is provided as part of this Docker image that you can use to flash your device's firmware. The script has been tested and verified to work for Conbee on amd64 Debian linux and armhf Raspbian Stretch and RaspBee on armhf Raspbian Stretch. To use it, follow the below instructions:

1. Check your deCONZ container logs for the update firmware file name: type `docker logs [container name]`, and look for lines near the beginning of the log that look like this, noting the .CGF file name listed (you'll need this later):
```
GW update firmware found: /usr/share/deCONZ/firmware/deCONZ_Rpi_0x261e0500.bin.GCF
GW firmware version: 0x261c0500
GW firmware version shall be updated to: 0x261e0500
```

2. `docker stop [container name]` or `docker-compose down` to stop your running deCONZ container (you must do this or the firmware update will fail).

3. Invoke the firmware update script: `docker run -it --rm --entrypoint "/firmware-update.sh" --privileged --cap-add=ALL -v /dev:/dev -v /lib/modules:/lib/modules -v /sys:/sys marthoc/deconz`

4. Follow the prompts:
- Enter C for Conbee, or R for RaspBee.
- If flashing Conbee, then enter the number that corresponds to the Conbee device in the listing.
- Type or paste the full file name that corresponds to the file name that you found in the deCONZ container logs in step 1 (or, select a different filename, but you should have a good reason for doing this).
- If the device/number and file name look OK, type Y to start flashing!

5. Restart your deCONZ container (`docker start [container name]` or `docker-compose up`).

#### Firmware Flashing Script FAQ

Q: Why does the script give an error about not being able to unload modules ftdi_sio and usbserial, or that the device couldn't be rest?

A: In order to flash the device, no other program or device on the system can be using these kernel modules or the device. Stop any program/container that could be using the modules or device (likely deCONZ) and then invoke the script again. If the error persists, you may need to temporarily remove other USB serial devices from the system in order allow the script to completely unload the kernel modules.

### Gotchas / Known Issues

Firmware updates from the web UI will fail silently and the Conbee/RaspBee device will stay at its current firmware level. See "Updating Conbee/RaspBee Firmware" above for instructions to update your device's firmware when a new version is available.

Over-the-air update functionality is currently untested.

### Issues / Contributing

Please raise any issues with this container at its GitHub repo: https://github.com/marthoc/docker-deconz. Please check the "Gotchas / Known Issues" section above before raising an Issue on GitHub in case the issue is already known.

To contribute, please fork the GitHub repo, create a feature branch, and raise a Pull Request; for simple changes/fixes, it may be more effective to raise an Issue instead.

### Building Locally

Pulling `marthoc/deconz` from Docker Hub is the recommended way to obtain this image. However, you can build this image locally by:

```bash
git clone https://github.com/marthoc/docker-deconz.git
cd docker-deconz
docker build -t "[your-user/]deconz[:local]" ./[arch]
```

|Parameter|Description|
|---------|-----------|
|`[your-user/]`|Your username (optional).|
|`deconz`|The name you want the built Docker image to have on your system (default: deconz).|
|`[local]`|Adds the tag `:local` to the image (to help differentiate between this image and your locally built image) (optional).|
|`[arch]`|The architecture you want to build for (currently supported options: `amd64` and `armhf`).|

### Acknowledgments

Dresden Elektronik for making deCONZ and the Conbee and RaspBee hardware.

@krallin for his "tini" container init process: https://github.com/krallin/tini.
