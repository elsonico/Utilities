#!/bin/bash

# *********************************** #
# Script to clean SHARD created with  #
#            run.sh v.02              #
#                                     #
#         v0.2 09/12/16               #
#                                     #
# *********************************** #

BASDIR=/home/tav/mycluster
LOG=$BASDIR/process.txt


for i in `grep forked\ process $LOG | awk '{print $NF}'`
do
    kill $i
done

rm -rf $BASDIR/*
