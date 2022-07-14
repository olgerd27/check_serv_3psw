#!/bin/ksh
#
# Copyright (c) 2022. Released under the MIT License.

##### Init data
# Directories
D_CURR=$(dirname $0)  # current dir
D_BIN=${D_CURR}/bin   # dir for executables
D_DAT=${D_CURR}/dat   # dir for dat-files
D_OUT=${D_CURR}/out   # dir for output

# Permissions
MOD_D_DFL=775  # default mode bits for dirs
MOD_F_DFL=664  # default mode bits for files
MOD_F_EXE=774  # mode bits for executable files

# Get to know the user group for all files & dirs
RC=1
while [ $RC -ne 0 ]; do
  echo "Please specify a user group to be set for all files & dirs:"
  read GRP_DFL
  echo "$(groups)" | grep -q "$GRP_DFL"
  RC=$?
  [ $RC -ne 0 ] && 
    printf "Unknown group, use one of the following: %s\n\n" "$(groups)"
done

##### Installation execution
# Set permissions for all directories except hidden ones
find "$D_CURR" -type d -not -path '*/.*' -exec chmod $MOD_D_DFL {} +

# Set permissions for executables
chmod $MOD_F_EXE "${D_BIN}"/*

# Set permissions for dat-file
chmod $MOD_F_DFL "${D_DAT}"/*

# Create the output directory
mkdir -p -m $MOD_D_DFL "$D_OUT"

# Set group for all files & dirs
find "$D_CURR" -not -path '*/.*' -exec chgrp $GRP_DFL {} +

echo "The Program is successfully installed."
