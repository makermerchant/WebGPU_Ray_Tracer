# Self-hosting on a VPS

Serves the same static site as the Cloudflare deployment (home page, `/viewer/`,
`/examples/`) from a Docker container running Caddy, which obtains and renews the
HTTPS certificate automatically. Default domain: `render.makermerchant.tech`.

## Requirements

- A Linux VPS with Docker Engine and the Compose plugin
  (`curl -fsSL https://get.docker.com | sh`).
- A DNS `A` record (and `AAAA` for IPv6) for `render.makermerchant.tech`
  pointing at the VPS. If the domain is on Cloudflare, use "DNS only" (grey cloud)
  at least until the first certificate is issued.
- Ports 80 and 443 open in the firewall (`ufw allow 80,443/tcp`, plus `443/udp`
  for HTTP/3).

## First deployment

```bash
git clone https://github.com/makermerchant/WebGPU_Ray_Tracer.git /opt/mutracer
cd /opt/mutracer
docker compose -f deploy/docker-compose.yml up -d --build
```

The build takes a few minutes. Open https://render.makermerchant.tech once it is
running; `docker compose -f deploy/docker-compose.yml logs -f` shows certificate
issuance and requests.

## Updating

```bash
/opt/mutracer/deploy/deploy.sh
```

It pulls the checked-out branch and rebuilds the container.

## Options

Set these in the shell or in `deploy/.env`:

| Variable | Default | Meaning |
| --- | --- | --- |
| `SITE_ADDRESS` | `render.makermerchant.tech` | Domain Caddy serves and gets a certificate for. Use `:80` when another proxy terminates TLS. |
| `HTTP_PORT` | `80` | Host port (optionally `ip:port`) mapped to the container's port 80. |
| `HTTPS_PORT` | `443` | Host port (optionally `ip:port`) mapped to the container's port 443. |

### Behind an existing nginx or other proxy

If ports 80/443 are already used by another web server on the VPS, run the
container on plain HTTP on a local port:

```bash
SITE_ADDRESS=:80 HTTP_PORT=127.0.0.1:8080 HTTPS_PORT=127.0.0.1:8443 \
  docker compose -f deploy/docker-compose.yml up -d --build
```

and proxy the domain to it, for example with nginx:

```nginx
server {
    server_name render.makermerchant.tech;
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
    }
    # TLS: run `certbot --nginx -d render.makermerchant.tech`
}
```

## Caveats

- WebGPU requires a secure context: the site must be served over HTTPS (or
  `localhost`), otherwise the renderer is unavailable or falls back to WebGL 2.
- Rendering happens in the visitor's browser on their GPU; the VPS only serves
  static files and needs no GPU.
