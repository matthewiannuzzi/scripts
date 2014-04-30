#!/bin/bash

#accept stdin and echo with date: stdin
    while read line
    do

    echo $(date) ":" $line;

    done

