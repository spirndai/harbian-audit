#!/bin/bash

#
# harbian audit 9 or CentOS Hardening
#

#
# 5.8 Ensure sudo is installed (Scored)
# Add new by: 
# Author : Samson wen, Samson <sccxboy@gmail.com> 
#

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=2

PACKAGE='sudo'


# This function will be called if the script status is on enabled / audit mode
audit () {
    is_pkg_installed $PACKAGE
    if [ $FNRET != 0 ]; then
        crit "$PACKAGE is not installed!"
	FNRET=1
    else
        ok "$PACKAGE is installed"
	FNRET=0
    fi
}

# This function will be called if the script status is on enabled mode
apply () {	
    if [ $FNRET = 0 ]; then
        ok "$PACKAGE is installed"
    else
        warn "$PACKAGE is absent, installing it"
        apt_install $PACKAGE
    fi
}

# This function will check config parameters required
check_config() {
    :
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