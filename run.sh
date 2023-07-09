#!/usr/bin/env bash

check_binary_exists()
{
  for i in "$@"; do
    if ! command -v "$i" >/dev/null 2>&1; then
      echo >&2 "Please install ${i} before using this script"
      exit 1
    fi
  done
}

error_and_quit()
{
  local msg=$1
  zenity --error --text "$msg"
  exit 1
}

do_restore()
{
  local neighbor_dir=$1
  local restore_file=$2

  pushd "$neighbor_dir"
  tar xf "$restore_file" | zenity --progress --pulsate --auto-close --no-cancel --text 'Restoring...' 
  local extract_rv=${PIPESTATUS[0]}
  popd

  if [[ $extract_rv -ne 0 ]]; then
    error_and_quit "Failed to extract backup, tar returned ${extract_rv}"
  fi
}

readonly sims2_config="${HOME}/.config/sims2/config.sh"

check_binary_exists zenity tar xz date

if [[ ! -f $sims2_config ]]; then
  error_and_quit "${sims2_config} doesn't exist, please create it first"
  exit 1
fi

source "$sims2_config"

readonly neighborhoods_dir="${SIMS2_WINE_PREFIX}/drive_c/users/${USER}/Documents/EA Games/The Sims 2/Neighborhoods"

if [[ ! -z $SIMS2_BACKUP_DIR ]]; then
  restore_file=$(zenity --file-selection \
    --file-filter='Sims 2 Backups | *.tar.xz' \
    --filename "$SIMS2_BACKUP_DIR")
  if [[ $? -eq 0 && $restore_file ]]; then
    do_restore "$neighborhoods_dir" "$restore_file"
  fi
fi

pushd "${SIMS2_WINE_PREFIX}/${SIMS2_TSBIN_DIR}"
export WINEPREFIX=$SIMS2_WINE_PREFIX
if ! sims2_run; then
  error_and_quit "sims2_run() failed, not attempting to create a backup"
fi
export -n WINEPREFIX
popd

if ! zenity --question --text 'Do you want to back up your neighborhoods?'; then
  # we're done
  exit 0
fi

set -e

backup_path="/tmp/sims2_${HOSTNAME}_$(date +%F_%T_%z).tar.xz"
pushd "$neighborhoods_dir"
XZ_OPT='-9 -e -T0' tar cJf "$backup_path" . | zenity --progress --pulsate --auto-close --no-cancel --text Compressing...
sims2_copy_to_storage "$backup_path" | zenity --progress --pulsate --auto-close --no-cancel --text 'Copying to storage...' 
rm -f "$backup_path"
popd
