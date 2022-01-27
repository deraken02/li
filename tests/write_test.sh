#!/bin/bash
read l < tester
if [[ $l == "Hello world"* ]]
then
    exit 0
else
    exit 1
fi
