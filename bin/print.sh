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
  echo "=> Server info"

  typeset OUT_LSCPU="$(lscpu)"
  # CPU's model name & base clock speed
  echo "CPU $(echo "$OUT_LSCPU" | grep "^Model name:" | tr -s ' ')"
  # CPU's current operating frequency:
  echo "CPU current frequency, MHz: $(echo "$OUT_LSCPU" | grep "CPU MHz:" | awk '{print $NF}')"
  # Number of CPUs
  echo "$OUT_LSCPU" | grep "^CPU(s):" | tr -s ' '

  # Total amount of memory
  grep MemTotal /proc/meminfo | tr -s ' '

  # Network interface and the IP address on it:
  echo "IP: $(ip -4 -o a | cut -d' ' -f 2,7 | cut -d '/' -f 1 | grep -v "127.0.0.1")"
  echo "Version: $(cat /etc/redhat-release)"  # release number
  echo "uname: $(uname -a)"  # system info
  echo "uptime: $(uptime)"    # host load info
  echo "$SEP_HEAD"
}

################################################################
# Print a list of enabled repositories
function prn_list_repos
{
  echo "=> List of enabled repositories"
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
# Do the data output in different output direction modes.
# $1 - data to be output
# $2.. - output modes:
#      1  - to STDOUT
#      2  - to STDERR
#      3  - to Report
function do_out
{
  DATA="$1"
  if [ $# -lt 2 ]; then
    echo "!---Error 50. do_out():
invalid number of arguments (N=$#) to output the following:
'${DATA}'" 1>&2
    exit 50
  fi

  shift # shift to the next argument

  while [ $# -gt 0 ]; do
    case $1 in
      1) echo "$DATA" ;;             # to STDOUT
      2) echo "$DATA" 1>&2 ;;        # to STDERR
      3) echo "$DATA" >> $FL_REP ;;  # to Report
      *) echo "!---Error 51. do_out_new():
invalid output mode '${1}' to output the following:
'${DATA}'" 1>&2
      exit 51 ;;
    esac
    shift # shift to the next argument
  done
}

