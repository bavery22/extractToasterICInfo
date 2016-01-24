#!/bin/bash

BUILD_NUM=$1
TARGET_NUM=$2

FILE_BASE=$3

if [ "$FILE_BASE" == "" ]; then
    echo "usage: $0 <build_num> <target_num> <file_base>"
    exit
fi

for type in packages recipes; do
    if [ "$type" == "packages" ]; then
	CURL_STR="http://192.168.168.66:8005/toastergui/build/$BUILD_NUM/target/$TARGET_NUM?count=250000&orderby=name%3A%2B&page=1"
	echo "pulling $type"
	curl -s $CURL_STR > "${FILE_BASE}-${type}.html"
	echo "extracting $type"
	cat "${FILE_BASE}-${type}.html" |  awk 'c&&!--c; /package_name/{c=2}'| tr -d ' \t\f' | sort > "${FILE_BASE}-${type}.list"
	# this is for pkgs built, not included.
	#cat "${FILE_BASE}-${type}.html"| egrep package_name | awk -F '>' '{print $3}' | tr '<' ' '| awk '{print $1}' > "${FILE_BASE}-${type}.list"
    elif [ "$type" == "recipes" ]; then
	CURL_STR="http://192.168.168.66:8005/toastergui/build/$BUILD_NUM/$type/?count=1000000&orderby=name%3A%2B&page=1"
	echo "pulling $type"
	curl -s $CURL_STR > "${FILE_BASE}-${type}.html"
	echo "extracting $type"
	cat "${FILE_BASE}-${type}.html" | awk 'f{print;f=0} /recipe__name/{f=1}' | awk -F '>' '{print $2}'|tr '<' ' '| awk '{print $1}' | sort > "${FILE_BASE}-${type}.list"
    fi
    NUM=`wc -l ${FILE_BASE}-${type}.list | awk '{print $1}'`
    echo "We have $NUM $type artifacts"
done
