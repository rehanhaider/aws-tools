#!/usr/bin/env bash

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   08/21/23   check audit log files owner
# E. Pinnell   09/01/23   Modified to handel error if "/etc/audit/auditd.conf" doesn't exist

# XCCDF_VALUE_REGEX="(root|adm)" #<- example XCCDF_VALUE_REGEX variable

l_output="" l_output2="" l_count="0"
l_owner="$XCCDF_VALUE_REGEX"

if [ -e "/etc/audit/auditd.conf" ]; then
   l_directory="$(dirname "$(awk -F "=" '/^\s*log_file\s*/ {print $2}' /etc/audit/auditd.conf | xargs)")"
   while IFS= read -r -d $'\0' l_fname; do
      (( l_count++ ))
      l_file_owner="$(stat -Lc '%U' "$l_fname")"
      if [[ ! "$l_file_owner" =~ $l_owner\s*$ ]]; then
         l_output2="$l_output2\n - file: \"$l_fname\" is owned by: \"$l_file_owner\" (should be owned by: \"${l_owner/|/ or }\")"
      fi
   done < <(find "$l_directory" -type f -print0)
else
   l_output2=" - Unable to read \"/etc/audit/auditd.conf\"\n  - verify auditd is installed, auditd.conf exists, and the log parameter is set"
fi

if [ -z "$l_output2" ]; then
   if [ "$l_count" -gt "0" ]; then
      l_output=" - All files in: \"$l_directory\" are owned by: \"${l_owner/|/ or }\""
   else
      l_output=" - No files exist in: \"$l_directory\""
   fi
fi

# If the tests produce no failing output, we pass
if [ -z "$l_output2" ]; then
	echo -e "\n- Audit Result:\n  ** PASS **\n$l_output"
	exit "${XCCDF_RESULT_PASS:-101}"
else
	echo -e "\n- Audit Result:\n  ** FAIL **\n$l_output2"
	exit "${XCCDF_RESULT_FAIL:-102}"
fi