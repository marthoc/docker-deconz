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
  if [ $DECONZ_VNC_PORT -lt 5900 ]; then
    echo "Invalid VNC Port. DECONZ_VNC_PORT must be larger than 5900"
    exit 1
  fi
  DECONZ_VNC_DISPLAY=:$(($DECONZ_VNC_PORT - 5900))
  echo "[marthoc/deconz] VNC Display: $DECONZ_VNC_DISPLAY on port $DECONZ_VNC_PORT"
  
  if [ ! -e /root/.vnc ]; then
  	mkdir /root/.vnc
  fi
  echo "$DECONZ_VNC_PASSWORD" | tigervncpasswd -f > /root/.vnc/passwd
  chmod 600 /root/.vnc/passwd

  tigervncserver -SecurityTypes VncAuth,TLSVnc "$DECONZ_VNC_DISPLAY"
  export DISPLAY=$DECONZ_VNC_DISPLAY
else
  echo "[marthoc/deconz] Starting without VNC GUI"
  DECONZ_OPTS="$DECONZ_OPTS -platform minimal"
fi

if [ "$DECONZ_DEVICE" != 0 ]; then
  DECONZ_OPTS="$DECONZ_OPTS --dev=$DECONZ_DEVICE"
fi

/usr/bin/deCONZ $DECONZ_OPTS
