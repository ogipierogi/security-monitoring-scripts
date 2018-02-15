#!/bin/bash

set -e

EMAIL=admin@fancycompany.pl

# Send an e-mail notification
function sendMail () {
    echo $1
    echo "You have an incident! $1" | mail -s "Test Postfix" $EMAIL

}
