#!/bin/bash

set -e

source /opt/maintenance_software/tools_scripts/tools.sh

# Check if backup zip files stored in server are not corrupted, if so - send e-mail notification to administrator
function checkIfCorrupted () {
    BACKUP_LOCATION=/media/backups

    for file in ${BACKUP_LOCATION}/*; do
        if [[ $(zip -T ${BACKUP_LOCATION}/${file##*/} | grep "OK") = *"OK"* ]]; then
            echo "Backup file ${file##*/} is not corrupted."
        elif [[ $(zip -T ${BACKUP_LOCATION}/${file##*/} 2>&1 | grep "zip error:") = *"Zip file invalid"* ]]; then
            echo "Backup file${file##*/} is corrupted!"
            sendMail "BAckup file ${file##*/} is corrupted!"
        fi
    done
}

checkIfCorrupted
