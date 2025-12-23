#!/bin/bash


file=$1

while read -r line; do

    case $line in
        *"Host "* )
            host=$(echo $line | awk '{print $2}')
            echo -e '\nThe name of the host: $host'
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


    esac 





done <$file

