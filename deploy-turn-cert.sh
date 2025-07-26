#!/bin/bash

CERT_SRC="/etc/letsencrypt/live/turn.weengoo.net"
CERT_DST="/home/alain/livekit-weengoo/certs"

install -m 644 "$CERT_SRC/fullchain.pem" "$CERT_DST/turn.crt"
install -m 600 "$CERT_SRC/privkey.pem" "$CERT_DST/turn.key"

# Redémarrer Coturn
# docker restart coturn
