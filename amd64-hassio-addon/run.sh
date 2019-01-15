#!/bin/sh

CONFIG_PATH=/data/options.json

HASSIO_DEBUG_INFO="$(jq --raw-output '.debug_info' $CONFIG_PATH)"
HASSIO_DEBUG_APS="$(jq --raw-output '.debug_aps' $CONFIG_PATH)"
HASSIO_DEBUG_ZCL="$(jq --raw-output '.debug_zcl' $CONFIG_PATH)"
HASSIO_DEBUG_ZDP="$(jq --raw-output '.debug_zdp' $CONFIG_PATH)"
HASSIO_DEBUG_OTAU="$(jq --raw-output '.debug_otau' $CONFIG_PATH)"
HASSIO_DECONZ_WEB_PORT="$(jq --raw-output '.web_port' $CONFIG_PATH)"
HASSIO_DECONZ_WS_PORT="$(jq --raw-output '.websockets_port' $CONFIG_PATH)"
HASSIO_DECONZ_DEVICE="$(jq --raw-output '.deconz_device' $CONFIG_PATH)"
HASSIO_DECONZ_VNC_MODE=":$(jq --raw-output '.vnc.active' $CONFIG_PATH)"
HASSIO_DECONZ_VNC_DISPLAY=":$(jq --raw-output '.vnc.port - 5900' $CONFIG_PATH)"
HASSIO_DECONZ_VNC_PORT="$(jq --raw-output '.vnc.port' $CONFIG_PATH)"
HASSIO_DECONZ_VNC_PASSWORD="$(jq --raw-output '.vnc.password' $CONFIG_PATH)"

DECONZ_OPTS="--auto-connect=1 \
        --dbg-info=$DEBUG_INFO \
        --dbg-aps=$DEBUG_APS \
        --dbg-zcl=$DEBUG_ZCL \
        --dbg-zdp=$DEBUG_ZDP \
        --dbg-otau=$DEBUG_OTAU \
        --http-port=$DECONZ_WEB_PORT \
        --ws-port=$DECONZ_WS_PORT"

echo "[Hass.io] Starting deCONZ Hass.io Addon..."
echo "[Hass.io] Current deCONZ version: $DECONZ_VERSION"
echo "[Hass.io] Web UI port: $HASSIO_DECONZ_WEB_PORT"
echo "[Hass.io] Websockets port: $HASSIO_DECONZ_WS_PORT"
echo "[Hass.io] deCONZ device: $HASSIO_DECONZ_DEVICE"

if [ "$HASSIO_DECONZ_VNC_MODE" == "true" ]; then
  echo "[Hass.io] Starting VNC Server on Port $HASSIO_DECONZ_VNC_PORT"
  if [ ! -e /data/.vnc ]; then
  	mkdir /data/.vnc
  fi
  echo "$HASSIO_DECONZ_VNC_PASSWORD" | tigervncpasswd -f > /data/.vnc/passwd
  chmod 600 /data/.vnc/passwd

  # cleanup previous session data
  tigervncserver -kill "$DECONZ_VNC_DISPLAY"

  tigervncserver -SecurityTypes VncAuth,TLSVnc $HASSIO_DECONZ_VNC_DISPLAY
  export DISPLAY=$HASSIO_DECONZ_VNC_DISPLAY
else
  echo "[Hass.io] Starting in minimal mode, without VNC GUI"
  DECONZ_OPTS="$DECONZ_OPTS -platform minimal"
fi

export USER=root

/usr/bin/deCONZ $DECONZ_OPTS 
    
