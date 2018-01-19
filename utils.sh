#!/bin/bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPTDIR/constants_local.sh"

accessor_pid(){
	lsof "$1" | grep -P "^.*?\s+\d+\s+" -o | grep -P "\d+" -o
}

graceful_terminate_accessor(){
	kill `accessor_pid $1` 2> /dev/null
	for (( i=0; i<=10; i++)); do
		if [[ -z `accessor_pid $1` ]]; then
			#echo "It's not running. At least, for now."
			exit 0
		else
			echo "Waiting for process to stop..."
			sleep 1
		fi
	done

	echo "Seems like it's not gonna terminate itself. Hard-shutdown commencing!"
	kill -9 `accessor_pid $1`
}

# echoes directory of calling script
# assumed calling from other file, not utils.sh
selfdir(){
	echo "$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd)"
}

stop_if_not_root(){
	if [[ $EUID -ne 0 ]]; then
		echo "This script must be run as root" 
		exit 1
	fi
}