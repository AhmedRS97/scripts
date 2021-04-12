#!/bin/bash

# this is to gracefully stop execution if there's non-zero error that
# wasn't checked by an conditional statement. doesn't catch subshells
# errors though.
#set -e

usage() {
  echo "This script link and unlink files in source directory to target directory.";
  echo "The script also renames files and directories to filename~bak when linking.";
  echo "	Usage: $0 -s SOURCE -t TARGET | -u -t TARGET" 1>&2
}
exit_abnormal() {
  usage
  exit 1
}

exit_with_error() {
  echo "$1"
  exit 1
}

validate_dir() {
  [ -d $1 ] ||
    exit_with_error "The path: $1 doesn't exist or isn't a directory."
  [ -r $1 ] ||
    exit_with_error "The path: $1 is not readable."
  [ -w $1 ] ||
    exit_with_error "The path: $1 is not writable."
  [ -x $1 ] ||
    exit_with_error "The path: $1 is not exeutable."
  $(test $(ls -1 $1 | wc -l) -eq 0) &&
    exit_with_error "$1 is empty!"
}

link() {
  local src=$(readlink -f "$1")
  local dst=$(readlink -f "$2")
  for d in $(tree -ni -L 1 --noreport "$src" | tail -n +2);
  do
    linkPath="$dst/$d"
    [ -e $linkPath ] && mv "$linkPath" "$linkPath~bak";
    $(cd "$dst" && ln -sf "$linkPath" $d)
  done
}

unlink() {
  local destination=$(readlink -f $1)

  # TODO: unlink only the links created by this script.
  # not other links that was already there in dst
  # before running this script.
  find "$destination" -maxdepth 1 -type l -exec unlink {} \;

  for fd in $(ls -1 $destination);
  do 
    echo $fd | grep -qP "~bak$" && mv "$destination/$fd" "$destination/$(echo ${fd:0:${#fd}-4})"
  done
}

while getopts :s:t:u option
do
  case "${option}"
    in
      s) src=${OPTARG}
	 ;;
      t) dst=${OPTARG}
	 ;;
      u) unLnk=1
         ;;
      :) echo "Error: -${OPTARG} requires an argument."
	 exit_abnormal
	 ;;
      *) exit_abnormal
	 ;;
  esac
done


if [ -z "$src" -a ! -z "$dst" -a ! -z "$unLnk" ]; then
  validate_dir $dst
  unlink $dst && echo "restored backup and unlinked files and directories."
fi
if [ ! -z "$src" -a ! -z "$dst" -a -z "$unLnk" ]; then
  validate_dir $src
  validate_dir $dst
  link $src $dst && echo "made backup and linked source files and directories to target"
fi
