#!/usr/bin/env bash

# the absolute path to the root directory of your wineprefix
readonly SIMS2_WINE_PREFIX=''

# the directory where the Sims2 executable is, relative to wineprefix
readonly SIMS2_TSBIN_DIR=''

# the directory where backups are moved to, displayed before launching the game
# in order to restore a backup.
# if not set, restoring from a backup on start is just skipped.
readonly SIMS2_BACKUP_DIR=''

sims2_run()
{
  # executed with ${SIMS2_TSBIN_DIR} as the working directory and with WINEPREFIX
  # already set to ${SIMS2_WINE_PREFIX}
  # you pretty much just want to run "wine Sims2EP9.exe", optionally via
  # prime-run if needed.
}

sims2_copy_to_storage()
{
  local neighborhood_backup_path=$1
  # neighborhood_backup_path points to a file containing the backup. this
  # function should most probably just move this to $SIMS2_BACKUP_DIR
}
