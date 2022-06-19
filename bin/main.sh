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

SH_FUNC_PRN=${D_CURR}/func_print.sh

####### Initialization
[ "$(uname -s)" != "Linux" ] && echo "Please run on Linux only" >&2 && exit 1
# Load the shell-scripts
for SCR in $SH_FUNC_PRN; do
  . $SCR
done

####### Start the program
touch $FL_REP
do_out "$(prn_title)" 12
#do_out "$(prn_serv_info)" 2   # TODO: uncomment for release version
#do_out "$(prn_list_repos)" 2  # TODO: uncomment for release version

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
while read -r LINE; do
  # Parsing the line
  PKG_SHRT_NAME=$(echo "$LINE" | cut -d":" -f1) # short name
  PKG_LONG_NAME=$(echo "$LINE" | cut -d":" -f2) # long name
  PKG_BIT=$(echo "$LINE" | cut -d":" -f3)       # bitness
  PKG_CMD=$(echo "$LINE" | cut -d":" -f4)       # command to execute

  [ -n "$PKG_SHRT_NAME" ] && STR_SHRT=" (${PKG_SHRT_NAME})" || STR_SHRT=""
  do_out "Package '${PKG_LONG_NAME}'${STR_SHRT}:" 12

  # The found packages in the 'installed' packages list
  PKG_INST_FND=$(echo "$PKGS_INST" | grep -E "^${PKG_SHRT_NAME}") 
  if [ $? -eq 0 ]; then
    do_out "INSTALLED" 12
    do_out "$PKG_INST_FND" 2
  else
    do_out "NOT INSTALLED" 12
  fi

  # The found packages in the 'available' packages list
  PKG_AVLB_FND=$(echo "$PKGS_AVLB" | grep -E "^${PKG_SHRT_NAME}") 
  if [ $? -eq 0 ]; then
    do_out "AVAILABLE" 12
    do_out "$PKG_AVLB_FND" 2
  else
    do_out "NOT AVAILABLE" 12
  fi

  do_out "$SEP_BODY" 12  # print the line separator
done < <(sed '/^#/d ; /^$/d' $FL_DAT)

# Print the Report file name
do_out "The Report file:
${FL_REP}" 1

