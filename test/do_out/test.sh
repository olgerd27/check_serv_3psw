#!/bin/ksh

#FL_REP_OLD="report_old.txt"
FL_OLD_1="old_1_stdout.txt" # output of old function to stdout (option 1)
FL_OLD_2="old_2_stderr.txt" # output old function to stderr (option 2)
FL_OLD_3="old_3_file.txt" # output of old function to file (option 3)

FL_NEW_1="new_1_stdout.txt" # output of new function to stdout (option 1)
FL_NEW_2="new_2_stderr.txt" # output of new function to stderr (option 2)
FL_NEW_3="new_3_file.txt" # output of new function to file (option 3)

# Reset files content
> $FL_OLD_1
> $FL_OLD_2
> $FL_OLD_3
> $FL_NEW_1
> $FL_NEW_2
> $FL_NEW_3

################################################################
# OLD VERSION
# Do the output in different output direction modes.
# $1 - data to be output
# $2 - output modes:
#      1  - to STDOUT
#      2  - to STDERR
#      3  - to Report
#      13 - to STDOUT && Report
#      23 - to STDERR && Report
function do_out_old
{
  if [ $# -ne 2 ]; then
    echo "!---Error 50. do_out_old():
invalid argument number ($#) to output the following:
'${1}'" 1>&2
    exit 50
  fi

  if [ $2 -eq 1 ]; then            # to STDOUT
    echo "$1"
  elif [ $2 -eq 2 ]; then          # to STDERR
    echo "$1" 1>&2
  elif [ $2 -eq 3 ]; then          # to Report
    echo "$1" >> $FL_OLD_3
  elif [[ $2 -eq 12 || $2 -eq 21 ]]; then # to STDOUT && STDERR
    echo "$1"
    echo "$1" 1>&2
  elif [[ $2 -eq 13 || $2 -eq 31 ]]; then # to STDOUT && Report
    echo "$1" | tee -a $FL_OLD_3
  elif [[ $2 -eq 23 || $2 -eq 32 ]]; then # to STDERR && Report
    echo "$1" 1>&2
    echo "$1" >> $FL_OLD_3
  else
    echo "!---Error 51. do_out_old(): 
invalid output mode '${2}' to output the following:
'${1}'" 1>&2
    exit 51
  fi
}

################################################################
# NEW VERSION
# Do the output in different output direction modes.
# $1 - data to be output
# $2..$4 - output modes:
#      1  - to STDOUT
#      2  - to STDERR
#      3  - to Report
function do_out_new
{
  DATA="$1"
  if [ $# -lt 2 ]; then
    echo "!---Error 50. do_out_new():
invalid argument number ($#) to output the following:
'${DATA}'" 1>&2
    exit 50
  fi

  shift # shift to the next argument

  while [ $# -gt 0 ]; do
    case $1 in
      1) echo "$DATA" ;;              # to STDOUT
      2) echo "$DATA" 1>&2 ;;         # to STDERR
      3) echo "$DATA" >> $FL_NEW_3 ;; # to Report
      *) echo "!---Error 51. do_out_new(): 
invalid output mode '${1}' to output the following:
'${DATA}'" 1>&2
      exit 51 ;;
    esac
    shift # shift to the next argument
  done
}

### Testing
# TC 1. Print to STDOUT
STR="Test 1"
do_out_old "${STR}" 1 1>>$FL_OLD_1
do_out_new "${STR}" 1 1>>$FL_NEW_1

# TC 2. Print to STDERR
STR="Test 2"
do_out_old "${STR}" 2 2>>$FL_OLD_2
do_out_new "${STR}" 2 2>>$FL_NEW_2

# TC 3. Print to file
STR="Test 3"
do_out_old "${STR}" 3
do_out_new "${STR}" 3

# TC 12. Print to STDOUT && STDERR
STR="Test 1-2"
do_out_old "${STR}" 12 1>>$FL_OLD_1 2>>$FL_OLD_2
do_out_new "${STR}" 1 2 1>>$FL_NEW_1 2>>$FL_NEW_2

# TC 13. Print to STDOUT && file  
STR="Test 1-3"
do_out_old "${STR}" 13 1>>$FL_OLD_1
do_out_new "${STR}" 1 3 1>>$FL_NEW_1

# TC 21. Print to STDERR && STDOUT
STR="Test 2-1"
do_out_old "${STR}" 21 1>>$FL_OLD_1 2>>$FL_OLD_2
do_out_new "${STR}" 2 1 1>>$FL_NEW_1 2>>$FL_NEW_2

# TC 23. Print to STDERR && file  
STR="Test 2-3"
do_out_old "${STR}" 23 2>>$FL_OLD_2
do_out_new "${STR}" 2 3 2>>$FL_NEW_2

# TC 31. Print to file && STDOUT
STR="Test 3-1"
do_out_old "${STR}" 31 1>>$FL_OLD_1
do_out_new "${STR}" 3 1 1>>$FL_NEW_1

# TC 32. Print to file && STDERR
STR="Test 3-2"
do_out_old "${STR}" 32 2>>$FL_OLD_2
do_out_new "${STR}" 3 2 2>>$FL_NEW_2

#do_out_new "Test 1-2-3" 1 2 3
#do_out_new "Test 2-3-1" 2 3 1
#do_out_new "Test 3-2-1" 3 2 1
