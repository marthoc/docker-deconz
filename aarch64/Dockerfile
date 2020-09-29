FROM balenalib/aarch64-debian:stretch-run

# Build arguments
ARG VERSION
ARG CHANNEL

# Runtime environment variables
ENV DECONZ_VERSION=${VERSION} \
    DECONZ_WEB_PORT=80 \
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

# Install deCONZ dependencies
RUN apt-get update && \
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
        wmii \
        xfonts-base \
        xfonts-scalable && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# WORKAROUND: update libc6 so flashing script works
# This can be removed when the base image includes GLIBC >= 2.28
RUN echo "deb http://ftp.us.debian.org/debian sid main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install --only-upgrade -y \
        libc6 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add start.sh and Conbee udev data; set execute permissions
COPY root /
RUN chmod +x /start.sh && \
    chmod +x /firmware-update.sh

# Add deCONZ, install deCONZ, make OTAU dir
ADD http://deconz.dresden-elektronik.de/debian/${CHANNEL}/deconz_${DECONZ_VERSION}-debian-stretch-${CHANNEL}_arm64.deb /deconz.deb
RUN dpkg -i /deconz.deb && \
    rm -f /deconz.deb && \
    mkdir /root/otau && \
    chown root:root /usr/bin/deCONZ*

VOLUME [ "/root/.local/share/dresden-elektronik/deCONZ" ]

EXPOSE ${DECONZ_WEB_PORT} ${DECONZ_WS_PORT} ${DECONZ_VNC_PORT}

CMD [ "bash", "/start.sh" ]
