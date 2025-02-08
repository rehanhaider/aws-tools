#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd         10/28/20   Enable logging of sudo commands
# 

sudologging=$(
/usr/bin/sudo -V | /usr/bin/grep -c "Log when a command is allowed by sudoers"
)

if [ $sudologging == 1 ]; then
  output=True
else
  output=False
fi

# If result returns 0 pass, otherwise fail.
if [ "$output" == True ] ; then
	echo "PASSED: Logging of sudo commands is enabled"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "FAILED: Sudoers need to be edited to enable sudo logging"
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi
