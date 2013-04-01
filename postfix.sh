#!/bin/bash

if [ "$1" == "" ]
then
  echo "usage: ./postfix clear"
  exit
fi

if [ "$1" == "clear" ]
then
  for j in `mailq | grep '@' | awk {'print $1'} | grep -v '@'`
  do
    postsuper -d $j
  done
fi
