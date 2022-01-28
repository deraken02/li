#!/bin/bash
chmod +w tester
read l < tester

if [[ $l == "Hello world"* ]]
then
    exit 0
else
    exit 1
fi
