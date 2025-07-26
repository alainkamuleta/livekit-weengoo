#!/bin/sh

REDIS_HOST="redis"
REDIS_PORT=6379

echo "⏳ Attente que Redis soit prêt à ${REDIS_HOST}:${REDIS_PORT}..."

# Essaye de se connecter à Redis 20 fois (10 secondes max)
for i in $(seq 1 20); do
  if nc -z "$REDIS_HOST" "$REDIS_PORT"; then
    echo "✅ Redis est prêt !"
    exec /bin/livekit-server --config /livekit.yaml
    exit 0
  fi
  echo "❌ Redis pas encore dispo, tentative $i/20"
  sleep 0.5
done

echo "❌ Échec : Redis n'est pas disponible après 10 secondes."
exit 1
