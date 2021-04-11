#!/bin/bash

# This script can be used to copy files from one directory to other one.

usage() {
  echo "This script copies files in source directory to target directory";
  echo "	Usage: $0 [ -s SOURCE ] [ -t TARGET ]" 1>&2
}
exit_abnormal() {
  usage
  exit 1
}


while getopts :s:t: option
do
  case "${option}"
    in
      s) src=${OPTARG}
	 ;;
      t) dst=${OPTARG}
	 ;;
      :) echo "Error: -${OPTARG} requires an argument."
	 exit_abnormal
	 ;;
      *) exit_abnormal
	 ;;
  esac
done

[ -z $src -o -z $dst ] &&
	echo "The source or target arguments are empty."; exit_abnormal
[ ! -d $src -o ! -d $dst ] &&
	echo "The source or target doesn't exist or isn't a directory."; exit 1;
[ ! -r $src -o ! -r $dst ] &&
	echo "The source or target directory isn't readable."; exit 1;
[ ! -w $src -o ! -w $dst ] &&
	echo "The source or target directory isn't writable."; exit 1;
[ ! -x $src -o ! -x $dst ] &&
	echo "The source or target directory isn't exeutable."; exit 1;

cp -r $src/* $dst &&
	echo "Done, the files have benn copied to the target directory." ||
	echo "Please check if there's files in the source directory";
