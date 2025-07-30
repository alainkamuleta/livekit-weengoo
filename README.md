# LiveKit Infrastructure – MimosaCall / Weengoo

## 🌍 Infrastructure Overview

| Serveur              | Rôle                                   | IP              | Nom(s) de domaine             |
|----------------------|----------------------------------------|------------------|-------------------------------|
| **vps-weengoo (ext)**| Reverse proxy + TLS + déploiement cert | 1.2.x.x    | livekit.example.com, turn.example.com |
| **livekit-lxc (int)**| LiveKit + TURN + Redis                 | 2.3.x.x    | interne derrière pfSense      |


## 🐙 Déploiement sur GitHub

### 1. Configure ton dépôt
```bash
cd /home/alain/livekit
git init
git remote add origin git@github.com:ton-utilisateur/livekit-example.com.git
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
