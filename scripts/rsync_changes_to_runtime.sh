#!/usr/bin/env bash
# shellcheck shell=bash disable=SC1091

#------------------------------------------------------------------------------
# run rsync command to sync changes to runtime config
# must be run from the project root
# alternatively, you can specify the what config file to use at the command line:
# wezterm --config-file ~/.config/wezterm/wezterm.lua start -- zsh -l
#------------------------------------------------------------------------------

source .env

# format lua files
fd -uuu -tf -e lua -X stylua -f .stylua.toml {}



rsync -av --update --exclude-from="$PROJ_ROOT/.rsync-exclude" "$PROJ_ROOT"/ "$RUNTIME_CONFIG_ROOT"/
