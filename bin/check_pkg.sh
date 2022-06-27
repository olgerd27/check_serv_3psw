###############################################################################
# The main functions to check the packages and decide if it's installed 
# and available.
###############################################################################

################################################################
# Get the data item from the string line (parse the line)
# $1 - the string line, which will be parsed
# $2 - items separator
# #3 - number of item in the string line
function getItem
{
  echo "$1" | cut -d"$2" -f$3
}

################################################################
# Find the package(-s) in the packages list
# $1 - a list of packages
# $2 - the searched package name
# $3 - decision message
function findPackage
{
  PKG_FND=$(echo "$1" | grep -E "^${2} ")
  if [ $? -eq 0 ]; then
    PKG_FND="$(echo "$PKG_FND" | sed 's/     / /g')" # decrease a number of spaces
    do_out "$3" 12
    do_out "$PKG_FND" 2
  else
    do_out "NOT $3" 12
  fi
}

################################################################
# Execute the Command from the dat-file
# $1 - the Command for the Package
# $2 - a flag: True - if there is a Short Package Name;
#              False - if it's not specified in dat-file
# $3 - decision message
function ExecPkgCommand
{
  OUT_CMD="$(eval $1 2>&1)"
  RC_CMD=$?
  # If Command OK && package cannot be searched in package manager
  # (short name is EMPTY), then this package is INSTALLED.
  if [ $2 = False ]; then
    [ $RC_CMD -eq 0 ] &&
      do_out "$3" 12 ||
      do_out "NOT $3" 12
  fi
  do_out "Command execution:" 2
  do_out "$OUT_CMD" 2
}

