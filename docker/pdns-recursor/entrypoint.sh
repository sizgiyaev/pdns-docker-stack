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
            IFS='=' read -r -a param <<< "${var,,}"
            echo "$(cut -d '=' -f 1 <<< ${param[0]} | sed 's/^pdns_\(.*\)/\1/' | sed -r 's/_/-/g')=${param[1]}" >> $1
        fi
    done
}

conf_file="/etc/powerdns/recursor.conf"

while [[ $# -gt 0 ]]
do
    case $1 in
        -e|--env-conf)

            # Default config
            [[ -z $PDNS_SETUID ]] && export PDNS_SETUID=pdns
            [[ -z $PDNS_SETGID ]] && export PDNS_SETGID=pdns
    
            create_env_conf $conf_file
        ;;
        *)

        ;;
    esac
    shift
done

exec pdns_recursor --daemon=no