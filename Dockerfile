FROM debian:bookworm-slim

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    nginx-core libnginx-mod-http-fancyindex

COPY nginx/mirror /etc/nginx/sites-enabled/mirror

ADD https://github.com/mirror-mwt/mwt-fancyindex-theme/archive/refs/heads/main.tar.gz /fancyindex