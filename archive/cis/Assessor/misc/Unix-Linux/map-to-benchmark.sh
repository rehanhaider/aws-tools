#!/bin/bash

map_to_benchmark()
{
    l_os_name=$1
    l_os_version=$2

    CIS_CAT_BENCHMARK_DIRECTORY="${CISCAT_DIR}/benchmarks/"

    set_profiles()
    {
        filename=$1
        a_profiles=()
        while IFS= read -r l_benchmark_profile; do
            a_profiles+=("$(awk -F'.' '{print $3}' <<< "$l_benchmark_profile" | cut -d_ -f 3- | tr -d '<>"')")

        done < <(awk -F= '$1~/<xccdf:Profile/{print $2}' "$filename")

        if [ "${#a_profiles[@]}" -gt 2 ]; then
            PROFILE1="$(grep -Psi '\bLevel_1_-_Server\b' <<< "$(printf '%s\n' "${a_profiles[@]}")" | sed 's/_/ /g')"
            PROFILE2="$(grep -Psi '\bLevel_2_-_Server\b' <<< "$(printf '%s\n' "${a_profiles[@]}")" | sed 's/_/ /g')"
        else
            PROFILE1="$(grep -Psi -- '\bLevel_1(_?-?_Server)?\b' <<< "$(printf '%s\n' "${a_profiles[@]}")" | sed 's/_/ /g')"
            PROFILE2="$(grep -Psi -- '\bLevel_2(_?-?_Server)?\b' <<< "$(printf '%s\n' "${a_profiles[@]}")" | sed 's/_/ /g')"
        fi

    }

    find_matching_benchmark()
    {
        l_bm_name=$1
        while IFS= read -r -d $'\0' l_benchmark_file; do
            if grep -Psqio -- '^([^\n\r]+)?\/?CIS_'"$l_bm_name"'_([^\n\r]+)?Benchmark_v\d+\.\d+\.\d+(\.\d+)?-xccdf\.xml$' <<< "$l_benchmark_file"; then

                    BENCHMARK="$(basename "$l_benchmark_file")"
                    set_profiles $l_benchmark_file
            fi
        done < <(find ${CIS_CAT_BENCHMARK_DIRECTORY} -maxdepth 1 -type f -name '*-xccdf.xml' -and ! -name '*_STIG*' -print0 )

    }

        JAVA_FOLDER="Linux"
        case "$l_os_name" in
            azurelinux )
                osNameAndOsVersion="AKS_Optimized_Azure_Linux" ;;
            amzn )
                osNameAndOsVersion="Amazon_Linux_${l_os_version}" ;;
#            alinux )
#                osNameAndOsVersion="Aliyun_Linux" ;;
            almalinuxos | almalinux )
                osNameAndOsVersion="AlmaLinux_OS_${l_os_version}" ;;&
            centos )
                JAVA_FOLDER="CentOS"
                osNameAndOsVersion="CentOS_Linux_${l_os_version}" ;;
            darwin )
                JAVA_FOLDER="OSX"
                ARFORXML="-x"
                osNameAndOsVersion="Apple_macOS_${l_os_version}" ;;
            debian )
                JAVA_FOLDER="Debian"
                osNameAndOsVersion="Debian_Linux_${l_os_version}" ;;
#            linuxmint )
#                osNameAndOsVersion="Linux_Mint" ;;
            ol )
                osNameAndOsVersion="Oracle_Linux_${l_os_version}" ;;
            opensuse | sles )
                JAVA_FOLDER="SUSE"
                osNameAndOsVersion="SUSE_Linux_Enterprise_${l_os_version}" ;;&
            rhel )
                JAVA_FOLDER="RedHat"
                osNameAndOsVersion="Red_Hat_Enterprise_Linux_${l_os_version}" ;;

            rocky )
                osNameAndOsVersion="Rocky_Linux_${l_os_version}" ;;

            ubuntu )
                JAVA_FOLDER="Ubuntu"
                osNameAndOsVersion="Ubuntu_Linux_${l_os_version}.04" ;;
        esac

        find_matching_benchmark $osNameAndOsVersion
}


