#!/bin/bash

set -e

UNIT=$1
TARGET=$2
FILE=$3

echo -n "UNIT[${UNIT}] TARGET[${TARGET}] TARGET_DEPS["

objdump -p $FILE|grep NEEDED|awk '{print $2}'|while read NEEDED; do
    echo -n ";`ldd $3 | grep "$NEEDED => " | awk '{print $3}'|xargs -L1 realpath -s`"
done

echo -n "]"

