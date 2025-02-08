#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd         01/20/21   Verifying status of nfs server and /etc/exports
# Edward Byrd 		  11/08/22   Updated for the new naming
# Edward Byrd		  07/12/23	 Updated the output and audit
# Edward Byrd		  10/21/24	 Changed to an or since /etc/export has to exist
#

nfsstatus=$(
/bin/launchctl list | /usr/bin/grep -c com.apple.nfsd
)

exportexist=$(
/bin/ls /etc/exports 2>/dev/null | /usr/bin/grep -c "/etc/exports"
)


if [ $exportexist = 0 ]; then
  output=True
elif [ $nfsstatus -eq 0 ]; then
  output=True
else
  output=False
fi

# If result returns 0 pass, otherwise fail.
if [ "$output" == True ] ; then
	echo "PASSED: NFS server is disabled"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "FAILED: The NFS server needs to be unloaded and disabled and/or the export folders needs to be deleted"
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi

