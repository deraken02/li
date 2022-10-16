#!/bin/bash
chmod +r tester
read l < tester

if [[ $l == "Hello" ]]
then
    exit 0
else
    exit 1
fi
