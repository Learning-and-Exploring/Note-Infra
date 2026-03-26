# Note Deployment Guide

This project deploys as four containers:

- `note-api`: Express + Prisma API
- `note-web`: built Vite frontend served by Nginx
- `db-postgres`: PostgreSQL
- `nginx`: public reverse proxy for HTTPS and routing

Traffic flow:

```text
Internet -> infra/nginx -> note-web
                    -> note-api
                    -> db-postgres
```

## 1. Requirements

- A Linux server with Docker and Docker Compose
- A domain name pointed to the server
- TLS certificate files for that domain
- A GitHub repository that can publish images to GHCR
- Real values for database credentials, JWT secrets, admin secret, ImageKit, and VAPID keys

## 2. Images Built By CI

Two GitHub Actions workflows publish images to GitHub Container Registry:

- API image: [Prisma/.github/workflows/docker.yml](/home/nuphea/Coding/NodeJS/Note/Prisma/.github/workflows/docker.yml)
- Web image: [note/.github/workflows/docker.yml](/home/nuphea/Coding/NodeJS/Note/note/.github/workflows/docker.yml)

Images are tagged as:

```text
ghcr.io/<owner>/note-api:latest
ghcr.io/<owner>/note-api:<git-sha>
ghcr.io/<owner>/note-web:latest
ghcr.io/<owner>/note-web:<git-sha>
```

### GitHub settings

Set these before deploying:

- Repository branch for release: `main`
- Repository variable `VITE_API_URL`
  Use your public API base, for example `https://app.example.com`
- Repository variable `VITE_VAPID_PUBLIC_KEY`
  Use the browser public VAPID key

If your packages are private, authenticate on the server before pulling:

```bash
echo '<github_pat>' | docker login ghcr.io -u <github_username> --password-stdin
```

## 3. Server Files

Work from the `infra` directory:

```bash
cd /path/to/Note/infra
```

Create the runtime env file from the example:

```bash
cp .env.example .env
```

The runtime stack is defined in [docker-compose.prod.yml](/home/nuphea/Coding/NodeJS/Note/infra/docker-compose.prod.yml).

## 4. Configure Environment

Edit `infra/.env` and set all required values.

Example:

```env
POSTGRES_USER=note
POSTGRES_PASSWORD=replace-with-strong-password
POSTGRES_DB=note_db

NOTE_API_IMAGE=ghcr.io/<owner>/note-api:latest
NOTE_WEB_IMAGE=ghcr.io/<owner>/note-web:latest

ADMIN_SECRET=replace-with-strong-secret
ACCESS_TOKEN_SECRET=replace-with-strong-secret
REFRESH_TOKEN_SECRET=replace-with-strong-secret
ACCESS_TOKEN_EXPIRES_IN=15m
REFRESH_TOKEN_EXPIRES_IN=7d

FRONTEND_URL=https://app.example.com
FRONTEND_URL_DE=https://app.example.com
BASE_URL=https://app.example.com

IMAGEKIT_PUBLIC_KEY=...
IMAGEKIT_PRIVATE_KEY=...
IMAGEKIT_URL_ENDPOINT=...

VAPID_PUBLIC_KEY=...
VAPID_PRIVATE_KEY=...
VAPID_SUBJECT=mailto:admin@example.com
```

Notes:

- `BASE_URL` should be the public base URL used by the backend.
- `FRONTEND_URL` and `FRONTEND_URL_DE` must match the browser origin allowed by CORS.
- `NOTE_API_IMAGE` and `NOTE_WEB_IMAGE` can use `latest` or an exact commit SHA.
- Do not commit the filled `.env` file.

## 5. TLS Certificates

Production Nginx expects these files:

```text
infra/nginx/ssl/fullchain.pem
infra/nginx/ssl/privkey.pem
```

Create the directory if needed:

```bash
mkdir -p nginx/ssl
```

Copy your certificate files into that directory.

The public proxy config is in [nginx/nginx.prod.conf](/home/nuphea/Coding/NodeJS/Note/infra/nginx/nginx.prod.conf).

## 6. Deploy

Pull the latest published images and start the stack:

```bash
docker compose -f docker-compose.prod.yml --env-file .env pull
docker compose -f docker-compose.prod.yml --env-file .env up -d
```

For a fresh install, this is enough. The API container runs Prisma migrations on startup.

## 7. Update To A New Release

When a new image is published:

```bash
docker compose -f docker-compose.prod.yml --env-file .env pull
docker compose -f docker-compose.prod.yml --env-file .env up -d
```

If you pin images by SHA, update `NOTE_API_IMAGE` and `NOTE_WEB_IMAGE` in `.env` first.

## 8. Verify Deployment

Check container status:

```bash
docker compose -f docker-compose.prod.yml --env-file .env ps
```

Check logs:

```bash
docker compose -f docker-compose.prod.yml --env-file .env logs -f app
docker compose -f docker-compose.prod.yml --env-file .env logs -f web
docker compose -f docker-compose.prod.yml --env-file .env logs -f nginx
```

Useful endpoints:

- App: `https://app.example.com`
- API health: `https://app.example.com/healthz`
- Swagger: `https://app.example.com/api-docs`
- Metrics: `https://app.example.com/metrics`

## 9. Roll Back

If you tag and keep previous SHA images, rollback is simple:

1. Update `NOTE_API_IMAGE` and `NOTE_WEB_IMAGE` in `infra/.env` to the older SHA tags.
2. Redeploy with:

```bash
docker compose -f docker-compose.prod.yml --env-file .env pull
docker compose -f docker-compose.prod.yml --env-file .env up -d
```

## 10. Local Production Config Check

Before deploying, validate the compose file:

```bash
docker compose -f docker-compose.prod.yml --env-file .env config
```

## Related Files

- Backend image: [Prisma/Dockerfile](/home/nuphea/Coding/NodeJS/Note/Prisma/Dockerfile)
- Backend env template: [Prisma/.env.example](/home/nuphea/Coding/NodeJS/Note/Prisma/.env.example)
- Frontend image: [note/Dockerfile](/home/nuphea/Coding/NodeJS/Note/note/Dockerfile)
- Frontend env template: [note/.env.example](/home/nuphea/Coding/NodeJS/Note/note/.env.example)
- Production compose: [infra/docker-compose.prod.yml](/home/nuphea/Coding/NodeJS/Note/infra/docker-compose.prod.yml)
- Production proxy: [infra/nginx/nginx.prod.conf](/home/nuphea/Coding/NodeJS/Note/infra/nginx/nginx.prod.conf)
