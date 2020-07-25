#!/bin/bash

# this script creates a new account for a given username
# it generates a random password
# it displays the created account info

# check if the script run priviliges
if [[ ${UID} -ne 0 ]]
then
	echo "error: permission denied: please use sudo or run as root" 1>&2
	exit 1
fi

# get username
USERNAME="${1}"
if [[ -z "${USERNAME}" ]]
then
	echo "error: username missing: pleae provide the username" 1>&2
	echo "usage: sudo ${0} USERNAME [COMMENT...]" 1>&2
	exit 1
fi
shift

# get comment
COMMENT="${*}"

# generate password
PASSWORD="$( date +%N%s | sha256sum | head -c 8)"

# create the user accout
useradd -c "${COMMENT}" -m ${USERNAME} 1> /dev/null 2> /tmp/create-new-user.err

# check if user accout has been created
if [[ ${?} -ne 0 ]]
then
	echo "the acount cannot be created" 1>&2
	exit 1
fi

# set the password
echo "${PASSWORD}" | passwd --stdin ${USERNAME} 1> /dev/null 2> /tmp/create-new-user.err

if [[ ${?} -ne 0 ]]
then
	echo "the password cannot be set" 1>&2
	exit 1
fi

# force changing password
passwd -e "${USERNAME}" 1> /dev/null 2> /tmp/create-new-user.err

# display account info
echo
echo "user account has been created: account info:"
echo "username: ${USERNAME}"
echo "password: ${PASSWORD}"
echo "hostname: ${HOSTNAME}"
echo 
exit 0
