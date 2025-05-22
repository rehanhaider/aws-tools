#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd 		  11/08/22   Enable Safari to warn when visting fraudulent sites
# Edward Byrd		  07/12/23	 Update to output and removed individual user audit
#

safariwarnprofile=$(
profiles -P -o stdout | /usr/bin/grep -c "WarnAboutFraudulentWebsites = 1;")

if [ "$safariwarnprofile" == "1" ]; then
  output=True
else
  output=False
fi

# If test passed, then no output would be generated. If so, we pass
if [ "$output" = True ] ; then
	echo "PASSED: Profile installed to warn when visiting a fraudulent site in Safari"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "FAILED: A profile needs to be installed that warns when visiting fraudulent in Safari"
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi
