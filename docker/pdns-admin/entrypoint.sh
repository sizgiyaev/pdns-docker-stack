#!/bin/bash
set -e

WWW_ROOT=/var/www/html

export POWERADMIN_SESSION_KEY=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)

function update_env_conf () {
    
    cp -f /var/www/html/inc/config-me.inc.php $1

    for var in $(env)
    do
        if [[ "${var,,}" == poweradmin_* ]]
        then
            IFS='=' read -r key value <<< "${var}"
        
            key=$(sed 's/^poweradmin_\(.*\)/\1/' <<< ${key,,})
        
            # Escape / and \ symbols for future sed processing
            value=$(sed -r "s/\//\\\\\//g;s/\\\([^\/])/\\\&/g" <<< $value)
        
            sed -i -re "s/(\/\/)?\s*([\x24]$key\s*=\s*'?)[^('|;)]*(.*$)/\2$value\3/g" $1
        fi
    done
}

conf_file="${WWW_ROOT}/inc/config.inc.php"

wait_for_timeout=5
wait_for_destination=()

while [[ $# -gt 0 ]]
do
    case $1 in
        -e|--env-conf)
            update_env_conf $conf_file
        ;;
        -w|--wait-for)
            IFS=':' read -r -a wait_for_destination <<< $2
            if [[ ${#wait_for_destination[@]} -ne 2 ]]
            then
                echo "$(date '+%b %d %Y %H:%M:%S') entrypoint:[ERROR] wait-for destination is wrong."
                exit 1
            fi
            shift
        ;;
        -t|--wait-for-timeout)
            if [[ $2 =~ ^[0-9]+$ ]]
            then
                wait_for_timeout=$2
            else
                echo "$(date '+%b %d %Y %H:%M:%S') entrypoint:[ERROR] wait-for-timeout must be a number of seconds."
                exit 1
            fi
            shift
        ;;
        *)

        ;;
    esac
    shift
done

while [[ $(nc -z ${wait_for_destination[@]} &>/dev/null && echo $?) != "0" ]] && \
        [[ $wait_for_timeout -gt 0 ]] && \
        [[ ${#wait_for_destination[@]} -ne 0 ]]
do
    [[ -z $info ]] && echo "$(date '+%b %d %Y %H:%M:%S') entrypoint:[INFO] Waiting $wait_for_timeout seconds for ${wait_for_destination[0]} to become available..."; info=yes
    sleep 1
    (( wait_for_timeout-- ))
done <<< $info

php /tmp/add_mysql_tables.php users /tmp/poweradmin_mysql.sql
rm -f /tmp/add_mysql_tables.php /tmp/poweradmin_mysql.sql

exec apache2ctl -D FOREGROUND