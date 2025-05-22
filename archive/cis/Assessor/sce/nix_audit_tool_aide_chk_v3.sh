#!/usr/bin/env bash

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   06/17/24   Check cryptographic mechanisms are used to protect the integrity of audit tools
# E. Pinnell   11/15/24   Modified to replace whereis with more reliable test

# Note: supersedes deprecated nix_audit_tool_aide_chk_v2.sh

# Setup output arrays, auditd tools to look for
a_output=();a_output2=();a_output3=();a_parlist=()
l_systemd_analyze="$(whereis systemd-analyze | awk '{print $2}')"
a_audit_files=("auditctl" "auditd" "ausearch" "aureport" "autrace" "augenrules")

# Function to check if all options a included
f_parameter_chk()
{
   for l_tool_file in "${a_parlist[@]}"; do
      if grep -Pq -- '\b'"$l_tool_file"'\b' <<< "${!A_out[*]}"; then
         for l_string in "${!A_out[@]}"; do
            l_check="$(grep -Po -- '^\h*(\/usr)?\/sbin\/'"$l_tool_file"'\b' <<< "$l_string")"
            if [ -n "$l_check" ]; then
               l_fname="$(printf '%s' "${A_out[$l_string]}")"
               [ "$l_check" != "$(readlink -f "$l_check")" ] && \
               a_output3+=("  - \"$l_check\" should be updated to: \"$(readlink -f "$l_check")\"" "    in: \"$l_fname\"")
               a_missing=()
               for l_var in "${a_items[@]}"; do
                  if ! grep -Pq -- "\b$l_var\b" <<< "$l_string"; then
                     a_missing+=("\"$l_var\"")
                  fi
               done
               if [ "${#a_missing[@]}" -gt 0 ]; then
                  a_output2+=(" - Option(s): ( ${a_missing[*]} ) are missing from: \"$l_tool_file\" in: \"$l_fname\"")
               else
                  a_output+=(" - Audit tool file \"$l_tool_file\" exists as:" "   \"$l_string\"" "   in the configuration file: \"$l_fname\"")
               fi
            fi
         done
      else
         a_output2+=(" - Audit tool file \"$l_tool_file\" doesn't exist in an AIDE configuration file")
      fi
   done
}

# Function to create array with "winning" configuration information
f_aide_conf()
{
#   l_config_file="$(whereis aide.conf | awk '{print $2}')"
   l_config_file="$(readlink -f /etc/aide/aide.conf)" || l_config_file="/etc/aide.conf"
   if [ -f "$l_config_file" ]; then
      a_items=("p" "i" "n" "u" "g" "s" "b" "acl" "xattrs" "sha512")
      declare -A A_out
      while IFS= read -r l_out; do
         if grep -Pq -- '^\h*\#\h*\/[^#\n\r]+\.conf\b' <<< "$l_out"; then
            l_file="${l_out//# /}"
         else
            for i in "${a_parlist[@]}"; do
               grep -Pq -- '^\h*(\/usr)?\/sbin\/'"$i"'\b' <<< "$l_out" && A_out+=(["$l_out"]="$l_file")
            done
         fi
      done < <("$l_systemd_analyze" cat-config "$l_config_file" | grep -Pio '^\h*([^#\n\r]+|#\h*\/[^#\n\r\h]+\.conf\b)')
      if [ "${#A_out[@]}" -gt 0 ]; then
         f_parameter_chk
      else
         a_output2+=(" - No audit tool files are configured in an AIDE configuration file")
      fi
   else
      a_output2+=(" - AIDE configuration file not found." "   Please verify AIDE is installed on the system")
   fi
}

# Loop to only look at auditd tools that exist on the system
for l_audit_file in "${a_audit_files[@]}"; do
   if [ -f "$(readlink -f "/sbin/$l_audit_file")" ]; then
      a_parlist+=("$l_audit_file")
   else
      a_output+=(" - Audit tool file \"$(readlink -f "/sbin/$l_audit_file")\" doesn't exist")
   fi
done
[ "${#a_parlist[@]}" -gt 0 ] && f_aide_conf

# Determine Pass/Fail state and provide output
if [ "${#a_output2[@]}" -le 0 ]; then
   printf '%s\n' "" "- Audit Result:" "  ** PASS **" "${a_output[@]}"
   [ "${#a_output3[@]}" -gt 0 ] && printf '%s\n' "" "  ** WARNING **" "${a_output3[@]}"
   exit "${XCCDF_RESULT_PASS:-101}"
else
   printf '%s\n' "" "- Audit Result:" "  ** FAIL **" "  * Reasons for audit failure *" "${a_output2[@]}" ""
   [ "${#a_output3[@]}" -gt 0 ] && printf '%s\n' "" "  ** WARNING **" "${a_output3[@]}"
   [ "${#a_output[@]}" -gt 0 ] && printf '%s\n' "- Correctly set:" "${a_output[@]}"
   exit "${XCCDF_RESULT_FAIL:-102}"
fi