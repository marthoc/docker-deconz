#!/bin/sh

echo "Starting deCONZ..."

/usr/bin/deCONZ \
    -platform minimal \
    --auto-connect=1 \
    --dbg-info=1 \
    --dbg-error=1 \
    --dbg-aps=1 \
    --http-port=$DECONZ_WEB_PORT \
    --ws-port=$DECONZ_WS_PORT