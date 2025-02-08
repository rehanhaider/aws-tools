#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd		  10/31/22	 Check that firewall is enabled
# Edward Byrd		  06/23/23	 Update to echo why it failed
# Edward Byrd		  10/21/24	 Added binary check for the binary for macOS 15 and forward
#

#firewall=$(
#/usr/bin/osascript -l JavaScript << EOS
#function run() {
#    app = Application.currentApplication()
#    app.includeStandardAdditions = true;#
#
#    
#  let pref1 = app.doShellScript('/usr/bin/defaults read /Library/Preferences/com.apple.alf globalstate 2&>1')
#  let pref2 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.security.firewall')\
#  .objectForKey('EnableFirewall'))
#  
#    if ( ( ( pref1 == 1 ) || ( pref1 == 2 ) || ( pref2 == "true" ) ) && (pref1 != 0 ) ) {
#    return("true")
#  } else {
#    return("false")
#  }
#
#}
#EOS
#)

firewall=$(
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.firewall')\
.objectForKey('EnableFirewall').js
EOS
)

firewallbinary=$(
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep -c "Firewall is enabled"
)

firewallplist=$(
/usr/bin/defaults read /Library/Preferences/com.apple.alf globalstate 2&>1
)

if [ "$firewall" == "true" ] && [ $firewallplist = 1 ]; then
  output=True
elif [ "$firewall" == "true" ] && [ $firewallplist = 2 ]; then
  output=True
elif [ $firewallbinary = 1 ]; then
  output=True
else
  output=False
fi

# If result returns 0 pass, otherwise fail.
if [ "$output" = True ] ; then
	echo "PASSED: The firewall is enabled"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "FAILED: The firewall is not enabled"
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi
