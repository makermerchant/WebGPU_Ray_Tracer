# Builds the static site (home page, viewer, examples) and serves it with Caddy.
# Build from the repository root: docker build -f deploy/Dockerfile .
FROM node:22-bookworm-slim AS build
WORKDIR /app
COPY package.json package-lock.json ./
# --ignore-scripts skips `prepare` (the npm library build), which the site does not need.
RUN npm ci --ignore-scripts
COPY . .
RUN npm run build:site

FROM caddy:2.8-alpine
COPY deploy/Caddyfile /etc/caddy/Caddyfile
COPY --from=build /app/dist-site /srv
