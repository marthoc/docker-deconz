#!/bin/sh

echo "[marthoc/deconz] Starting deCONZ..."
echo "[marthoc/deconz] Current deCONZ version: $DECONZ_VERSION"
echo "[marthoc/deconz] Web UI port: $DECONZ_WEB_PORT"
echo "[marthoc/deconz] Websockets port: $DECONZ_WS_PORT"

/usr/bin/deCONZ \
    -platform minimal \
    --auto-connect=1 \
    --dbg-info=$DEBUG_INFO \
    --dbg-aps=$DEBUG_APS \
    --dbg-zcl=$DEBUG_ZCL \
    --dbg-zdp=$DEBUG_ZDP \
    --dbg-otau=$DEBUG_OTAU \
    --http-port=$DECONZ_WEB_PORT \
    --ws-port=$DECONZ_WS_PORT