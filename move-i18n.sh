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

exit_with_error() {
  echo "$1"
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


[ -d $src -o -d $dst ] ||
  exit_with_error "The source or target doesn't exist or isn't a directory."
[ -r $src -o -r $dst ] ||
  exit_with_error "The source or target directory isn't readable."
[ -w $src -o -w $dst ] ||
  exit_with_error "The source or target directory isn't writable."
[ -x $src -o -x $dst ] ||
  exit_with_error "The source or target directory isn't exeutable."
$(test $(find $src -maxdepth 1 | tail -n +2 | wc -l) -eq 0) &&
  exit_with_error "The source directory's content is empty!"

src=$(readlink -f "$src")
dst=$(readlink -f "$dst")

# Since the `cp -Rs` require to delete or rename any existing directory
# in order to create a symlink, the script will do a 2 step process,
# First is to get directories under source (depth=1) and look in the
# target for those directories, if not found then create a symlink to it.
# Second step is to create (recursively) symlinks to all files under
# target, except of course the already made symlinks in step 1.

# for each name of sub-directories under src directory.
# create symlink to src sub-directory in dst where there's
# no existing said sub-directory.
for d in $(tree -dni -L 1 --noreport "$src" | tail -n +2);
do
  dir="$dst/$d"
  # create symbolic links to directories existing in src but not in dst
  # existing directory level1

  #test2/level1  (1    +   1 )    *  (1      *     0)
  # non existing directory or a file or a link.
  #test2/level11 (1    +   1 )    *  (1      *     1)
  $(test -L $dir -o ! -e $dir -a ! -d $dir -a ! -f $dir);
  case $? in
    0)
      cd "$dst"; ln -sf "$src/$d" "$d";
      echo "Created $src/$d symlink in $dst directory.";
      ;;
    1)
      echo "Failed to create symlink for $src/$d in $dst directory.";
      ;;
  esac
done

cp -Rsvb $src/* $dst

