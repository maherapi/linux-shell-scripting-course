#!/bin/bash

# this scripts deletes or disable a local user on the system
# It accepts username(s) as arguments
# It displays each username with the associated action

# constants
readonly ARCHIVE_DIR='/archives'

#usage function
usage() {
	echo "usage:" >&2
	echo "${0} [OPTIONS] USERNAME[...]" >&2
	echo "-d 	deletes accounts instead of disabling them." >&2
	echo "-r	removes the home directory associated with the accounts(s)" >&2
	echo "-a	creates an archive of the home directory associated with the account(s) and store them in the /archives directory" >&2
	exit 1
}

# check if run with root privilges
if [[ ${UID} -ne 0 ]]
then 
	echo "please run with sudo or as root" >&2
	exit 1
fi

# check if arguments are not sufficient
while getopts "dra" OPTION
do
	case ${OPTION} in
		d)
			DELETE='true'
			;;
		r) 
			REMOVE='-r'	
			;;
		a) 
			ARCHIVE='true'
			;;
		?) 
			usage
			;;
	esac
done

# remove getopts options from positional arguments
shift $(( OPTIND - 1 ))

# check if at least one username is provided as arg
if [[ ${#} -lt 1 ]]
then
	usage
fi

# performing actions on username(s)
for USERNAME in "${@}"
do
	# do not delete the account if it is a system account
	if [[ $( id -u "${USERNAME}" ) -lt 1000 ]]
	then
		echo "cannot delete ${USERNAME} because it is a system account" >&2
		continue
	fi

	if [[ ${ARCHIVE} = 'true' ]]
	then
		echo "archiving ${USERNAME} home directory..."
		# creats ARCHIVE_DIR if not exists
		if [[ ! -d ${ARCHIVE_DIR} ]]
		then
			mkdir -p ${ARCHIVE_DIR}
			echo "${ARCHIVE_DIR} dir created"
		fi

		ARCHIVE_FILE="${ARCHIVE_DIR}/${USERNAME}.tgz"
		tar -czf ${ARCHIVE_FILE} "/home/${USERNAME}" &> /dev/null 

		if [[ ${?} -ne 0 ]]
		then
			echo "archive for ${USERNAME} could not be created" >&2
			continue
		else
			echo "${ARCHIVE_FILE} has been creates"
		fi	
	fi

	if [[ ${DELETE} = 'true' ]]
	then
		userdel ${REMOVE} ${USERNAME}
		
		if [[ ${?} -ne 0 ]]
		then
			echo "${USERNAME} could not be deleted" >&2
		else
			echo "${USERNAME} has been deleted."
		fi
		
		continue
	fi	
	
	chage -E 0 ${USERNAME}
	
	if [[ ${?} -ne 0 ]]
	then
		echo "${USERNAME} could not be disables" >&2
	else
		echo "${USERNAME} has been disables"
	fi
		
	shift
done


