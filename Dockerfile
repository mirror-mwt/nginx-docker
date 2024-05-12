FROM debian:bookworm-slim

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    nginx-core libnginx-mod-http-fancyindex \
    curl ca-certificates \
    ssl-cert

COPY nginx/mirror /etc/nginx/sites-enabled/mirror

RUN curl -L https://github.com/mirror-mwt/mwt-fancyindex-theme/archive/refs/heads/main.tar.gz | tar xz -C /

CMD ["nginx", "-g", "daemon off;"]