#!/bin/bash

if [[ "$1" == "" ]]; then
    echo -e "FATAL: You need to provide a filename as first argument!\nExiting..."
    exit 1
fi

FILENAME=$1

OS=$(uname)
if [[ "$OS" == "Linux" ]]; then
    VIEWER="evince"
    MD5="md5sum"
else #if [[ "$OS" == "Darwin" ]]; then
    VIEWER="/Applications/MacPorts/KDE4/okular.app/Contents/MacOS/okular"
    MD5="md5"
fi

ECHECK=`ps aux | grep "$VIEWER Out/${FILENAME}.pdf" | awk '{print $2}'`
if [ "$ECHECK" ]; then
    EPID="$ECHECK"
else
    $VIEWER Out/${FILENAME}.pdf 2>/dev/null &
    EPID="$!"
fi

OLD=`find . -name "*.tex" -exec cat '{}' \; | $MD5 | grep -o "^[^ ]*"`
OLDCITE=$(find . -name "*.tex" -exec cat '{}' \; |grep -o "\\\cite{[^}]*}" | $MD5 | grep -o "^[^ ]*")
while true; do
    ERUN=`ps aux | awk '{print $2}' | grep "^$EPID$"`
    if [ ! "$ERUN" ]; then
        $VIEWER Out/${FILENAME}.pdf 2>/dev/null &
    EPID="$!"
    fi
    CUR=`find . -name "*.tex" -exec cat '{}' 2>/dev/null \; | $MD5 | grep -o "^[^ ]*"`
    CITE=$(find . -name "*.tex" -exec cat '{}' \; |grep -o "\\\cite{[^}]*}" | $MD5 | grep -o "^[^ ]*")
    if [[ "$CUR" != "$OLD" ]]; then
    if [[ "${CITE}" == "${OLDCITE}" ]]; then
        make compileauto
    else
        make bibcompileauto
    fi
    OLD=$CUR
    OLDCITE=${CITE}
    date
    fi
    sleep 2s
done
