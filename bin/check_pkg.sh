###############################################################################
# The main functions to check the packages and decide if it's installed 
# and available.
###############################################################################

################################################################
# Get the data item from the string line (parse the line)
# $1 - the string line, which will be parsed
# $2 - items separator
# #3 - number of item in the string line
function GetItem
{
  echo -n "$1" | cut -d"$2" -f$3
}

################################################################
# Check if a string is empty or contains spaces only.
# $1 - field data from dat-file
function IsEmptyString
{
  echo "$1" | grep -qE "^[[:space:]]*$"
  return $?
}

################################################################
# Find the package(-s) in the packages list
# $1 - a list of packages
# $2 - the searched package name
# $3 - decision message
# RC: 0 - package is found,
#     1 - package is not found
function FindPackage
{
  typeset PKG_FND # forward declaration
  PKG_FND=$(echo "$1" | grep "^${2} ")
  typeset RC=$?
  if [ $RC -eq 0 ]; then
    PKG_FND="$(echo "$PKG_FND" | sed 's/     / /g')" # decrease a number of spaces
    do_out "$3" 13
    do_out "$PKG_FND" 3
  else
    do_out "NOT $3" 13
  fi
  return $RC
}

################################################################
# Execute the Command from the dat-file
# $1 - the Command for the Package
# $2 - a flag: True - if a Short Package Name is specified in dat-file;
#              False - if it's not specified in dat-file
# $3 - decision message
# RC: 0 - package is installed,
#     1 - package is not installed
function ExecPkgCommand
{
  typeset OUT_CMD  # forward declaration
  OUT_CMD="$(eval $1 2>&1)"
  typeset RC=$?
  # If Short Package Name is EMPTY && Command executed OK, 
  # then this package is INSTALLED.
  if [ $2 = False ]; then
    [ $RC -eq 0 ] &&
      do_out "$3" 13 ||
      do_out "NOT $3" 13
  fi
  do_out "Command execution:" 3
  do_out "$OUT_CMD" 3
  return $RC
}

################################################################
# Collection of statistics.
# Init data - global variables - number of packages:
# N_ALL - all
# N_INS - installed
# N_NINS - not installed
# N_NINS_AVL - not installed & available
# N_NINS_NAVL - not installed & not available
# Init data - Return codes:
# RC_INS - RC of package finding among the installed packages
# RC_AVL - RC of package finding among the available packages
# RC_CMD - RC of successfulness the Command execution
# All the input data is the global variables.
function gath_stats
{
  ((N_ALL++))  # - all
  if [ $RC_INS -eq 0 ] || [ $RC_CMD -eq 0 ]; then
    ((N_INS++))       # - installed
  else
    ((N_NINS++))      # - not installed
    if [ $RC_AVL -eq 0 ]; then
      ((N_NINS_AVL++))  # - not installed & available
    else
      ((N_NINS_NAVL++)) # - not installed & not available
    fi
  fi
}

