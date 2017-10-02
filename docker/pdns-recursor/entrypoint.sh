#!/bin/bash
set -e

# host_to_ip - Returns first resolved IP address
# Arguments:
#    $1 - Hostname to be resolved
function host_to_ip () {
    echo $(host -t A $1 | head -n 1 | rev | cut -d" " -f1  | rev)
}

# resolve_hosts - Resolves all hostnames given in placeholders (eg. ##google.com##) in the given file
# Arguments:
#    $1 - Filename
function resolve_hosts () {
    local host_placeholders=$(grep -ow -e "##[^#]*##" $1)
    
    for HOST in ${host_placeholders[@]}
    do
        sed -i -e "s/$HOST/$(host_to_ip $(sed -Ee 's/##(.*)##/\1/g' <<< $HOST))/g" $1 
    done
}

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
    esac
    shift
done

# Resolve hostnames to IPs in given configuration file placeholders
resolve_hosts $conf_file

exec pdns_recursor --daemon=no