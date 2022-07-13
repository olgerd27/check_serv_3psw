###############################################################################
# The 'print' functions
###############################################################################

####### Initial data
# Set the separator lines for the different data types
SEP_HEAD="**********************************************************************"
SEP_BODY="==========================="

####### Functions
################################################################
# Print the program Title
function prn_title
{
  echo "$SEP_HEAD"
  echo "        Checking the installed 3PSW on ${HOST}"
  echo "$SEP_HEAD"
}

################################################################
# Print the current server info
function prn_serv_info
{
  echo "Server info:"
  cat /etc/redhat-release
  uname -a
  uptime
  echo "$SEP_HEAD"
}

################################################################
# Print a list of enabled repositories
function prn_list_repos
{
  echo "List of enabled repositories:"
  yum repolist
  echo "$SEP_HEAD"
}

################################################################
# Printing the statistics - number of packages:
# N_ALL - all
# N_INS - installed
# N_NINS - not installed
# N_NINS_AVL - not installed & available
# N_NINS_NAVL - not installed & not available
# All the input data is the global variables.
function prn_stats
{
  echo "Statistics:
  - All: ${N_ALL}
  - Installed: ${N_INS}
  - Not Installed: ${N_NINS}
  - Not Installed & Available: ${N_NINS_AVL}
  - Not Installed & Not Available: ${N_NINS_NAVL}"

  # Statistics validation
  [ $N_ALL -ne $(($N_INS + $N_NINS)) ] &&
  echo "!---Warning 3. Invalid statistics:
'All' != 'Installed' + 'Not Installed'"

  [ $N_NINS -ne $(($N_NINS_AVL + $N_NINS_NAVL)) ] &&
  echo "!---Warning 4. Invalid statistics:
'Not Installed' != 'Not Installed & Available' + 'Not Installed & Not Available'"

  echo "$SEP_HEAD"
}

################################################################
# Do the output in different output direction modes.
# $1 - data to be output
# $2 - output mode:
#      1  - to stdout
#      2  - to Report
#      12 - to stdout & Report
function do_out
{
  if [ "$2" = "1" ]; then
    echo "$1"
  elif [ "$2" = "2" ]; then
    echo "$1" >> $FL_REP
  elif [ "$2" = "12" ]; then
    echo "$1" | tee -a $FL_REP
  else
    printf "!---Error 55: invalid output mode '%i' to output the following:\n%s\n" \
      "$2" "$1" 1>&2
    exit 55
  fi
}

