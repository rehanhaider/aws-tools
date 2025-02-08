#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd         08/31/20   Ensure system is set to to wake on LAN or use Power Nap
# Edward Byrd		  10/08/20   Forked from osx_wakenap.sh for 10.14 and 10.15 1.1.0 benchmarks due to power nap and wake on LAN being separate recommendations
# Edward Byrd		  06/15/22	 Added support for profiles
#

wakelan=$(
pmset -g | grep -c 'womp                 0'
)

wakelanprofile=$(
profiles -P -o stdout | /usr/bin/grep -c '"Wake On LAN" = 0'
)

wakemodemprofile=$(
profiles -P -o stdout | /usr/bin/grep -c '"Wake On Modem Ring" = 0'
)


if [ $wakelanprofile -ge 1 ] && [ $wakemodemprofile -ge 1 ]; then
  output=True
elif [ $wakelan == 1 ]; then
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

