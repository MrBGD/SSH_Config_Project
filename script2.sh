#!/bin/bash

file=$1

echo ' $$$$$$\   $$$$$$\  $$\   $$\        $$$$$$\   $$$$$$\  $$\   $$\ $$$$$$$$\ $$$$$$\  $$$$$$\        $$$$$$\  $$\   $$\ $$$$$$$$\  $$$$$$\  $$\   $$\ 
$$  __$$\ $$  __$$\ $$ |  $$ |      $$  __$$\ $$  __$$\ $$$\  $$ |$$  _____|\_$$  _|$$  __$$\      $$  __$$\ $$ |  $$ |$$  _____|$$  __$$\ $$ | $$  |
$$ /  \__|$$ /  \__|$$ |  $$ |      $$ /  \__|$$ /  $$ |$$$$\ $$ |$$ |        $$ |  $$ /  \__|     $$ /  \__|$$ |  $$ |$$ |      $$ /  \__|$$ |$$  / 
\$$$$$$\  \$$$$$$\  $$$$$$$$ |      $$ |      $$ |  $$ |$$ $$\$$ |$$$$$\      $$ |  $$ |$$$$\      $$ |      $$$$$$$$ |$$$$$\    $$ |      $$$$$  /  
 \____$$\  \____$$\ $$  __$$ |      $$ |      $$ |  $$ |$$ \$$$$ |$$  __|     $$ |  $$ |\_$$ |     $$ |      $$  __$$ |$$  __|   $$ |      $$  $$<   
$$\   $$ |$$\   $$ |$$ |  $$ |      $$ |  $$\ $$ |  $$ |$$ |\$$$ |$$ |        $$ |  $$ |  $$ |     $$ |  $$\ $$ |  $$ |$$ |      $$ |  $$\ $$ |\$$\  
\$$$$$$  |\$$$$$$  |$$ |  $$ |      \$$$$$$  | $$$$$$  |$$ | \$$ |$$ |      $$$$$$\ \$$$$$$  |     \$$$$$$  |$$ |  $$ |$$$$$$$$\ \$$$$$$  |$$ | \$$\ 
 \______/  \______/ \__|  \__|$$$$$$\\______/  \______/ \__|  \__|\__|      \______| \______/$$$$$$\\______/ \__|  \__|\________| \______/ \__|  \__|
                              \______|                                                       \______|                                                '

if [[ ! -e "$file" ]]; then
    echo "No file provided! Usage of the script: ./script.sh <sshd_config_file>. Quiting..."
    exit
fi

permission_octal=$(stat -c "%a" $1)
owner=$(stat -c "%U" $1)

if [[ $owner != "root" ]]; then
    echo "Owner of the file is $owner! It should be root!"
fi

if [[ $permission_octal -gt 644 ]]; then
    echo "Check permissions, some users may have more access to the file than needed!"
fi
# if [[ $EUID -ne 0 ]]; then
#    echo "This script must be run as root to check sshd" 
#    exit 1
# fi

# declare -A default_array
declare -A seen_setting
declare -A security_settings=(
    [passwordauthentication]="no"
    [publickeyauthentication]="yes"
    [clientaliveinterval]="60"
    [clientalivecountmax]="3"
    #[port]="" diferit de 22
    [permitrootlogin]="no"
    [permitemptypasswords]="no"
    [protocol]="2"
)
declare -A whitelist=(
    [listenaddress]="true"
    [hostkey]="true"
)

status_file="true"

verify_duplicate_overwriting()
{
    local content=$1
    local content_value=$2
    if [[ -n "${whitelist["$content"]}" ]]; then
        return
    fi
    

    if [[ -n "${seen_setting["$content"]}" ]];then
        prev_value="${seen_setting["$content"]}" #prev value e folosit ca un auxiliar (mai usor la explicat)
        if [[ "$content_value" == "$prev_value" ]]; then
            echo "duplicate la ${seen_setting["$content"]} in $content_value"
            status_file="false"
        else
            echo "overwrite la ${seen_setting["$content"]} in $content_value"
            status_file="false"
        fi
    else
        seen_setting["$content"]="$content_value"
    fi

}

check_security_policy() {
    local content=$1
    local content_value=$2
    if [[ -n "${security_settings[$content]}" ]]; then
        expected="${security_settings[$content]}"
        if [[ "$content_value" != "$expected" ]]; then
            echo " $content is '$content_value', but policy requires '$expected'."
            status_file="security"
        fi
    fi

}

# big_settings="$(sudo sshd -T)"


# while read -r line; do
#     key=$(echo "$line" | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
#     val=$(echo "$line" | awk '{print $2}' | tr '[:upper:]' '[:lower:]')

#     if [[ -n "$key" ]]; then
#         default_array["$key"]="$val"
#     fi
# done <<< "$big_settings"





while read -r line; 
do
    if [[ -z "$line" ]]; then
        continue
    fi
    if [[ "$line" != \#\ * ]]; then
        setting=$(echo "$line" | awk '{print $1}' | tr '[:upper:]' '[:lower:]' )
        setting_value=$(echo "$line" | awk '{print $2}' | tr '[:upper:]' '[:lower:]')

        if [[ ${setting:0:1} == "#" ]]; then
            setting=${setting:1}
            verify_duplicate_overwriting "$setting" "$setting_value"
            # ??? check_security_policy "$setting" "$setting_value" ????
            # if [[ "$setting_value" != "${default_array["$setting"]}" ]]; then
            #     echo "warning, decomenteaza linia pentru setarea $setting"
            #     status_file=false
            # fi
        else
            verify_duplicate_overwriting "$setting" "$setting_value"
            check_security_policy "$setting" "$setting_value"
            # if [[ "$setting_value" == "${default_array["$setting"]}" ]]; then
            #     echo "warning comenteaza linia pentru setarea $setting"
            #     status_file=false
            # fi
        fi

    fi
    if [[ "$setting" == "match" ]]; then
        break
    fi
   

done < $file


if [[ -z "${seen_setting["port"]}" ]]; then
        echo "Port is not explicitly defined (Defaults to 22)."
        status_file="security"
elif [[ "${seen_setting["port"]}" == "22" ]]; then
        echo "Port is set to 22, change it to another value greater than 1024."
        status_file="security"
fi



if [[ "$status_file" == "true" ]] ; then
    echo "The file is ready to go"
elif [[ "$status_file" == "security" ]] ; then
    echo -e "\nCheck the recomandations before using the ssh!"
elif [[ "$status_file" == "false" ]] ; then
    echo -e "\nWarning! Modify the settings!"
fi
