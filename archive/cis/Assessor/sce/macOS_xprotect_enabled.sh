#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd         10/12/23   5.10/5.11 Ensure XProtect Is Running and Updated
# Edward Byrd         10/12/23   Added check for macOS version and new audit
# Edward Byrd		  10/22/24	 Added version check for macOS 15 with new binary commands
# 

xprotectenable=$(
/bin/launchctl list | /usr/bin/grep -cE "(com.apple.XprotectFramework.PluginService$|com.apple.XProtect.daemon.scan$)"
)

macOSversion=$(
/usr/bin/sw_vers | /usr/bin/grep ProductVersion | awk '{s+=$2} END {print s}' | cut -c1-2
)

xprotectlaunch=$(
/usr/bin/xprotect status | /usr/bin/grep -c "XProtect launch scans: enabled"
)

xprotectbackground=$(
/usr/bin/xprotect status | /usr/bin/grep -c "XProtect background scans: enabled" 
)

if [ $macOSversion -ge 15 ] && [ $xprotectlaunch = 1 ] && [ $xprotectbackground = 1 ]; then
  output=True	
elif [ $xprotectenable -eq 2 ] ; then
  output=True
else
  output=False
fi

# If result returns 0 pass, otherwise fail.
if [ "$output" = True ] ; then
	echo "PASSED: XProtect is enabled"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "FAILED: XProtect is disabled and needs to be investigated"
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi
