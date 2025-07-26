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


