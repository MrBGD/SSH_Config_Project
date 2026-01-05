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

if [[ -z "$file" ]]; then
    echo "Error: file not specified"
    exit 1
fi

if [[ ! -e "$file" ]]; then
    echo "Error: file not found"
    exit 1
fi

owner=$(stat -c '%U' "$file")
perms=$(stat -c '%a' "$file")

if [[ "$owner" != "root" ]]; then
    echo "[CRITICAL] File not owned by root!"
else
    echo "File owned by root"
fi

if [[ "$perms" -gt 644 ]]; then
    echo "Permissions are too permissive"
else
    echo "Permissions are secure"
fi

declare default_values
default_values=(
    ["AddressFamily"]="any"
    ["PasswordAuthentication"]="no"
    ["KbdInteractiveAuthentication"]="yes"
)
while read -r line; do
    
    if [[ -z "$line" ]]; then
        continue
    fi

    if [[ "$line" == \#* ]]; then
        if [[ "$line" == \#\ * ]]; then
    continue
        fi
    
        content="${line:1}"

        key=$(echo "$content" | awk '{print $1}')
        val=$(echo "$content" | awk '{print $2}')


        if [[ -n "${default_values[$key]}" ]]; then
            expected_default="${default_values[$key]}"

            if [[ "$val" == "$expected_default" ]]; then
                echo "$key = default"
            else 
                echo "$key is not default"
            fi
        fi  

    else
        key=$(echo "$line" | awk '{print $1}')
        val=$(echo "$line" | awk '{print $2}')
         if [[ -n "${default_values[$key]}" ]]; then
            expected_default="${default_values[$key]}"

            if [[ "$val" == "$expected_default" ]]; then
                echo "[FAIL] $key = default; redundant, should be commented"
            else 
                echo "[OK] $key is not default"
            fi
        fi  
    fi


done <$file