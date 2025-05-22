#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd         09/22/20   Enable Login Window Banner
# Edward Byrd         06/16/20   Added permission check
# 

loginbanner=$(
ls /Library/Security | grep -c "PolicyBanner."
)

bannerpermission=$(
stat -f %A /Library/Security/PolicyBanner.* | /usr/bin/cut -c 3
)

if [ $loginbanner == 1 ] && [ $bannerpermission == 4 ]; then
  output=True
else
  output=False
fi

# If result returns 0 pass, otherwise fail.
if [ "$output" == True ] ; then
	echo "$output"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi
