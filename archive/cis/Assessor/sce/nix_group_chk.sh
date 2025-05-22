#!/usr/bin/env bash

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   09/15/22   Verify a directory or file is group-owned by group (directory/file and group(s) as regex need to be separated by a ':')
# E. Pinnell   08/18/23   Updated to modernize and simplify

# XCCDF_VALUE_REGEX="/usr/bin/:(root|adm)" <- variable example

l_output="" l_output2=""

while IFS=":" read -r l_fname l_owner; do
	if [ -e "$l_fname" ]; then
		l_file_owner=$(stat -Lc '%G' "$l_fname")
		# Gather information for more verbose output
		l_slname="$(readlink -e "$l_fname")"
		[ -d "$l_slname" ] && l_ftype="directory"
		[ -f "$l_slname" ] && l_ftype="file"
		if [[ ! "$l_file_owner" =~ $l_owner\s*$ ]]; then
			l_output2=" - $l_ftype: \"$l_fname\" is group owned by: \"$l_file_owner\" (should be group owned by: \"${l_owner/|/ or }\")"
		else
			l_output=" - $l_ftype: \"$l_fname\" is group owned by: \"$l_file_owner\" (should be group owned by: \"${l_owner/|/ or }\")"
		fi
	else
		l_output=" - \"$l_fname\" doesn't exist"
	fi
done <<< "$XCCDF_VALUE_REGEX"

# If the tests produce no failing output, we pass
if [ -z "$l_output2" ]; then
	echo -e "\n- Audit Result:\n  ** PASS **\n$l_output"
	exit "${XCCDF_RESULT_PASS:-101}"
else
	echo -e "\n- Audit Result:\n  ** FAIL **\n$l_output2"
	exit "${XCCDF_RESULT_FAIL:-102}"
fi