#!/bin/bash

set -e

source /opt/maintenance_software/tools_scripts/tools.sh

# Check disk space usage, if more then 80% is used - send e-mail notification to administrator
function checkDiskSpace () {
    DISK_USAGE=$(df -h / | awk 'NR > 1 { print $5 }' | tr -d '%')

    if [ $(($DISK_USAGE)) -lt 80 ]; then
        echo "Disk space usage is under 80%."
    else
        echo "Disk usage is over 80% !"
        sendMail "Disk usage is over 80% !"
    fi
}

checkDiskSpace
