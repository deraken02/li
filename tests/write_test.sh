#!/bin/bash
FILE=tester
RES="Hello World"

if [ -f $FILE ]
then
    rm $FILE
fi

printf "Hello World\033q" | ./li $FILE

read l < $FILE

if [[ $l == $RES ]]
then
    exit 0
else
    exit 1
fi
