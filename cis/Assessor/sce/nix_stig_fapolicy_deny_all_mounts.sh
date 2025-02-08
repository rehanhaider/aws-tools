#!/usr/bin/env bash

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# ------------------------------------------------------------------------------------------------------------
# E. Pinnell   11/15/21     Verify all tmpfs, ext[2-4] and xfs mounts are included in the fapolicyd.mounts files

# Note: Deprecates nix_stig_fapolicy_deny_all_mounts.sh

a_output=() a_output2=()

while IFS= read -r l_mountpoint; do
	if grep -Ps -- '^\h*'"$l_mountpoint"'\b' /etc/fapolicyd/fapolicyd.mounts; then
		a_output+=("\"$l_mountpoint\" included in /etc/fapolicyd/fapolicyd.mounts")
	else
		a_output2+=("\"$l_mountpoint\" is not included in /etc/fapolicyd/fapolicyd.mounts")
	fi
done < <(mount | grep -P -- '(^tmpfs|ext4|ext3|xfs)\b' | awk '{ printf "%s\n", $3 }')

# Send test results and assessment evidence to CIS-CAT
if [ "${#a_output2[@]}" -le 0 ]; then
   printf '%s\n' "" "- Audit Result:" "  ** PASS **" "${a_output[@]}" ""
   exit "${XCCDF_RESULT_PASS:-101}"
else
   printf '%s\n' "" "- Audit Result:" "  ** FAIL **" " - Reason(s) for audit failure:" "${a_output2[@]}"
   [ "${#a_output[@]}" -gt 0 ] && printf '%s\n' "" "- Correctly set:" "${a_output[@]}" ""
   exit "${XCCDF_RESULT_FAIL:-102}"
fi