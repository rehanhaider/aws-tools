#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd		  09/18/20   Check audit record access
# Edward Byrd		  03/05/21   Updated to include file check
# Edward Byrd 		  11/08/22   Updated for the new naming
# Edward Byrd		  06/27/23	 Updated the output
# Edward Byrd		  10/22/24	 Audit updated to match benchmark
# 


controlowner=$(
/bin/ls -n /etc/security/audit_control | /usr/bin/awk '{s+=$3} END {print s}'
)

controlgroup=$(
/bin/ls -n /etc/security/audit_control | /usr/bin/awk '{s+=$4} END {print s}'
)

controlaccess=$(
/bin/ls -n /etc/security/audit_control | /usr/bin/awk '!/-r--r-----|current|total/{print $1}' | /usr/bin/wc -l | /usr/bin/tr -d ' '
)

auditowner=$(
/bin/ls -n $(/usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}') | /usr/bin/awk '{s+=$3} END {print s}'
)

auditgroup=$(
/bin/ls -n $(/usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}') | /usr/bin/awk '{s+=$4} END {print s}'
)

auditfilesaccess=$(
/bin/ls -n $(/usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}') | /usr/bin/awk '!/-r--r-----|current|total/{print $1}' | /usr/bin/wc -l | /usr/bin/tr -d ' '
)

if [ $controlowner = 0 ] && [ $controlgroup = 0 ] && [ $auditowner = 0 ] && [ $auditgroup = 0 ] && [ $auditfilesaccess = 0 ]; then
  output=True
else
  output=False
fi

# If result returns 0 pass, otherwise fail.
if [ "$output" == True ] ; then
	echo "PASSED: Controlled access to audit records is correctly set"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "FAILED: Some files have the incorrect permissions"
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi
