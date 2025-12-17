file=$1

while read -r line; do

    case $line in
        *"Host "* )
            y=$(echo $line | awk '{print $2}')
            echo "The name of the host: $y"
         ;;
    esac 





done <$file

