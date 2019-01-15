FROM marthoc/deconz:amd64

# Add Hass.io-specific start script
COPY run.sh /
RUN chmod +x /run.sh

# Create directory for persistent Hass.io config data
# Workaround to persist ZigBee network data: change root's home dir to /data
RUN mkdir /data && \
    mkdir /data/.vnc && \
    sed -i 's/\/root/\/data/' /etc/passwd && \
    chown root:root /usr/bin/deCONZ*

VOLUME [ "/data" ]

# Hass.io-specific labels
LABEL io.hass.version="${DECONZ_VERSION}" \ 
      io.hass.type="addon" \
      io.hass.arch="armhf|amd64"

ENTRYPOINT [ "/tini", "-s", "--", "/run.sh" ]