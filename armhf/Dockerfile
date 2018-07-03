FROM resin/armv7hf-debian:stretch

# Build environment variables
ENV TINI_VERSION=0.18.0 \
    DECONZ_VERSION=2.05.31 \
    WIRINGPI_VERSION="2.44+1"

# Runtime environment variables
ENV DECONZ_WEB_PORT=80 \
    DECONZ_WS_PORT=443 \
    DEBUG_INFO=1 \
    DEBUG_APS=0 \
    DEBUG_ZCL=0 \
    DEBUG_ZDP=0 \
    DEBUG_OTAU=0

# Install deCONZ dependencies (except for WiringPi)
RUN apt-get update && \
    apt-get install -y \
        curl \
        jq \
        kmod \
        libcap2-bin \
        libqt5core5a \
        libqt5gui5 \
        libqt5network5 \
        libqt5serialport5 \
        libqt5sql5 \
        libqt5websockets5 \
        libqt5widgets5 \
        sqlite3 \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add WiringPi, install WiringPi
ADD https://archive.raspberrypi.org/debian/pool/main/w/wiringpi/wiringpi_${WIRINGPI_VERSION}_armhf.deb /wiringpi.deb
RUN dpkg -i /wiringpi.deb && \
    rm -f /wiringpi.deb

# Add tini, start.sh, and Conbee udev data; set execute permissions
ADD https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-armhf /tini
COPY root /
RUN chmod +x /tini && \
    chmod +x /start.sh && \
    chmod +x /firmware-update.sh

# Add deCONZ, install deCONZ, make OTAU dir
ADD https://www.dresden-elektronik.de/rpi/deconz/beta/deconz-${DECONZ_VERSION}-qt5.deb /deconz.deb
RUN dpkg -i /deconz.deb && \
    rm -f /deconz.deb && \
    mkdir /root/otau && \
    chown root:root /usr/bin/deCONZ*

VOLUME [ "/root/.local/share/dresden-elektronik/deCONZ" ]

EXPOSE ${DECONZ_WEB_PORT} ${DECONZ_WS_PORT}

ENTRYPOINT [ "/tini", "--", "/start.sh" ]
