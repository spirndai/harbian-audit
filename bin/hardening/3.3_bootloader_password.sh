#!/bin/bash

#
# harbian audit 7/8/9/10 or CentOS Hardening
# Modify by: Samson-W (samson@hardenedlinux.org)
#

#
# 3.3 Set Boot Loader Password (Scored)
#

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=3

FILE='/boot/grub/grub.cfg'
PKGNAME='grub-pc'
USER_PATTERN="^set superusers"
PWD_PATTERN="^password_pbkdf2"

# This function will be called if the script status is on enabled / audit mode
audit () {
	if [ $OS_RELEASE -eq 2 ]; then
		FILE='/boot/grub2/grub.cfg'
	else
		:
	fi
    does_pattern_exist_in_file $FILE "$USER_PATTERN"
    if [ $FNRET != 0 ]; then
        crit "$USER_PATTERN not present in $FILE"
    else
        ok "$USER_PATTERN is present in $FILE"
    fi
    does_pattern_exist_in_file $FILE "$PWD_PATTERN"
    if [ $FNRET != 0 ]; then
        crit "$PWD_PATTERN not present in $FILE"
    else
        ok "$PWD_PATTERN is present in $FILE"
    fi
}

# This function will be called if the script status is on enabled mode
apply () {
	if [ $OS_RELEASE -eq 2 ]; then
		FILE='/boot/grub2/grub.cfg'
	else
		:
	fi
    does_pattern_exist_in_file $FILE "$USER_PATTERN"
    if [ $FNRET != 0 ]; then
        warn "$USER_PATTERN not present in $FILE, please configure password for grub"
    else
        ok "$USER_PATTERN is present in $FILE"
    fi
    does_pattern_exist_in_file $FILE "$PWD_PATTERN"
    if [ $FNRET != 0 ]; then
        warn "$PWD_PATTERN not present in $FILE, please configure password for grub"
    else
        ok "$PWD_PATTERN is present in $FILE"
    fi
    :
}

# This function will check config parameters required
check_config() {
	if [ $OS_RELEASE -eq 2 ]; then
		FILE='/boot/grub2/grub.cfg'
		PKGNAME='grub2-pc'
	else
		:
	fi
    is_pkg_installed "$PKGNAME"
    if [ $FNRET != 0 ]; then
        warn "$PKGNAME is not installed, not handling configuration"
        exit 128
    fi
    if [ $FNRET != 0 ]; then
        crit "$FILE does not exist"
        exit 128
    fi
}

# Source Root Dir Parameter
if [ -r /etc/default/cis-hardening ]; then
    . /etc/default/cis-hardening
fi
if [ -z "$CIS_ROOT_DIR" ]; then
     echo "There is no /etc/default/cis-hardening file nor cis-hardening directory in current environment."
     echo "Cannot source CIS_ROOT_DIR variable, aborting."
    exit 128
fi

# Main function, will call the proper functions given the configuration (audit, enabled, disabled)
if [ -r $CIS_ROOT_DIR/lib/main.sh ]; then
    . $CIS_ROOT_DIR/lib/main.sh
else
    echo "Cannot find main.sh, have you correctly defined your root directory? Current value is $CIS_ROOT_DIR in /etc/default/cis-hardening"
    exit 128
fi
