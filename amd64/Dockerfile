FROM ubuntu:latest
LABEL version="2020-07-27" 

# Build environment variables
ENV TINI_VERSION=0.18.0 \
    DECONZ_VERSION=2.05.79

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

# Runtime environment variables
ENV DECONZ_WEB_PORT=80 \
    DECONZ_WS_PORT=443 \
    DEBUG_INFO=1 \
    DEBUG_APS=0 \
    DEBUG_ZCL=0 \
    DEBUG_ZDP=0 \
    DEBUG_OTAU=0 \
    DECONZ_DEVICE=0 \
    DECONZ_VNC_MODE=0 \
    DECONZ_VNC_DISPLAY=0 \
    DECONZ_VNC_PASSWORD=changeme \
    DECONZ_VNC_PORT=5900 \
    DECONZ_UPNP=1

# Add tini, start.sh, and Conbee udev data; set execute permissions
ADD https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini /tini
# Add deCONZ, install deCONZ, make OTAU dir
ADD http://deconz.dresden-elektronik.de/ubuntu/beta/deconz-${DECONZ_VERSION}-qt5.deb /deconz.deb

COPY root /
RUN chmod +x /tini && \
    chmod +x /start.sh && \
    chmod +x /firmware-update.sh && \
    mkdir /root/otau

# Install deCONZ dependencies
RUN DEBIAN_FRONTEND="noninteractive" apt-get update && \
    apt-get install -y \
    curl \
    kmod \
    libcap2-bin \
    libqt5core5a \
    libqt5gui5 \
    libqt5network5 \
    libqt5serialport5 \
    libqt5sql5 \
    libqt5websockets5 \
    libqt5widgets5 \
    lsof \
    sqlite3 \
    tigervnc-standalone-server \
    tigervnc-common \
    i3-wm \
    xfonts-base \
    xfonts-scalable && \
    dpkg -i /deconz.deb && \
    rm -f /deconz.deb && \
    chown root:root /usr/bin/deCONZ* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

VOLUME [ "/root/.local/share/dresden-elektronik/deCONZ" ]

EXPOSE ${DECONZ_WEB_PORT} ${DECONZ_WS_PORT} ${DECONZ_VNC_PORT}

ENTRYPOINT [ "/tini", "--", "/start.sh" ]
