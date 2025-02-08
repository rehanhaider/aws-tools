#!/usr/bin/env bash

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# R. DARUSZKA  12/19/17   Ensure there is an active auditd config for all privileged commands
# R. DARUSZKA  03/28/17   Fix issue with command not working in all shells
# B. Munyan    02/04/19   Unix line endings
# E. Pinnell   08/28/19   Modified script to detect uid of the system (Some are 500 newer systems are 1000)
# E. Pinnell   02/10/20   Modified to allow for any key value 
# E. Pinnell   03/12/20   Modified to make "-S all " optional in output in awk print
# E. Pinnell   02/23/24   Modified to fix fragile for loop over find, better align with Prose, improve output

# Set variables
l_output="" l_output2="" l_out2="" l_running_config=""
a_option_check=("-a\h+(always,exit|exit,always)" "-F\h+perm=x" "-F\h+auid>=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)" "-F\h+auid!=(unset|-1|4294967295)")

# auditd rules check function
f_auditd_rules_chk()
{
  if [ -n "$l_check_line" ]; then
   for l_option_check in "${a_option_check[@]}"; do
      if ! grep -Pq -- "$l_option_check" <<< "$l_check_line"; then
         l_out2="$l_out2\n  - option: \"$l_option_check\" is missing"
      fi
   done
  else
    l_out2="$l_out2\n  - auditd rule doesn't exist in $l_check_type"
  fi
}

# Check for auditctl status
f_auditctl_chk()
{
  l_running_config=""
  if command -v auditctl &>/dev/null; then
    # Build array with auditd rules in the running config (run once instead of multiple times)
    a_auditd_rule=()
    while IFS= read -r l_auditd_rule; do
      [ -n "$l_auditd_rule" ] && a_auditd_rule+=("$l_auditd_rule")
    done < <(auditctl -l)
    if (( "${#a_auditd_rule[@]}" != 0 )); then
      l_running_config="Y"
    else
      l_running_config="  - No rules are loaded in the auditd running configuration"
    fi
  else
    l_running_config="  - auditctl command not found on the system"
  fi
}

# Main check script
[ -z "$l_running_config" ] && f_auditctl_chk
if [ "$l_running_config" = "Y" ]; then
   #Build privileged files path exclusion array
   a_path=(! -path \"/run/user/*\")
   while IFS= read -r l_exclude_path; do
      a_path+=( -a ! -path \""$l_exclude_path"/*\")
   done < <(findmnt -krn | awk '/(noexec|nodev)/{print $1}')
   # Check if rule exists for file
   while IFS= read -r -d $'\0' l_file; do
      l_out2=""
      l_check_type="the auditd running configuration"
      l_check_line="$(awk '/path='"${l_file//\//\\/}"'/{print}' <<< "${a_auditd_rule[@]}" 2>/dev/null)"
      f_auditd_rules_chk
      # Create output for file
      if [ -n "$l_out2" ]; then
         l_output2="$l_output2\n - Privileged file: \"$l_file\":$l_out2\n"
      else
         l_output="$l_output\n - Privileged file: \"$l_file\"\n  - auditd rule exists in the running configuration\n"
      fi
   done < <(find / \( "${a_path[@]}" \) \( -perm -4000 -o -perm -2000 \) -type f -print0 2> /dev/null)
else
   l_output2="$l_output2\n$l_running_config"
fi

# Send output to CIS-CAT and exit
if [ -z "$l_output2" ]; then
  echo -e "\n- Audit Result:\n  ** PASS **\n - * Correctly configured * :$l_output"
  exit "${XCCDF_RESULT_PASS:-101}"
else
  echo -e "\n- Audit Result:\n  ** FAIL **\n - * Reasons for audit failure * :$l_output2\n"
  [ -n "$l_output" ] && echo -e "\n - * Correctly configured * :\n$l_output\n"
  exit "${XCCDF_RESULT_FAIL:-102}"
fi
