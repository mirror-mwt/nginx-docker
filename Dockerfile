FROM debian:bookworm-slim

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    nginx-core libnginx-mod-http-fancyindex \
    curl ca-certificates \
    ssl-cert

COPY nginx/mirror /etc/nginx/sites-enabled/mirror

COPY --chmod=0755 setup-web-root.sh /setup-web-root.sh

RUN ["/setup-web-root.sh"]

CMD ["nginx", "-g", "daemon off;"]