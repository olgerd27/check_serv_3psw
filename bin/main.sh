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
SH_CHECK_PKG=${D_CURR}/check_pkg.sh

####### Initialization
[ "$(uname -s)" != "Linux" ] && echo "Please run on Linux only" >&2 && exit 1
# Load the shell-scripts
for SCR in $SH_FUNC_PRN $SH_CHECK_PKG; do
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
ncurses-libs.x86_64            6.2-8.20210508.fc35      @anaconda
gcc.x86_64                     11.2.1-9.fc35            @updates
gcc-gdb-plugin.x86_64          11.2.1-9.fc35            @updates
glibc.x86_64                   2.34-29.fc35             @updates"
PKGS_AVLB="Available Packages
bison.x86_64                   3.7.6-3.fc35             fedora
cmake.x86_64                   3.22.2-1.fc35            updates
gcc.x86_64                     11.3.1-2.fc35            updates
glibc.i686                     2.34-35.fc35             updates                   
glibc.x86_64                   2.34-35.fc35             updates"

####### The Main loop
while read -r LINE; do
  # Parsing the line
  PKG_SHRT_NAME=$(echo "$LINE" | cut -d":" -f1) # short name
  PKG_LONG_NAME=$(echo "$LINE" | cut -d":" -f2) # long name
  PKG_BIT=$(echo "$LINE" | cut -d":" -f3)       # bitness
  PKG_CMD=$(echo "$LINE" | cut -d":" -f4)       # command to execute

  # Taking decisions based on the initial data (dat-file)
  STR_SHRT=""  # init the string with the package short name
  CAN_FIND_PKG=False  # init flag if it's possible to find package in package manager
  if [ -n "$PKG_SHRT_NAME" ]; then
    STR_SHRT=" (${PKG_SHRT_NAME})"
    CAN_FIND_PKG=True
  fi

  do_out "Package '${PKG_LONG_NAME}' ${PKG_BIT}-bit${STR_SHRT}:" 12

  # FInd the package(-s) in different packages lists, and run only if the 
  # the package short name is specified in the dat-file
  if [ $CAN_FIND_PKG = True ]; then
    findPackage "$PKGS_INST" "$PKG_SHRT_NAME" "INSTALLED" # installed pkg list
    findPackage "$PKGS_AVLB" "$PKG_SHRT_NAME" "AVAILABLE" # available pkg list
  fi

  # Execute the Command from the dat-file
  if [ -n "$PKG_CMD" ]; then
    ExecPkgCommand "$PKG_CMD" $CAN_FIND_PKG "INSTALLED"
  fi

  do_out "$SEP_BODY" 12  # print the line separator
done < <(sed '/^#/d ; /^$/d' $FL_DAT)

# Print the Report file name
do_out "The Report file:
${FL_REP}" 1

