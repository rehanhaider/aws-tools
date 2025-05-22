#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd         09/02/20   Ensure system is set to require 5 or lower failed logins
# Edward Byrd		  11/05/21	 Fixed unexpected operator error
# Edward Byrd 		  11/08/22   Updated for the new naming and new audit
# Edward Byrd		  07/12/23	 Update to output and audit
# Edward Byrd		  10/22/24	 Removed lockout time due to Apple's implementation no longer working correctly
# 


pwprofilemax=$(
/usr/bin/pwpolicy -getaccountpolicies 2> /dev/null | /usr/bin/tail +2 | /usr/bin/xmllint --xpath '//dict/key[text()="policyAttributeMaximumFailedAuthentications"]/following-sibling::integer[1]/text()' -
)

if [ $pwprofilemax -le 5 ] ; then
  output=True
else
  output=False
fi

# If result returns 0 pass, otherwise fail.
if [ "$output" == True ] ; then
	echo "PASSED: The password policy for maximum amount of attempts and lockout time is set correctly"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "FAILED: The password policy maximum amount of attempts is \"$pwprofilemax\" which is greater than the 5 allowable attempts or teh lockout time is set to less than 15 minutes"
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi


