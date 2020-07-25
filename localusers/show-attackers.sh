#!/bin/bash

# this script show the most failed login attempts

# constants
readonly LIMIT=10

#get the file
LOG_FILE="${1}"

if [[ ! -e "${LOG_FILE}" ]]
then
	echo "cannot open the file ${LOG_FILE}: not found" >&2
	exit 1
fi


CSV_FILE="$(basename ${LOG_FILE}).csv"
touch "${CSV_FILE}"

echo 'Count, IP, Location' > "${CSV_FILE}"

cat "${LOG_FILE}" | grep 'Failed password' | awk -F ' ' '{print $(NF - 3)}' | sort | uniq -c | awk -F ' ' -v OFS=', ' '{"geoiplookup "$2" | cut -d ':' -f 2 | cut -d ',' -f 2"| getline location; print $1, $2, location}' | awk -F ',' -v OFS=', ' -v LIMIT=${LIMIT} '{if($1 > LIMIT) print $1, $2, $3}'| sort -rn >> "${CSV_FILE}"
