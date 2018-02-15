#!/bin/bash

set -e

source /opt/maintenance_software/tools_scripts/tools.sh

# Policy which we checking is as follows:
# Serwer-Aplikacji - eligible to connect only from 8.8.8.8, called in var as APPLICATION_SERVER
# Hurtownia-Admin - eligible to connect only from localhost, called in var as WAREHOUSE_ADMIN
# Pracownik-Admin - eligible to connect only from localhost, called in var as EMPLOYEE_ADMIN

# List hosts from indicated users are able to connect
APPLICATION_SERVER=$(mysql -u root -e "SELECT Host FROM mysql.user WHERE User='Serwer-Aplikacji'" | awk 'NR > 1 { print $1 }')
WAREHOUSE_ADMIN=$(mysql -u root -e "SELECT Host FROM mysql.user WHERE User='Hurtownia-Admin'" | awk 'NR > 1 { print $1 }')
EMPLOYEE_ADMIN=$(mysql -u root -e "SELECT Host FROM mysql.user WHERE User='Pracownik-Admin'" | awk 'NR > 1 { print $1 }')

# Policy for databases - which user can access database
# Hurtownia - only Hurtownia-Admin is eligible to perform administrative tasks, called in var as WAREHOUSE_DATABASE
# Pracownicy - only Serwer-Aplikacji and Pracownik-Admin are eligible to perform administrative tasks, called in var as EMPLOYEE_DATABASE

# List databases permissions granted for users
WAREHOUSE_DATABASE=$(mysql -u root -e "SELECT User FROM mysql.db WHERE db='Hurtownia';" | awk 'NR > 1 { print $1 }')
EMPLOYEE_DATABASE=$(mysql -u root -e "SELECT User FROM mysql.db WHERE db='Pracownicy';" | awk 'NR > 1 { print $1 }')

# APPLICATION_SERVER users function
function checkAppServerPermissions () {
    # Check if users can connect only from single location, if not - send e-mail notification to administrator
    HOSTNAME_NUMBER=$(echo "$APPLICATION_SERVER" | wc -l)

    if [ $(($HOSTNAME_NUMBER)) -eq 1 ]; then
        echo "User APPLICATION_SERVER is able to connect only from single location."
    else
        echo "User APPLICATION_SERVER is able to connect from more than one location!"
        sendMail "User APPLICATION_SERVER is able to connect from more than one location!"
    fi

    # Check if user is able to connect from proper location, if not - send e-mail notification to administrator
    if [ $APPLICATION_SERVER == "8.8.8.8"  ]; then
        echo "User APPLICATION_SERVER is able to connect only from 8.8.8.8."
    else
        echo "User APPLICATION_SERVER is able to connect from following unknown location: $APPLICATION_SERVER !"
        sendMail "User APPLICATION_SERVER is able to connect from following unknown location: $APPLICATION_SERVER !"
    fi
}

# WAREHOUSE_ADMIN users function
function checkWareHouseAdminPermissions () {
    # Check if users can connect only from single location, if not - send e-mail notification to administrator
    HOSTNAME_NUMBER=$(echo "$WAREHOUSE_ADMIN" | wc -l)

    if [ $(($HOSTNAME_NUMBER)) -eq 1 ]; then
        echo "User WAREHOUSE_ADMIN is able to connect only from single location."
    else
        echo "User WAREHOUSE_ADMIN is able to connect from more than one location !"
        sendMail
    fi

    # Check if user is able to connect from proper location, if not - send e-mail notification to administrator
    if [ $WAREHOUSE_ADMIN == "localhost"  ]; then
        echo "User WAREHOUSE_ADMIN is able to connect only from localhost."
    else
        echo "User WAREHOUSE_ADMIN is able to connect from following unknown location: $WAREHOUSE_ADMIN !"
    fi
}

# EMPLOYEE_ADMIN users function
function checkEmployeeAdminPermissions () {
    # Check if users can connect only from single location, if not - send e-mail notification to administrator
    HOSTNAME_NUMBER=$(echo "$EMPLOYEE_ADMIN" | wc -l)

    if [ $(($HOSTNAME_NUMBER)) -eq 1 ]; then
        echo "User EMPLOYEE_ADMIN is able to connect only from single location."
    else
        echo "User EMPLOYEE_ADMIN is able to connect from more than one location !"
        sendMail "User WAREHOUSE_ADMIN is able to connect from more than one location !"
    fi

    # Check if user is able to connect from proper location, if not - send e-mail notification to administrator
    if [ $EMPLOYEE_ADMIN == "localhost"  ]; then
        echo "User EMPLOYEE_ADMIN is able to connect only from localhost."
    else
        echo "User EMPLOYEE_ADMIN is able to connect from following unknown location: $EMPLOYEE_ADMIN !"
        sendMail "User EMPLOYEE_ADMIN is able to connect from following unknown location: $EMPLOYEE_ADMIN !"
    fi
}

function checkWareHouseDatabasePermissions () {
    # Check if only single user can perform administrative tasks on Hurtownia database, if not - send e-mail notification to administrator
    USER_NUMBER=$(echo "$WAREHOUSE_DATABASE" | wc -l)

    if [ $(($USER_NUMBER)) -eq 1 ]; then
        echo "Database Hurtownia can be administered only by single user."
    else
        echo "Database Hurtownia can be administered by more than one user!"
        sendMail "Database Hurtownia can be administered by more than one user!"
    fi

    # Check if only Hurtownia-Admin is able to perform administrative tasks on Hurtownia database, if not - send e-mail notification to administrator

    if [ $WAREHOUSE_DATABASE == "Hurtownia-Admin" ]; then
        echo "Databse Hurtownia can be administered only by Hurtownia-Admin."
    else
        echo "Database Hurtownia can be administered by not eligible user: $WAREHOUSE_DATABASE !"
        sendMail "Database Hurtownia can be administered by not eligible user: $WAREHOUSE_DATABASE !"
    fi
}

function checkEmployeeDatabasePermissions () {
    # Check if only two users can perform administrative tasks on Pracownicy database, if not - send e-mail notification to administrator
    USER_NUMBER=$(echo "$EMPLOYEE_DATABASE" | wc -l)

    if [ $(($USER_NUMBER)) -eq 2 ]; then
        echo "Database Pracownicy can be administered only by two users."
    else
        echo "Database Pracownicy can be administered by more than two users:!"
        sendMail "Database Pracownicy can be administered by more than two users:!"
    fi

    # Check if only Serwer-Aplikacji and Pracownik-Admin are able to perform administrative tasks on Pracownicy database, if not - send e-mail notification to administrator
    IFS=$'\n' users=($EMPLOYEE_DATABASE)

    if [ ${users[0]} == "Pracownik-Admin" ] && [ ${users[1]} == "Serwer-Aplikacji" ] || \
       [ ${users[0]} == "Serwer-Aplikacji" ] && [ ${users[1]} == "Pracownik-Admin" ]; then
        echo "Database Pracownicy can be administered by Serwer-Aplikacji and Pracownik-Admin."
    else
        echo "Database Pracownicy can be administered by unknown users!"
        sendMail "Database Pracownicy can be administered by unknown users!"
    fi
}

# Perform checks of user connection from indicated location permissions
checkAppServerPermissions
checkWareHouseAdminPermissions
checkEmployeeAdminPermissions

# Perform check of permissions granted to indicated users for respective databases
checkWareHouseDatabasePermissions
checkEmployeeDatabasePermissions
