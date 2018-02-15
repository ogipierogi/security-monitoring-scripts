#!/bin/bash

set -e

source /opt/maintenance_software/tools_scripts/tools.sh

# Check if database is running, if not - send e-mail notification to administrator
function checkIfDatabaseIsRunning () {
    STATUS="$(systemctl status mysql | grep "Active:")"

    if [[ $STATUS = *"active (running)"* ]]; then
        echo "Database is running."
    else
        echo "Database is down!"
        sendMail "Database is down!"
    fi
}

checkIfDatabaseIsRunning
