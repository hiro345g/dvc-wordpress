#!/bin/sh

# set -x

/bin/bash -c '\
    eval "$(~/.local/bin/mise activate bash)"; \
    curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/home/node/.local/share/mise/installs/php/8.3.36/bin \
    --filename=composer; \
'
