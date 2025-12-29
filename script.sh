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
                              \______|                                                       \______|                                                
                                                                                                                                                     
                                                                                                                                                     '



critical_info()
{
    [ -z "$host" ] && return

    if [[ has_hostname == false ]]; then
        echo "CRITICAL! No hostname found in $host" 
    elif [[ has_user == false ]]; then
        echo "Warning! No user found in $host. Default value, "$PWD" will be used." 
    fi
}

default_user="$(whoami)"
declare CRITICAL_KEY
declare critic
declare all_valid
declare -a target_hosts # asta e un array cu toate hosturile disponibile mai putin *
declare -A default_config # configu default din * (daca exista)
declare -a default_keys # valorile din configu *
declare -A config # un array temporar unde se salveaza info de la fiecare host

get_config_block() {
    cat "$file" | tr -d '\r' | sed 's/^[ \t]*$//' | \
    awk -v target="$1" 'BEGIN {RS=""} $1 == "Host" && $2 == target {print; exit}'
}

validate_ip_or_dns()
{
    if [[ ! $1 =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]] && [[ ! $1 =~ ^([a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\.)+[a-zA-Z]{2,}$ ]]; then
        echo "CRITICAL! Invalid/Missing IP or DNS address in $2"
        all_valid=false

    fi

}

parse_block() {
    local content="$1"
    local -n config_map=$2  
    local host_name="$3"
    while read -r line; do
        [[ -z "$line" || "$line" =~ ^# || "$line" == "Host $host_name" ]] && continue
        key=$(echo "$line" | awk '{print $1}')
        val=$(echo "$line" | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')
        if [[ -n "$key" ]]; then
            config_map["$key"]="$val"
        fi
    done <<< "$content"
}

if [[ ! -e "$file" ]]; then
    echo "No file provided! Usage of the script: ./script.sh <ssh_config_file>. Quiting..."
    exit
fi


default_data=$(get_config_block "*")
parse_block "$default_data" default_config "*"

for key in "${!default_config[@]}"; do
    default_keys+="$key "
done

if [[ "${!default_config[@]}" =~ "HostName" ]]; then
    if [[ "${default_config["HostName"]}" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then
        echo "Default Ip address of the host: ${default_config["HostName"]}"
        CRITICAL_KEY=""
        critic=false

    elif [[ "${default_config["HostName"]}" =~ ^([a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\.)+[a-zA-Z]{2,}$ ]]; then
        echo "Default DNS address of the host: ${default_config["HostName"]}"
        CRITICAL_KEY=""
        critic=false
    fi    
else
    CRITICAL_KEY="HostName"
    critic=true
fi
if [[ "${!default_config[@]}" =~ "User" ]]; then
    default_user=${default_config[@]}
fi

mapfile -t target_hosts < <(awk '$1 == "Host" && $2 != "*" {print $2}' "$file")


for host in "${target_hosts[@]}"; do
    all_valid=true
    unset config
    declare -A config
    host_data=$(get_config_block "$host")
    parse_block "$host_data" config "$host"
    if $critic; then
        validate_ip_or_dns "${config["$CRITICAL_KEY"]}" "$host"
    fi

    #inca mai trb verificate chestii
    if $all_valid; then
        echo -e "\n[OK] Configuration for $host is stable and ready to go"
    else
        echo -e "Configuration is incomplete for $host, check the errors\n"
    fi
      
done
