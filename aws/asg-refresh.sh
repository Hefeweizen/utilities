#!/usr/bin/env bash

# set -x

# state management
STATEDIR=~/.config/aws
STATEFILE="${STATEDIR}/instance_refresh"
mkdir -p ${STATEDIR}
if [[ ! -e ${STATEFILE} ]]; then
    cat >${STATEFILE} <<<"{}"
fi

function usage() {
    cat <<EOF
USAGE: ${0} [command]

Commands:
status        - report on previously started instance refresh [default]
start [ASG]   - start a refresh of an asg; picker provided if asg not specified

Note: when starting the instance refresh, we skip nodes that already use the desired launch_template
EOF
}

function start_refresh() {
    if [[ -n ${1} ]]; then
        # use provided asg
        target_asg="${1}"
    else
        # nothing specified; use picker
        target_asg=$(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[]".AutoScalingGroupName | jq -r '.[]' | fzf)
    fi

    if [[ -z ${target_asg} ]]; then
        # no selection; abort
        exit 1
    fi

    refresh_id=$(aws autoscaling start-instance-refresh --auto-scaling-group-name "${target_asg}" --preferences '{ "SkipMatching": true }' | jq -r '.InstanceRefreshId')

    cat >${STATEFILE} <<<"{ \"${target_asg}\": \"${refresh_id}\" }"
}

function status() {
    target_asg=$(jq -r 'keys | .[0]' "${STATEFILE}") # there should only ever be one, but return lexigraphical first otherwise -- https://jqlang.github.io/jq/manual/#keys-keys_unsorted
    refresh_id=$(jq -r --arg key "${target_asg}" '.[$key]' "${STATEFILE}")

    aws autoscaling describe-instance-refreshes --auto-scaling-group-name "${target_asg}" --instance-refresh-ids "${refresh_id}"
}

function asg-refresh ()
{
    if (( $# == 0 )); then
        # default scenario
        status
    else
        # interpret command
        case $1 in
            start)
                shift # pop `start` command
                start_refresh "$@"
                ;;
            status)
                status
                ;;
            *)
                usage
                ;;
        esac
    fi
}

asg-refresh "$@"
