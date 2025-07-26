#!/bin/sh
echo "⏳ Attente de Redis sur redis:6379..."

# Essaye toutes les 1s jusqu'à succès
while ! nc -z redis 6379; do
  echo "Redis pas encore prêt, nouvelle tentative..."
  sleep 1
done

echo "✅ Redis est prêt, démarrage de LiveKit"
exec /bin/livekit-server --config /livekit.yaml
