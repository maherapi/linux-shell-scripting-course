#!/bin/bash

# this script runs a command on multiple servers

# constants
SERVERS_FILE='/vagrant/servers'
TIMEOUT=2

EXIT_STATUS=0

# funtions
usage() {
	echo "usage: ${0} [-nsvf] COMMANDS" >&2
	echo "  -n                 dry run, display commands instead of running them" >&2
	echo "  -s                 run commands as sudo" >&2
	echo "  -v                 be verbose, display commands run on each machine" >&2
	echo "  -f SERVERS_FILE    specify a file containing servers hostnames, default is ${SERVERS_FILE}" >&2
	exit 1
}	

display() {
	local TEXT="${*}"
	if [[ ${VERBOSE} = 'true' ]]
	then
		echo "${TEXT}"
	fi
}

run() {
	local SERVER="${1}"
	shift

	local CMD="${*}"
	
	if [[ ${SUDO} = 'true' ]]
	then 
		CMD="sudo ${CMD}"
	fi

	if [[ ${DRY_RUN} = 'true' ]]
	then
		echo "DRY RUN: ${CMD}"
	else
		display "running: ${CMD} ..."
		eval "ssh -o ConnectTimeout=${TIMEOUT} ${SERVER} '${CMD}'" 2> /dev/null
		
		EXIT_STATUS=${?}
		if [[ ${EXIT_STATUS} -ne 0 ]]
		then
			echo "${SERVER}: failed: ${CMD}" >&2
		fi
	fi
}

# check if run as root or sudo
if [[ ${UID} -eq 0 ]]
then
	echo "execute without superuser (root) privileges.  If you want the remote commands executed with superuser (root) privileges, specify the -s option." >&2
	usage
fi

# get options
while getopts 'f:nsv' OPTION
do
	case ${OPTION} in
		f) SERVERS_FILE="${OPTARG}" ;;
		n) DRY_RUN='true' ;;
		s) SUDO='true' ;;
		v) VERBOSE='true' ;;
		?) usage
	esac
done
shift $(( OPTIND - 1 ))

# check SERVERS_FILE
if [[ ! -e "${SERVERS_FILE}" ]]
then
	echo "failed: could NOT open ${SERVERS_FILE}" >&2
	exit 1
fi 

# get the commands
COMMAND="${@}"

# check if COMMAND is given as argument
if [[ -z "${COMMAND}" ]]
then
	echo "please specify the command to execute" >&2
	usage
fi

# run the command on each server
for SERVER in $(cat "${SERVERS_FILE}")
do
	display "========"
	display "${SERVER}"
	run "${SERVER}" "${COMMAND}"
done

exit ${EXIT_STATUS}
