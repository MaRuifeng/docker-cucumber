#!/bin/bash

# Parallel cucumber test launcher 
# Note that the RVM has to be started first as a pre-requisite

# Authors:
#  Ruifeng Ma <ruifengm@sg.ibm.com>
# Date:
#  2016-May-03

OPTIONS=$(getopt -o hd: -l help,cuke_dir: -- "$@")

if [ $? -ne 0 ]; then
  echo "getopt error"
  exit 1
fi

eval set -- $OPTIONS

while true; do
  case "$1" in
    -h | --help) printf "This is a parallel cucumber test launcher.\n\nTrigger it by\n./parallel_cukes.sh -d <cucumber_direcotry>\nor\n./parallel_cukes.sh --cuke_dir <cucumber_direcotry>\n\n" ;;
    -d | --cuke_dir) 
		CUKE_DIR="$2"
		cd $CUKE_DIR
		echo "Current directory: " 
		# pwd
		echo $CUKE_DIR
		source /etc/profile.d/rvm.sh
		echo "Started RVM version: "
		rvm -v
		bundle exec parallel_cucumber $CUKE_DIR/features/parallel_test/ -o "-p parallel -t @direct_search"; shift ;;
    --)        shift ; break ;;
    *)         echo "unknown option: $1" ; exit 1 ;;
  esac
  shift
done

if [ $# -ne 0 ]; then
  echo "unknown option(s): $@"
  exit 1
fi

