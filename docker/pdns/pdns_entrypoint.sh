#!/bin/bash

# Parameters for the script:
#   -a, --application       Application to run (eg. pdns_server, pdns_recursor)
#   -p, --parameters-file   File that contains all valid application parameters
#   -c, --config-file       Config file path, if not specified, the application will use it's default location
#   -e, --env-conf          Build config file for environment variables

# create_env_conf - Creates the PDNS conf file from environment variables and validates the parameter names
# Arguments:
#    $1 - The file with the list of all possible parameters
#    $2 - The Configuration file path
function create_env_conf () {
    
    pdns_valid_params=()
   
    # Load valid parameters
    while read param
    do
        pdns_valid_params+=("$param")
    done < $1
    
    cat /dev/null > $2

    for var in $(env)
    do
        if [[ "${var,,}" == pdns_* ]]
        then
            param=$(cut -d '=' -f 1 <<< ${var,,} | sed 's/^pdns_\(.*\)/\1/' | sed -r 's/_/-/g')
            if [[ " ${pdns_valid_params[*]} " == *" $param "* ]]
            then
                echo "$param=$(cut -d '=' -f 2 <<< ${var,,})" >> $2 
            else
                echo "The PDNS parameters $param is not valid!" # make it formated well
            fi
        fi
    done
}

use_env=0
app=""
param_file="valid_params.list"
conf_file=""

while [[ $# -gt 1 ]]
do
    case $1 in
        -a | --application)
        app=$2
        shift
        ;;
     
        -p | --parameters-file)
        param_file=$2
        shift
        ;;

        -c | --config-file)
        conf_file=$2
        shift
        ;;
        
        -e | --env-conf)
            use_env=1
        ;;
        *)

        ;;
    esac
    shift
done

if [[ $app == "" ]]
then
    echo "The application is not specified"
    exit 1
fi

if [ $use_env -eq 1 ]
then
    create_env_conf $params_file $conf_file
fi

exec $app