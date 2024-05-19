#!/bin/sh 

# Fail on first error
set -e

# Install the theme for fancyindex into the internal directory
curl -L https://github.com/mirror-mwt/mwt-fancyindex-theme/archive/refs/heads/main.tar.gz |
tar xz -C /srv/www/internal --strip-components=2 mwt-fancyindex-theme-main/dist

# Install the universal installation script into the internal directory
curl -L https://gist.githubusercontent.com/mwt/1bc605c6fbcef451142cf145b8518439/raw/install.sh -o /srv/www/internal/universal-install.sh

# Run nginx in the foreground
nginx -g "daemon off;"
