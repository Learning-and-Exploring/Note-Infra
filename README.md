# Note-Infra

Journey of CI


Frontend (5173)  ──▶  Nginx (80/443)  ──▶  API (4000)




docker compose -f docker-compose.dev.yml --env-file .env down
docker compose -f docker-compose.dev.yml --env-file .env up -d


cd ~/Coding/NodeJS/Note/infra
docker compose -f docker-compose.dev.yml --env-file .env down
docker rmi ghcr.io/oeun-nuphea/note-api:latest
docker compose -f docker-compose.dev.yml --env-file .env up -d --build


chmod +x restart-dev.sh

# one cmd for all
./restart-dev.sh