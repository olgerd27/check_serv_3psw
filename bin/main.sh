#!/bin/ksh
# TODO: create the 'install' file, which can do the following:
#       - create 'out' directory
#       - chmod -R g+w .
#       - chmod 774 bin/*
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

SH_FUNC_PRN=${D_CURR}/print.sh
SH_CHECK_PKG=${D_CURR}/check_pkg.sh

####### Initialization
# Init checks
[ "$(uname -s)" != "Linux" ] && echo "Please run on Linux only" >&2 && exit 1
# TODO: check if dat-file exists
# TODO: check if $D_OUT dir exists, if not - print a message like:
# The program is not installed, please check existance of $D_OUT directory.
# TODO: move here the Report file creation if $D_OUT exists


# Load the shell-scripts
for SCR in $SH_FUNC_PRN $SH_CHECK_PKG; do
  . $SCR
done

# Init the variables
# Data from dat-file
PKG_SHRT_NAME=  # short name
PKG_LONG_NAME=  # long name
PKG_BIT=        # bitness
PKG_CMD=        # command to execute

# Statistics - number of packages:
N_ALL=0        # all
N_INS=0        # installed
N_NINS=0       # not installed
N_NINS_AVL=0   # not installed & available
N_NINS_NAVL=0  # not installed & not available

####### Start the program
touch $FL_REP
do_out "$(prn_title)" 12
do_out "$(prn_serv_info)" 2 
do_out "$(prn_list_repos)" 2

# Getting the packages
printf "Getting the packages..."
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
# - using yum 
#PKGS_INST="$(yum list installed)"
#PKGS_AVLB="$(yum list available)"
# - using rpm
#PKGS_INST="$(rpm -qa)"
printf "DONE\n%s\n" $SEP_BODY

####### The Main loop
while read -r LINE; do
  # Skip the blank and commented lines 
  echo "$LINE" | grep -qE "^#|^$" && continue

  # Parsing the line
  PKG_SHRT_NAME=$(getItem "$LINE" ":" 1)
  PKG_LONG_NAME=$(getItem "$LINE" ":" 2)
  PKG_BIT=$(getItem "$LINE" ":" 3)
  PKG_CMD=$(getItem "$LINE" ":" 4)

  # Validation and initialization by the 'Package Short Name' value from dat-file
  if [ -z "$PKG_SHRT_NAME" ]; then
    STR_SHRT=""  # string with the package short name
    CAN_FIND_PKG=False  # flag if it's possible to find package in pkg manager
  else
    STR_SHRT=" (${PKG_SHRT_NAME})"
    CAN_FIND_PKG=True
  fi

  # Print a title for this package
  do_out "Package '${PKG_LONG_NAME}' ${PKG_BIT}-bit${STR_SHRT}:" 12

  # Validation and initialization by the Command' value from dat-file
  # TODO: add check for PKG_CMD that it's more like a command, 
  #       e.g. check the length of the data in it
  if [ -z "$PKG_CMD" ]; then
    if [ $CAN_FIND_PKG = False ]; then
      echo "!---Error 2. Invalid data in dat-file - empty short name and command" 1>&2
      echo "Please specify at least one of these values" 1>&2
      exit 2
    fi
    CAN_RUN_CMD=False
  else
    CAN_RUN_CMD=True
  fi

  # Find the package(-s) in different packages lists only if the 
  # the package short name is specified in the dat-file
  if [ $CAN_FIND_PKG = True ]; then
    # TODO: rename function name - start with a capital letter 
    # find in a list of installed packages
    findPackage "$PKGS_INST" "$PKG_SHRT_NAME" "INSTALLED"
    RC_INS=$?
    # TODO: do the search of package within the available packages only if it's not 
    # found within the installed packages
    # find in a list of available packages
    findPackage "$PKGS_AVLB" "$PKG_SHRT_NAME" "AVAILABLE"
    RC_AVL=$?
  fi

  # Execute the Command from the dat-file
  if [ $CAN_RUN_CMD = True ]; then
    ExecPkgCommand "$PKG_CMD" $CAN_FIND_PKG "INSTALLED"
    RC_CMD=$?
  fi

  # Collection of statistics - number of packages:
  ((N_ALL++))  # - all
  if [[ $CAN_FIND_PKG = True && $RC_INS -eq 0 ]] || 
     [[ $CAN_FIND_PKG = False && $RC_CMD -eq 0 ]]; then
    ((N_INS++))       # - installed
  else
    ((N_NINS++))      # - not installed
    if [[ $CAN_FIND_PKG = True && $RC_INS -ne 0 && $RC_AVL -eq 0 ]]; then
      ((N_NINS_AVL++))  # - not installed & available
    else
      ((N_NINS_NAVL++)) # - not installed & not available
    fi
  fi

  do_out "$SEP_BODY" 12  # print the line separator
done < $FL_DAT

# TODO: print the statistics in an external finction - number of packages: all, 
# installed, not installed, not installed & available, not installed & not available
echo "Package Statistics:"
echo "  - All: ${N_ALL}"
echo "  - Installed: ${N_INS}"
echo "  - Not Installed: ${N_NINS}"
echo "  - Not Installed & Available: ${N_NINS_AVL}"
echo "  - Not Installed & Not Available: ${N_NINS_NAVL}"
echo "$SEP_HEAD"

# Print the Report file name
do_out "The Report file:
${FL_REP}" 1

