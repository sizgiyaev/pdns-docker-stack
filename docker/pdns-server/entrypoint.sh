#!/bin/bash
set -e

# create_env_conf - Creates the PDNS conf file from environment variables
# Arguments:
#    $1 - The Configuration file path
function create_env_conf () {
    
    cat /dev/null > $1

    for var in $(env)
    do
        if [[ "${var,,}" == pdns_* ]]
        then

            key=$(cut -d '=' -f 1 <<< "${var,,}" | sed 's/^pdns_\(.*\)/\1/' | sed -r 's/_/-/g')
            value=$(cut -d '=' -f 2- <<< "${var}")

            echo "${key}=${value}" >> $1
        fi
    done
}

conf_file="/etc/powerdns/pdns.conf"
wait_for_timeout=5
wait_for_destination=()

while [[ $# -gt 0 ]]
do
    case $1 in
        -e|--env-conf)
            
            # Default config
            [[ -z $PDNS_SETUID ]] && export PDNS_SETUID=pdns
            [[ -z $PDNS_SETGID ]] && export PDNS_SETGID=pdns
            
            create_env_conf $conf_file
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

exec pdns_server