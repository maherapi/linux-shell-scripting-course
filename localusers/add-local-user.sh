#!/bin/bash

# Ex: 2: a bash script to automate adding user account to the system>
# it asks the user for the information and creates the user
# it diplays the username, password and the host

# check if the script is running by root previlges
if [[ $UID -ne 0 ]]
then
	echo "please run this script as root or with sudo"
	echo "Permission denied"
	exit 1
fi

# ask for the account infomation to be added
echo "Please enter the required info for the new account:"

read -p "username: " USERNAME
read -p "full name: " COMMENT
read -p "password: " PASSWORD

# create the user accout
useradd -c "${COMMENT}" -m ${USERNAME} 

# check if user accout has been created
if [[ "${?}" -ne 0 ]]
then
	echo "user account creation FAILED"
	exit 1
fi

#adding a password to the account
echo ${PASSWORD} | passwd --stdin ${USERNAME}

# check if the password being set successfully
if [[ "${?}" -ne 0 ]]
then
	echo "some error in setting the password"
	exit 1
fi


#force changing password in the next login
passwd -e ${USERNAME}

# check if password change enfroce went well
if [[ "${?}" -ne 0 ]]
then
	echo "something went wrong in change password enfrocement"
	exit 1
fi


# display the user account info
echo "========="
echo "accout has been created succesfully"
echo "account info:"
echo "username: ${USERNAME}"
echo "temporal password: ${PASSWORD}"
echo "hostname: ${HOSTNAME}"
exit 0

