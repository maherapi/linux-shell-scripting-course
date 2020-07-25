#!/bin/bash

# this script creates new local user given the username and the description (full name) as arguments
# the script will generate an initial password for the account and will force to change it after first login
# the script will display the username name and the username, randomly generated password, and hostname

# check if the script is run by root or sudo previlges
if [[ ${UID} -ne 0 ]]
then
	echo "please run the script as root or use sudo."
	exit 1
fi

# get the username
USERNAME="${1}"
# if username name is empty; display a usage message
if [[ -z "${USERNAME}" ]] 
then
	echo "please provide the username as the first argument, and the comment as the second argument."
	exit 1
fi
# remove username from the arguments
shift

# get the comments
COMMENT="${*}"

# create the user account
useradd -c "${COMMENT}" -m "${USERNAME}"

# display error exit if user not created
if [[ "${?}" -ne 0 ]]
then
	echo "user account creation FAILED."
	exit 1
fi

# generate a random password
PASSWORD=$( date +%N | sha1sum | head -c6 )

# set the password to the account
echo "${PASSWORD}" | passwd --stdin "${USERNAME}"

 # display error  message if password does not set
if [[ "${?}" -ne 0 ]]
then
	echo "user account password setting FAILED."
fi

# force change password on first login
passwd -e "${USERNAME}"

# display account info
echo
echo "=============="
echo "acount information:"
echo "username: ${USERNAME}"
echo "password: ${PASSWORD}"
echo "hostname: ${HOSTNAME}"
echo

exit 0
