# LiveKit Infrastructure – MimosaCall / Weengoo

## 🌍 Infrastructure Overview

| Serveur              | Rôle                                   | IP              | Nom(s) de domaine             |
|----------------------|----------------------------------------|------------------|-------------------------------|
| **vps-weengoo (ext)**| Reverse proxy + TLS + déploiement cert | 54.36.103.240    | livekit.weengoo.net, turn.weengoo.net |
| **livekit-lxc (int)**| LiveKit + TURN + Redis                 | 192.168.4.103    | interne derrière pfSense      |

## 🔐 Certificats TLS

- Certificats Let's Encrypt générés sur le serveur public `54.36.103.240` via Certbot.
- Déploiement automatique vers `/home/alain/livekit-weengoo/certs/` sur `192.168.4.103` via script hook `deploy-turn.sh`.

---

## 🚀 Installation des composants

### 1. LiveKit Server (sur 192.168.4.103)

#### 📁 Arborescence :
/home/alain/livekit-weengoo/
├── certs/                   # contient turn.crt / turn.key
├── deploy-turn-cert.sh      # copie les certs de Let's Encrypt localement
├── docker-compose.yaml      # pour Redis
├── livekit.yaml             # configuration LiveKit
├── redis.conf               # config redis
└── livekit.service          # service systemd

#### ⚙️ Fichier `livekit.yaml` (extrait) :
```yaml
port: 7880
rtc:
  udp_port: 7881
  port_range_start: 50000
  port_range_end: 60000
  use_external_ip: true

redis:
  address: localhost:6379
  db: 0
  use_tls: false

turn:
  enabled: true
  domain: turn.weengoo.net
  tls_port: 5349
  udp_port: 3478
  cert_file: /home/alain/livekit-weengoo/certs/turn.crt
  key_file: /home/alain/livekit-weengoo/certs/turn.key

keys:
  APIo9NHV7gBiwcf: ZnaddCRseDvRA9L3VUu0Bya4HAtDHfxeVj9Mn84Ky5IA
```

#### 🧠 Lancement :
```bash
# Redis
docker compose -f docker-compose.yaml up -d

# LiveKit
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now livekit
```

---

### 2. Certbot & Déploiement TLS (sur 54.36.103.240)

#### 📁 Fichiers :
/etc/letsencrypt/renewal-hooks/deploy/deploy-turn.sh  
/home/alain/livekit-weengoo/deploy-turn-cert.sh

#### 📝 Script `deploy-turn-cert.sh`
```bash
#!/bin/bash

CERT_SRC="/etc/letsencrypt/live/turn.weengoo.net"
CERT_DST="/home/alain/livekit-weengoo/certs"

install -m 644 "$CERT_SRC/fullchain.pem" "$CERT_DST/turn.crt"
install -m 600 "$CERT_SRC/privkey.pem" "$CERT_DST/turn.key"
```

#### 📝 Hook `/etc/letsencrypt/renewal-hooks/deploy/deploy-turn.sh`
```bash
#!/bin/bash
/home/alain/livekit-weengoo/deploy-turn-cert.sh
```

---

## 📡 Reverse Proxy (sur 54.36.103.240)

Via Nginx, les domaines suivants sont redirigés :
- `https://livekit.weengoo.net` → `http://192.168.4.103:7880`
- `turn.weengoo.net:5349` → redirigé directement vers port Docker ou local

---

## 🔁 Renouvellement automatique TLS

```bash
sudo certbot renew --dry-run
```

---

## 🐙 Déploiement sur GitHub

### 1. Configure ton dépôt
```bash
cd /home/alain/livekit-weengoo
git init
git remote add origin git@github.com:ton-utilisateur/livekit-weengoo.git
```

### 2. Ajoute un `.gitignore`
Voir fichier `.gitignore` plus haut.

### 3. Commit & push
```bash
git add .
git commit -m "Mise à jour complète de l'infrastructure LiveKit (prod)"
git branch -M main
git push -u origin main
```
