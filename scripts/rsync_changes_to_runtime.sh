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
fd -uuu -tf -e lua -E 'runtime_cfg_backups' -X stylua -f .stylua.toml {}

# make backup of the current runtime config
BACKUP_DIR="$PROJ_ROOT/runtime_cfg_backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r "$RUNTIME_CONFIG_ROOT"/* "$BACKUP_DIR"/

rsync -av --update --exclude-from="$PROJ_ROOT/.rsync-exclude" "$PROJ_ROOT"/ "$RUNTIME_CONFIG_ROOT"/
