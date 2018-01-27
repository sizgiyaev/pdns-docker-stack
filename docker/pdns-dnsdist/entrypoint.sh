#!/bin/bash
set -e

wait_for_timeout=5
wait_for_destination=()
service_user=_dnsdist

while [[ $# -gt 0 ]]
do
    case $1 in
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
        -u|--serivice-user)
            service_user=$2
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

exec dnsdist -g $service_user -u $service_user --supervised
