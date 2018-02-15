#!/bin/bash

set -e

source /opt/maintenance_software/tools_scripts/tools.sh

# List all users which are currently have open sessions to mysql
# Policy: only root, Hurtownia-Admin, Serwer-Aplikacji, Pracownik-Admin are eligible to have open sessions

USERS_CONNECTION_LIST=$(mysql -u root -e "SELECT * FROM INFORMATION_SCHEMA.PROCESSLIST" | awk 'NR > 1 { print $2 }')

function checkWhoIsconnected () {
    # Check if only eligible users are connected to database, if not - send e-mail notification to administrator

    while read -r user; do
        if [ $user == "root" ] || \
           [ $user == "Hurtownia-Admin" ] || \
           [ $user == "Serwer-Aplikacji" ] || \
           [ $user == "Pracownik-Admin" ]; then
            echo "Eligible user has established connection to database: $user ."
        else
            echo "Not eligible user has established connection to database: $user !"
            sendMail "Not eligible user has established connection to database: $user !"
        fi
    done <<< "$USERS_CONNECTION_LIST"
}

checkWhoIsconnected
