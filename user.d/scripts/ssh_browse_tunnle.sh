#!/bin/bash
# If the file is not executing right click -> properties -> set to executable

if [ "$#" -eq 0 ]; then
	echo "First argument should be the address to ssh through (e.g. user@my.domain.name)"
	exit 1
fi

echo "Now to use your browser through this tunnel, set the connection settings to SOCKS host localhost:55555"

ssh -D 55555 "$1"
