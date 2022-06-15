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
  echo "Server info:"
  cat /etc/redhat-release
  uname -a
  uptime
  echo "$SEP_HEAD"
}

# Print a list of enabled repositories
function prn_list_repos
{
  echo "List of enabled repositories:"
  yum repolist
  echo "$SEP_HEAD"
}

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

####### Start the program
touch $FL_REP
do_out "$(prn_title)" 12
do_out "$(prn_serv_info)" 2
do_out "$(prn_list_repos)" 2

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
PKGS_AVLB="Available Packages
bison.x86_64                   3.7.6-3.fc35             fedora
cmake.x86_64                   3.22.2-1.fc35            updates
glibc.i686                     2.34-34.fc35             updates                   
glibc.x86_64                   2.34-34.fc35             updates"

####### The Main loop
for PKG in gcc.x86_64 bison.x86_64 make.x86_64 glibc.x86_64 libXi.i686; do
  do_out "Package ${PKG}:" 12
  # search packages in the 'installed' packages list
  PKG_INST_FND=$(echo "$PKGS_INST" | grep ${PKG}) 
  if [ $? -eq 0 ]; then
    do_out "INSTALLED" 12
    do_out "$PKG_INST_FND" 2
  else
    do_out "NOT INSTALLED" 12
    # search packages in the 'available' packages list
    PKG_AVLB_FND=$(echo "$PKGS_AVLB" | grep ${PKG}) 
    if [ $? -eq 0 ]; then
      do_out "AVAILABLE" 12
      do_out "$PKG_AVLB_FND" 2
    else
      do_out "NOT AVAILABLE" 12
    fi
  fi
  do_out "$SEP_BODY" 12
done

# Print the Report file name
do_out "The Report file:
${FL_REP}" 1

