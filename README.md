# LiveKit Weengoo Infrastructure

This repo contains Docker Compose setups for:
- LiveKit server (livekit.weengoo.net)
- Redis (local)
- TURN server (turn.weengoo.net)
- All services connect via a shared Docker network `weengoo-net`
- Nginx reverse proxy with Let's Encrypt (configured separately)

## Start services

docker network create weengoo-net
docker compose -f docker-compose.redis.yaml up -d
docker compose -f docker-compose.turn.yaml up -d
docker compose -f docker-compose.livekit.yaml up -d


## Notes
- TURN secret must match in both `turnserver.conf` and `livekit.yaml`
- Ports 3478, 7880-7881, 50000-60000/udp must be open


Commit et push

git add .
git commit -m "Initial Docker setup for LiveKit, Redis, TURN"
git push origin main


----------------------------------------------------------
INFRASTRUCTURE D3X LIVEKIT
----------------------------

# Architecture de l'infrastructure LiveKit + TURN

## Vue d'ensemble

L'infrastructure est hébergée sur un seul serveur public (IP : `54.36.103.240`) et se compose des éléments suivants :

### 1. Nginx Reverse Proxy + Certbot (Natif)

- Nginx agit comme reverse proxy HTTPS pour d'autres services (LiveKit n'en dépend pas directement).
- Certbot gère les certificats TLS via Let's Encrypt.
- Le certificat pour TURN est renouvelé automatiquement avec un hook personnalisé.

### 2. Services Docker dans `/home/alain/livekit-weengoo/docker-compose.yaml`

- **Redis**
  - Exposé localement sur le port `6379`
  - Utilisé par LiveKit comme base de données temporaire
- **Coturn (TURN server)**
  - Ports exposés : `3478` TCP+UDP et `5349` TCP (TLS)
  - Certificat TLS utilisé : fourni par Certbot via `/etc/letsencrypt/live/turn.weengoo.net`

### 3. Certificat TLS pour TURN

- Certbot gère les certificats dans `/etc/letsencrypt/live/turn.weengoo.net/`
- Script de déploiement automatique :
  ```bash
  /etc/letsencrypt/renewal-hooks/deploy/deploy-turn.sh
  ```
- Ce script copie les fichiers TLS (certificat + clé privée) dans le conteneur Coturn (via volume ou `docker cp`) ou dans un répertoire surveillé par Coturn, puis redémarre le service.

### 4. LiveKit (Natif)

- Installé dans `/home/alain/livekit-weengoo/livekit`
- Mode de lancement : via `systemd`
- Fichier de service : `/etc/systemd/system/livekit.service`

Exemple de contenu du fichier :

```ini
[Unit]
Description=LiveKit SFU
After=network.target docker.service

[Service]
User=alain
WorkingDirectory=/home/alain/livekit-weengoo
ExecStart=/home/alain/livekit-weengoo/livekit --config /home/alain/livekit-weengoo/livekit.yaml
Restart=on-failure
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
```

## Configuration des ports (pare-feu)

Assurez-vous que les ports suivants sont ouverts sur le pare-feu (UFW, iptables, etc.) :

- `3478` TCP/UDP
- `5349` TCP
- `6379` (local uniquement si Redis est en local)
- Ports définis dans la config `livekit.yaml` (par défaut HTTP 7880, UDP 50000-60000)

---

## Déploiement GitHub

Pour versionner cette infrastructure sur GitHub :

### 1. Initialiser un dépôt

```bash
cd /home/alain/livekit-weengoo
git init
git remote add origin git@github.com:<votre_user>/livekit-weengoo.git
```

### 2. Ajouter les fichiers importants

```bash
git add docker-compose.yaml livekit.yaml deploy-turn.sh README.md
```

### 3. Commit et push

```bash
git commit -m "Initial commit: infra LiveKit + TURN + Redis"
git push -u origin master
```

> ✉️ **Astuce** : n'oubliez pas d'ajouter un `.gitignore` pour exclure les certificats et fichiers sensibles !

Exemple `.gitignore` :

```
*.pem
*.key
*.crt
*.log
.env
certs/
```


