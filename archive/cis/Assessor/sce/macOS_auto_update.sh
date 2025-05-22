#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd		  10/31/22	 Check that OS auto updates
# Edward Byrd		  06/19/23	 Update to echo why it failed
# Edward Byrd		  10/22/24	 Added version check for macOS 15
#

autoupdate=$(
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.SoftwareUpdate')\
.objectForKey('AutomaticCheckEnabled').js
EOS
)

macOSversion=$(
/usr/bin/sw_vers | /usr/bin/grep ProductVersion | awk '{s+=$2} END {print s}' | cut -c1-2
)

if [ "$autoupdate" == "true" ] || [ $macOSversion -ge 15 ]; then
  output=True
else
  output=False
fi

# If result returns 0 pass, otherwise fail.
if [ "$output" = True ] ; then
	echo "PASSED: Updates are being checked automatically"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "FAILED: Updates are not being checked automatically"
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi
fi

