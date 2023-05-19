#!/bin/bash
read err < error
read std < stdout

if [[ $err == "No file specified"* && $std == "" ]]
then
    exit 0
else
    exit 1
fi
