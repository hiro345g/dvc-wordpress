#!/bin/sh
echo "$(date '+%Y-%m-%dT%H:%M:%S+09:00') init" >> /home/node/workspace/init.log

#
# `mise -y use --global php@8.5.30` 実行など調整したいとき
# ----
# if [ ! -e /home/node/.config/mise/ ]; then
#     mkdir -p /home/node/.config/mise/
# fi
# cat << EOS > /home/node/.config/mise/config.toml 
# [tools]
# php = "8.5.30"
#
# [settings]
# # disable_tools = ["php"]
# EOS
