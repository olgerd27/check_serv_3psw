#!/bin/ksh
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
# Check OS
[ "$(uname -s)" != "Linux" ] && echo "Please run on Linux only" >&2 && exit 1

# Load the shell-scripts
for SCR in $SH_FUNC_PRN $SH_CHECK_PKG; do
  . $SCR
done

# Check an existance of the dat-file
if [ ! -f "$FL_DAT" ]; then
  do_out "!---Error 2. The dat-file is unavailable:
'${FL_DAT}'" 2
  exit 2
fi

# Check an existance of the output dir
if [ ! -d "$D_OUT" ]; then
  do_out "!---Error 3. The output directory is unavailable:
'${D_OUT}'
It looks like the Program is not installed" 2
  exit 3
fi

touch $FL_REP  # create the Report file

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
do_out "$(prn_title)" 13
do_out "$(prn_serv_info)" 3
do_out "$(prn_list_repos)" 3

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

  # Validate the line
  if [ $(echo "$LINE" | grep -o ":" | wc -l) -ne 3 ]; then
    do_out "!---Error 2. Invalid line in dat-file ${FL_DAT}:
'${LINE}'
Please check the fields number in the line (should be 4).
${SEP_BODY}" 23
    continue
  fi

  # Parsing the line
  PKG_SHRT_NAME=$(GetItem "$LINE" ":" 1)
  PKG_LONG_NAME=$(GetItem "$LINE" ":" 2)
  PKG_BIT=$(GetItem "$LINE" ":" 3)
  PKG_CMD=$(GetItem "$LINE" ":" 4)

  # Validation and initialization by the 'Package Short Name' value from dat-file
  if IsEmptyString "$PKG_SHRT_NAME"; then
    STR_SHRT=""  # string with the package short name
    CAN_FIND_PKG=False  # flag if it's possible to find package in pkg manager
  else
    STR_SHRT=" (${PKG_SHRT_NAME})"
    CAN_FIND_PKG=True
  fi

  # Print a title for this package
  do_out "Package '${PKG_LONG_NAME}' ${PKG_BIT}-bit${STR_SHRT}:" 13

  # Validation and initialization by the 'Command' value from dat-file
  if IsEmptyString "$PKG_CMD"; then
    if [ $CAN_FIND_PKG = False ]; then
      do_out "!---Error 3. Invalid data in dat-file - empty short name and command
Please specify at least one of these values.
${SEP_BODY}" 23
      continue
    fi
    CAN_RUN_CMD=False
  else
    CAN_RUN_CMD=True
  fi

  # Init return codes to avoid influencing of their values between iterations
  RC_INS=-1;  RC_AVL=-1;  RC_CMD=-1

  # Find the package(-s) in different packages lists only if the 
  # the package short name is specified in the dat-file
  if [ $CAN_FIND_PKG = True ]; then
    # Find in a list of installed packages
    FindPackage "$PKGS_INST" "$PKG_SHRT_NAME" "INSTALLED"
    RC_INS=$?

    # Find a package in a list of available pkgs if it's not found amoung installed
    if [ $RC_INS -ne 0 ]; then
      FindPackage "$PKGS_AVLB" "$PKG_SHRT_NAME" "AVAILABLE"
      RC_AVL=$?
    fi
  fi

  # Execute the Command from the dat-file
  if [ $CAN_RUN_CMD = True ]; then
    ExecPkgCommand "$PKG_CMD" $CAN_FIND_PKG "INSTALLED"
    RC_CMD=$?
  fi

  gath_stats  # collecting the packages statistics

  do_out "$SEP_BODY" 13  # print the line separator
done < $FL_DAT

do_out "$(prn_stats)" 13  # printing statistics

# Print the Report file name
do_out "The Report file:
${FL_REP}" 1

