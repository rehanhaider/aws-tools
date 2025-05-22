#!/bin/bash

detect_os_variant()
{
    if command -v uname &>/dev/null; then
       l_os_type="$(uname -s)"
       case "${l_os_type,,}" in
          linux )
             l_os_name="$(awk -F= '{IGNORECASE=1; if ($1=="ID") print tolower($2)}' /etc/os-release | tr -d '"')"
             l_os_version="$(awk -F= '($1=="VERSION_ID") {split($2,a,".");print a[1]}' /etc/os-release | tr -d '"')"
             ;;
          darwin )
             l_os_name="$(SW_VERS | awk '{IGNORECASE=1; if ($1=="ProductName:") print tolower($2)}')"
             l_os_vfull="$(SW_VERS | awk '{IGNORECASE=1; if ($1=="ProductVersion:") {split($2,a,".");print a[1]"."a[2]}')"
             l_os_version="$(cut -d. -f1 <<< "$l_os_vfull")"
             if [ "$l_os_version" -le "10" ]; then
                l_os_version="$l_os_vfull"
             else
                l_os_version="$l_os_version.0"
             fi
             ;;
       esac

        DISTRO=${l_os_name,,}
        VER=$l_os_version

    fi
    if [[ ! -v l_os_name ]]; then
#         when invoked with no option, `uname` assumes -s
        case `uname` in
            Linux)
                operatingSystem=`hostnamectl | grep "Operating System"`
                echo ${operatingSystem}
                if [ ! -z "${operatingSystem}" ]
                then
                    case ${operatingSystem} in
                            *"Ubuntu"*)
                    esac
            ### Oracle ###
                elif [ -f /etc/oracle-release ]
                then
                    DISTRO='Oracle'
                    VER=`egrep -o "([[:digit:]]\.?)+" /etc/oracle-release`

                    grep -q "Server" /etc/oracle-release
                    if [ $? -eq 0 ]
                    then
                            ROLE="Server"
                    else
                            ROLE="Workstation"
                    fi

            ### RedHat and variants ###
                elif [ -f /etc/redhat-release ]
                then
                    case `awk {'print $1'} /etc/redhat-release` in
                        Red)
                                DISTRO='RedHat' ;;
                        CentOS)
                                DISTRO='CentOS' ;;
                        Aliyun)
                                DISTRO='Aliyun' ;; ### Alibaba ###
                    esac
                    VER=`egrep -o "([[:digit:]]\.?)+" /etc/redhat-release`

                    grep -q "Server" /etc/redhat-release
                    if [ $? -eq 0 ]
                    then
                      ROLE="Server"
                    else
                      ROLE="Workstation"
                    fi

            ### SuSE and variants ###
                elif [ -f /etc/SuSE-release ]
                then
                    DISTRO='SUSE'
                    VER=`grep VERSION /etc/SuSE-release | awk '{print $NF}'`.`grep PATCHLEVEL /etc/SuSE-release | awk '{print $NF}'`
                    #VER=`grep VERSION /etc/SuSE-release | awk '{print $NF}'`

                ### SuSE 15 ###
                elif [[ `grep "ID_LIKE=.*" /etc/os-release | grep -o '".*"' | sed 's/"//g'` == "suse" ]]
                then
                    DISTRO='SUSE'
                    VER=`egrep "VERSION_ID=.*" /etc/os-release | egrep -o "([[:digit:]]\.?)+"`

    ### Debian and variants ###
                elif [ -f /etc/debian_version ]
                then
                    DISTRO='Debian'
                    VER=`egrep -o "([[:digit:]]\.?)+" /etc/debian_version`


                    # Ubuntu appears to not use numbers...
                    if [ ! $VER ]
                    then
                            DISTRO='Ubuntu'
                            VER=`egrep "VERSION_ID=.*" /etc/os-release | egrep -o "([[:digit:]]\.?)+"`
                    fi
                else
                    DISTRO='Linux'
                fi
            ;;
            ### Mac OS ###
            Darwin)
                DISTRO='OSX'
                VER=`uname -r`
            ;;

        esac
        fi

}

#detect_os_variant
