#!/bin/bash

set -e

source /opt/maintenance_software/tools_scripts/tools.sh

# Check RAM usage, if swap is used send e-mail notification to administrator
function checkRamUsage () {
    SWAP_USAGE="$(awk '/^Swap/ {print $3}' <(free -m))"

    if [ $(($SWAP_USAGE)) -eq 0 ]; then
        echo "Swap is not yest in use."
    else
        echo "Machine is using swap!"
        sendMail "Machine is using swap!"
    fi
}

# Check CPU usage, function check how much CPU is not used, if value is less than 10% - send notification to administrator
function checkCpuUsage() {
    FREE_CPU=$(printf "%.0f" "$(top -n 1 -b | awk '/^%Cpu/{print $8}')")
    BUSY_CPU=$((100 - $FREE_CPU))

    if [ $(($BUSY_CPU)) -lt 90 ]; then
        echo "CPU usage is under 90%."
    else
        echo "CPU usage is over 90%!"
        sendMail "CPU usage is over 90%!"
    fi
}

checkRamUsage
checkCpuUsage
