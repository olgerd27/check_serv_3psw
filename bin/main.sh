#/bin/bash
###############################################################################
# The main program
###############################################################################

####### Initial data
HOST=$(hostname | cut -d'.' -f1)

# Dirs & files
D_CURR=$(dirname $0)
D_DAT=${D_CURR}/../dat
D_OUT=${D_CURR}/../out
D_DAT=$(realpath ${D_DAT})
D_OUT=$(realpath ${D_OUT})

FL_DAT=${D_DAT}/${HOST}.dat
FL_REP=${D_OUT}/report_${HOST}_$(date +"%Y%m%d_%H%M%S").txt

# Set the separator lines for the different data types
SEP_HEAD="**********************************************************************"
SEP_BODY="==========================="

####### Initial checks
[ "$(uname -s)" != "Linux" ] && echo "Please run on Linux only" >&2 && exit 1

####### Functions
# Print the program Title
function prn_title
{
  echo "$SEP_HEAD"
  echo "	Checking the installed 3PSW on ${HOST}"
  echo "$SEP_HEAD"
}

# Print the current server info
function prn_serv_info
{
  echo "	Server info:"
  cat /etc/redhat-release
  uname -a
  uptime
  echo "$SEP_HEAD"
}

# Print a list of enabled repositories
function prn_list_repos
{
  echo "	List of enabled repositories:"
  yum repolist
  echo "$SEP_HEAD"
}

# Do the output to stdout and to the Report file
# $1 - data to be output
function do_out
{
  echo "$1" | tee -a $FL_REP
}

####### Start the program
touch $FL_REP
do_out "$(prn_title)"
do_out "$(prn_serv_info)"
do_out "$(prn_list_repos)"

# Getting the packages
# - using yum 
#PKGS_INST="$(yum list installed)"
#PKGS_AVLB="$(yum list available)"
# - using rpm
#PKGS_INST="$(rpm -qa)"
# - test data for debug
PKGS_INST="Installed Packages
make.x86_64                    1:4.3-6.fc35             @anaconda
gcc.x86_64                     11.2.1-9.fc35            @updates
gcc-gdb-plugin.x86_64          11.2.1-9.fc35            @updates
glibc.x86_64                   2.34-29.fc35             @updates"

####### The Main loop
for PKG in bison byacc flex gcc make perl jdk; do
  do_out "Package ${PKG}:"
  # search packages in the 'installed' packages list
  PKG_INST_FND=$(echo "$PKGS_INST" | grep ${PKG}) 
  if [ $? -eq 0 ]; then
    do_out "$PKG_INST_FND"
  else
    do_out "NOT INSTALLED"
    # search packages in the 'available' packages list
    PKG_AVLB_FND=$(echo "$PKGS_AVLB" | grep ${PKG}) 
    if [ $? -eq 0 ]; then
      do_out "Available in the following packages:"
      do_out "$PKG_AVLB_FND"
    else
      do_out "NOT AVAILABLE"
    fi
  fi
  do_out "$SEP_BODY"
done

printf "The Report file:\n%s\n" $FL_REP
