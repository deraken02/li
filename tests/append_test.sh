#!/bin/bash
chmod +r tester
read l < tester

if [[ $l == "Hello world\nGoodbye world"* ]]
then
    exit 0
else
    exit 1
fi
