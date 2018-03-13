FROM debian:stretch-slim

# Build environment variables
ENV TINI_VERSION=0.17.0
ENV DECONZ_VERSION=2.05.12

# Runtime environment variables
ENV DECONZ_WEB_PORT=80
ENV DECONZ_WS_PORT=443

# Add tini, start.sh, and Conbee udev data; set execute permissions
ADD https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini /tini
COPY root /
RUN chmod +x /tini && \
    chmod +x /start.sh

# Add deCONZ, install dependencies, install deCONZ 
ADD https://www.dresden-elektronik.de/deconz/ubuntu/beta/deconz-${DECONZ_VERSION}-qt5.deb /deconz.deb
RUN apt-get update && \
    apt-get install -y \
        libcap2-bin \
        libqt5core5a \
        libqt5gui5 \
        libqt5network5 \
        libqt5serialport5 \
        libqt5sql5 \
        libqt5websockets5 \
        libqt5widgets5 \
        sqlite3 && \
    rm -rf /var/lib/apt/lists/*
RUN dpkg -i /deconz.deb && \
    rm -f /deconz.deb

VOLUME [ "/root/.local/share/dresden-elektronik/deCONZ" ]

EXPOSE ${DECONZ_WEB_PORT} ${DECONZ_WS_PORT}

ENTRYPOINT [ "/tini", "--", "/start.sh" ]
