#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd		  11/03/22	 Check that media sharing is disabled
# Edward Byrd		  06/27/23	 Update to echo why it failed
# Edward Byrd		  10/22/24	 Added version check for new Sequoia updates
#

mediasharing=$(
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let pref1 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.preferences.sharing.SharingPrefsExtension')\
  .objectForKey('homeSharingUIStatus'))
  let pref2 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.preferences.sharing.SharingPrefsExtension')\
  .objectForKey('legacySharingUIStatus'))
  let pref3 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.preferences.sharing.SharingPrefsExtension')\
  .objectForKey('mediaSharingUIStatus'))
  if ( pref1 == 0 && pref2 == 0 && pref3 == 0 ) {
    return("true")
  } else {
    return("false")
  }
}
EOS
)

mediasharingnew=$(
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let pref1 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
  .objectForKey('allowMediaSharing'))
  let pref2 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
  .objectForKey('allowMediaSharingModification'))
  if ( pref1 == 0 && pref2 == 0 ) {
    return("true")
  } else {
    return("false")
  }
}
EOS
)

macOSversion=$(
/usr/bin/sw_vers | /usr/bin/grep ProductVersion | awk '{s+=$2} END {print s}' | cut -c1-2
)


if [ $macOSversion -ge 15 ] && [ "$mediasharingnew" == "true" ]; then
  output=True
elif [ $macOSversion -lt 15 ] && [ "$mediasharing" == "true" ]; then
  output=True
else
  output=False
fi

	# If test passed, then no output would be generated. If so, we pass
if [ "$output" = True ] ; then
	echo "PASSED: A profile is installed that disabled media sharing"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "FAILED: A profile needs to be installed that disabled media sharing"
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi
