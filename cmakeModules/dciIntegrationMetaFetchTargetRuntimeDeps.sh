#!/bin/bash

set -e

UNIT=$1
TARGET=$2
FILE=$3
LIBDIR=$4

UNAME=$( command -v uname)

echo -n "UNIT[${UNIT}] TARGET[${TARGET}] TARGET_DEPS["

if [[ $( "${UNAME}" | tr '[:upper:]' '[:lower:]') =~ ^.*(msys|mingw).*$ ]]; then
    PATH="${LIBDIR}:${PATH}"
    objdump -p $FILE|grep "DLL Name:" | awk '{print $3}' | xargs -I{} whereis {} | awk -F.': ' '{print $2}' | xargs -I{} cygpath -m {} | xargs -I{} echo -n "{};"
else
    lddOur=`ldd $3`
    objdump -p $FILE|grep NEEDED | awk '{print $2}' | while read NEEDED; do
        echo -n "$lddOur" | grep "$NEEDED => " | awk '{print $3}' | grep -v -e '^$' | xargs -I{} realpath -s {} | xargs -I{} echo -n "{};"
    done
fi

echo "] "
