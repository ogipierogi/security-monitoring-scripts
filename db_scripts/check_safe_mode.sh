#!/bin/bash

set -e

source /opt/maintenance_software/tools_scripts/tools.sh

# Check if MySQL Safe Mode is enabled, if not - send e-mail notification to administrator
function checkSafeModeStatus () {
    SAFE_MODE_STATUS="$(mysql -u root -e "SHOW VARIABLES LIKE 'SQL_SAFE_UPDATES';" | awk 'FNR == 2 { print $2 }')"

    if [ $SAFE_MODE_STATUS == "ON" ]; then
        echo "MySQL Safe Mode is enabled."
    else
        echo "MySQL Safe Mode is not enabled!"
        sendMail "MySQL Safe Mode is not enabled!"
    fi
}

checkSafeModeStatus
