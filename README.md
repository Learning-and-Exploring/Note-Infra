# Note-Infra

Journey of CI


Frontend (5173)  ──▶  Nginx (80/443)  ──▶  API (4000)




docker compose -f docker-compose.dev.yml --env-file .env down
docker compose -f docker-compose.dev.yml --env-file .env up -d