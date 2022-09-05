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
  cat /etc/redhat-release  # release number
  uname -a  # system info
  uptime    # host load info
  ip -4 -o a | cut -d' ' -f 2,7 | cut -d '/' -f 1 | grep -v "127.0.0.1" # ip
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
# $2 - output modes:
#      1  - to STDOUT
#      2  - to STDERR
#      3  - to Report
#      13 - to STDOUT && Report
#      23 - to STDERR && Report
function do_out
{
  if [ $# -ne 2 ]; then
    echo "!---Error 50. do_out():
invalid argument number ($#) to output the following:
'${1}'" 1>&2
    exit 50
  fi

  if [ $2 -eq 1 ]; then
    echo "$1"                  # to STDOUT
  elif [ $2 -eq 2 ]; then
    echo "$1" 1>&2             # to STDERR
  elif [ $2 -eq 3 ]; then
    echo "$1" >> $FL_REP       # to Report
  elif [ $2 -eq 13 ]; then
    echo "$1" | tee -a $FL_REP # to STDOUT && Report
  elif [ $2 -eq 23 ]; then
    echo "$1" 1>&2             # to STDERR
    echo "$1" | tee -a $FL_REP # to Report
  else
    echo "!---Error 51. do_out(): 
invalid output mode '${2}' to output the following:
'${1}'" 1>&2
    exit 51
  fi
}

