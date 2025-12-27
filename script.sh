#!/bin/bash


file=$1

while read -r line; do

    case $line in
        *"Host "* )
            host=$(echo $line | awk '{print $2}')
            echo -e "\nThe name of the host: $host"
         ;;

         *"HostName "* )

            ip=$(echo $line | awk '{print $2}')
            if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                echo "Ip address of the host: $ip"
            elif [[ $ip =~ ^([a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\.)+[a-zA-Z]{2,}$ ]]; then
                echo "DNS address of the host: $ip"
            else
                echo "Invalid Ip address"

        
            fi
         ;;

         *"User "* )
            user=$(echo $line | awk '{print $2}')
            if [ -n "$user" ]; then
                echo "Host UserName: $user"
            else
                echo "Invalid UserName"

            fi
    
         ;;

         *"IdentityFile "* )
            path=$(echo $line | awk '{print $2}')
            if [ -n "$path" ]; then
                echo "Path of the private key: $path"
            else
                echo "Invalid path of the private key"
            fi
         ;;

          *"ServerAliveInterval "* )
            interval=$(echo $line | awk '{print $2}')
            if [[ $interval =~ ^[0-9]+$ ]]; then
                echo "ServerAliveInterval: $interval"
            else
                echo "Invalid interval(must be an integer)"
            fi
         ;;


         *"Port "* )
            port=$(echo $line | awk '{print $2}')
            if [[ $port =~ ^((6553[0-5])|(655[0-2][0-9])|(65[0-4][0-9]{2})|(6[0-4][0-9]{3})|([1-5][0-9]{4})|([0-5]{0,5})|([0-9]{1,4}))$ ]]; then
                echo "Computer port: $port"
            else
                echo "Invalid port"
            fi
         ;;

        

    esac 





done <$file

