#!/bin/sh

# set -x

# 8.2.30 は `composer diagnose` で `Checking pubkeys:` が FAIL になるので対応
/bin/bash -c '\
    eval "$(~/.local/bin/mise activate bash)"; \
    curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/home/node/.local/share/mise/installs/php/8.2.30/bin \
    --filename=composer; \
'

# ----
# tty が有効なら、次のコマンドで更新できたが、Dockerfile 内では動作しなかったので再インストールとしている
# ----
# 
# curl -s -L -O https://composer.github.io/snapshots.pub
# curl -s -L -O https://composer.github.io/releases.pub
# cat snapshots.pub releases.pub > composer_keys.txt
# eval "$(~/.local/bin/mise activate bash)"
# cat composer_keys.txt \
#     | script -q -c "/home/node/.local/share/mise/installs/php/8.2.30/bin/composer self-update --update-keys" /dev/null
# rm snapshots.pub releases.pub composer_keys.txt;
