#!/bin/sh

echo "[marthoc/deconz] Starting deCONZ..."
echo "[marthoc/deconz] Current deCONZ version: $DECONZ_VERSION"
echo "[marthoc/deconz] Web UI port: $DECONZ_WEB_PORT"
echo "[marthoc/deconz] Websockets port: $DECONZ_WS_PORT"

DECONZ_OPTS="--auto-connect=1 \
        --dbg-info=$DEBUG_INFO \
        --dbg-aps=$DEBUG_APS \
        --dbg-zcl=$DEBUG_ZCL \
        --dbg-zdp=$DEBUG_ZDP \
        --dbg-otau=$DEBUG_OTAU \
        --http-port=$DECONZ_WEB_PORT \
        --ws-port=$DECONZ_WS_PORT"

if [ "$DECONZ_VNC_MODE" != 0 ]; then

  DECONZ_VNC_DISPLAY=:0
  echo "[marthoc/deconz] VNC port: $DECONZ_VNC_PORT"
  
  if [ ! -e /root/.vnc ]; then
    mkdir /root/.vnc
  fi
  
  # Set VNC password
  echo "$DECONZ_VNC_PASSWORD" | tigervncpasswd -f > /root/.vnc/passwd
  chmod 600 /root/.vnc/passwd

  # Cleanup previous VNC session data
  tigervncserver -kill "$DECONZ_VNC_DISPLAY"

  # Set VNC security
  tigervncserver -SecurityTypes VncAuth,TLSVnc "$DECONZ_VNC_DISPLAY"
  
  # Export VNC display variable
  export DISPLAY=$DECONZ_VNC_DISPLAY
else
  echo "[marthoc/deconz] VNC Disabled"
  DECONZ_OPTS="$DECONZ_OPTS -platform minimal"
fi

if [ "$DECONZ_DEVICE" != 0 ]; then
  DECONZ_OPTS="$DECONZ_OPTS --dev=$DECONZ_DEVICE"
fi

if [ "$DECONZ_UPNP" != 1 ]; then
  DECONZ_OPTS="$DECONZ_OPTS --upnp=0"
fi

/usr/bin/deCONZ $DECONZ_OPTS
