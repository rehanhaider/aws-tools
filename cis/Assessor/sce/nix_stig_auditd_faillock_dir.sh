#!/usr/bin/env bash

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# ----------------------------------------------------------------
# J. Brown     10/12/21   Check permissions on audit log directory
# E. Pinnell   07/05/24   Modified to account for minor release 10+ to not be marked "low"
# E. Pinnell   11/15/24   Modified to ignore commented out dir entries 

# XCCDF_VALUE_REGEX should support direct strings and regex

passing=false
rhversion=""

# Get RH version
if rpm -qa redhat-release | grep -Pq -- 'redhat-release-8\.[0-1]\b' ; then
	rhversion="low"
else
	rhversion="high"
fi

#Collect faillock dir value
if [ $rhversion = "low" ]; then
	dirval="$(grep -i pam_faillock.so /etc/pam.d/system-auth | grep -Po "dir=([\H]+)\h" | awk -F"=" '{print $2}' | awk '{$1=$1};1')"
else
#	dirval=$(grep -Po -- "^\h*dir\h*=\h*([\H]+)\h*" /etc/security/faillock.conf | awk -F"=" '{print $2}' | awk '{$1=$1};1')
	dirval="$(awk -F'=' '$1~/^\s*dir/{print $2}' /etc/security/faillock.conf | xargs)"
fi

rule="-w $dirval -p wa -k"

# Check auditd rules
grep -P -- "$rule" /etc/audit/audit.rules && passing=true

# If passing is true, we pass
if [ "$passing" = true ] ; then
	echo "Passed! \"$dirval\" found in auditd ruleset."
	exit "${XCCDF_RESULT_PASS:-101}"
else
	echo "Failed! \"$dirval\" NOT found in auditd ruleset."
	exit "${XCCDF_RESULT_FAIL:-102}"
fi