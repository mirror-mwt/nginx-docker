FROM debian:trixie-slim

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    nginx-core libnginx-mod-http-fancyindex \
    curl ca-certificates \
    ssl-cert

COPY nginx/mirror /etc/nginx/sites-enabled/mirror

COPY --chmod=0755 setup-web-root.sh /setup-web-root.sh
COPY --chmod=0755 entrypoint.sh /entrypoint.sh

RUN ["/setup-web-root.sh"]

ENTRYPOINT ["/entrypoint.sh"]
