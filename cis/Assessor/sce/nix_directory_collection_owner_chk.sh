#!/usr/bin/env bash

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   08/18/23   check directory collection owner check (Two part colon separated variable. {DIRECTORY}:{OWNER}) example: /usr/sbin:root

# XCCDF_VALUE_REGEX="/usr:root" #<- example XCCDF_VALUE_REGEX variable

l_output="" l_output2="" l_count="0"

while IFS=: read -r l_directory l_owner; do
   while IFS= read -r -d $'\0' l_fname; do
      (( l_count++ ))
      l_file_owner="$(stat -Lc '%U' "$l_fname")"
      if [[ ! "$l_file_owner" =~ $l_owner\s*$ ]]; then
         l_output2="$l_output2\n - Directory: \"$l_fname\" is owned by: \"$l_file_owner\" (should be owned by: \"${l_owner/|/ or }\")"
      fi
   done < <(find "$l_directory" -mindepth 1 -type d -print0)
   if [ -z "$l_output2" ]; then
      if [ "$l_count" -gt "0" ]; then
         l_output=" - All directories in: \"$l_directory\" are owned by: \"${l_owner/|/ or }\""
      else
         l_output=" - No directories exist in: \"$l_directory\""
      fi
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