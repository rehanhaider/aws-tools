#!/usr/bin/env bash 
 
{ 
   a_output2=() a_output3=() l_dl="" l_mod_name="cramfs" l_mod_type="fs" 
   l_mod_path="$(readlink -f /lib/modules/**/kernel/$l_mod_type | sort -u)" 
   f_module_fix() 
   { 
      l_dl="y" a_showconfig=() 
      while IFS= read -r l_showconfig; do 
         a_showconfig+=("$l_showconfig") 
      done < <(modprobe --showconfig | grep -P -- 
'\b(install|blacklist)\h+'"${l_mod_chk_name//-/_}"'\b') 
      if  lsmod | grep "$l_mod_chk_name" &> /dev/null; then 
         a_output2+=(" - unloading kernel module: \"$l_mod_name\"") 
         modprobe -r "$l_mod_chk_name" 2>/dev/null; rmmod "$l_mod_name" 
2>/dev/null 
      fi 
      if ! grep -Pq -- '\binstall\h+'"${l_mod_chk_name//
/_}"'\h+(\/usr)?\/bin\/(true|false)\b' <<< "${a_showconfig[*]}"; then 
         a_output2+=(" - setting kernel  module: \"$l_mod_name\" to 
\"$(readlink -f /bin/false)\"") 
         printf '%s\n' "install $l_mod_chk_name $(readlink -f /bin/false)" >> 
/etc/modprobe.d/"$l_mod_name".conf 
      fi 
      if ! grep -Pq -- '\bblacklist\h+'"${l_mod_chk_name//-/_}"'\b' <<< 
"${a_showconfig[*]}"; then 
         a_output2+=(" - denylisting kernel module: \"$l_mod_name\"") 
         printf '%s\n' "blacklist $l_mod_chk_name" >> 
/etc/modprobe.d/"$l_mod_name".conf 
      fi 
   } 
   for l_mod_base_directory in $l_mod_path; do # Check if the module exists 
on the system 
      if [ -d "$l_mod_base_directory/${l_mod_name/-/\/}" ] && [ -n "$(ls -A 
"$l_mod_base_directory/${l_mod_name/-/\/}")" ]; then 
         a_output3+=("  - \"$l_mod_base_directory\"") 
         l_mod_chk_name="$l_mod_name" 
         [[ "$l_mod_name" =~ overlay ]] && l_mod_chk_name="${l_mod_name::-2}"         
         [ "$l_dl" != "y" ] && f_module_fix 
      else 
         printf '%s\n' " - kernel module: \"$l_mod_name\" doesn't exist in 
\"$l_mod_base_directory\"" 
      fi 
   done 
   [ "${#a_output3[@]}" -gt 0 ] && printf '%s\n' "" " -- INFO --" " - module: 
\"$l_mod_name\" exists in:" "${a_output3[@]}" 
   [ "${#a_output2[@]}" -gt 0 ] && printf '%s\n' "" "${a_output2[@]}" || 
printf '%s\n' "" " - No changes needed" 
   printf '%s\n' "" " - remediation of kernel module: \"$l_mod_name\" 
complete" "" 
}