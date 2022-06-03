#/bin/bash
# Checking the 3PSW, installed on the server, and the server itself.
# Supports Linux for now only.

# Initial data
HOST=$(hostname | cut -d'.' -f1)

D_OUT=../out
D_OUT=$(realpath ${D_OUT})
FL_REP=${D_OUT}/report_${HOST}_$(date +"%Y%m%d_%H%M%S").txt

# Initial checks
[ "$(uname -s)" != "Linux" ] && echo "Please run on Linux only" >&2 && exit 1

# Some functions
function title
{
  echo "**********************************************************************"
  echo "Checking of the installed 3PSW on ${HOST}"
  echo "**********************************************************************"
}

function host_info
{
  cat /etc/redhat-release
  uname -a
  uptime
  echo "**********************************************************************"
}

# Start the program
title | tee $FL_REP
host_info >>$FL_REP

printf "The Report file:\n%s\n" $FL_REP
exit

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

for PKG in bison byacc flex gcc make perl jdk; do
  echo "Package ${PKG}:"
  # the 'found' packages in the 'installed' packages list
  PKG_INST_FND=$(echo "$PKGS_INST" | grep ${PKG}) 
  if [ $? -eq 0 ]; then
    echo "$PKG_INST_FND"
  else
    echo "NOT INSTALLED"
    # the 'found' packages in the 'available' packages list
    PKG_AVLB_FND=$(echo "$PKGS_AVLB" | grep ${PKG}) 
    if [ $? -eq 0 ]; then
      echo "Available in the following packages:"
      echo "$PKG_AVLB_FND"
    else
      echo "NOT AVAILABLE"
    fi
  fi
  echo "==========================="
done

printf "The Report file:\n%s\n" $FL_REP
