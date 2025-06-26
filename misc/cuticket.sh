#!/opt/homebrew/bin/bash

# Presumed to be set in env
# CLICKUP_API_KEY=
# CLICKUP_TEAM_ID=

CLICKUP_DEFAULT_LIST="901407545296"
CLICKUP_USER_ID_ME="88262838"

TICKET_TITLE=${1}
TICKET_DESC=${2}
DEFAULT_STATUS="in progress"

function create_ticket {
    if [[ -z ${TICKET_DESC} ]] || [[ ${TICKET_DESC} == "" ]]; then
        description=${TICKET_TITLE}
    else
        description=${TICKET_DESC}
    fi

    curl \
        -s \
        --url "https://api.clickup.com/api/v2/list/${CLICKUP_DEFAULT_LIST}/task?custom_task_ids=true&team_id=${CLICKUP_TEAM_ID}" \
        --request POST \
        --header "Authorization: ${CLICKUP_API_KEY}" \
        --header 'accept: application/json' \
        --header 'content-type: application/json' \
        --data @- <<EOT | jq -r '.id'
{
    "name": "${TICKET_TITLE}",
    "description": "${description}",
    "assignees": ["${CLICKUP_USER_ID_ME}"],
    "status": "${DEFAULT_STATUS}"
}
EOT
}

function lookup_custom_id {
    TASK_ID=${1}

    curl \
        -s \
        --url "https://api.clickup.com/api/v2/task/${TASK_ID}?team_id=${CLICKUP_TEAM_ID}" \
        --request GET \
        --header "Authorization: ${CLICKUP_API_KEY}" \
        --header 'accept: application/json' | jq -r '.custom_id'
}

function wrap_custom_id_inurl {
    CUSTOM_ID=${1}

    echo "https://app.clickup.com/t/${CLICKUP_TEAM_ID}/${CUSTOM_ID}"
}


TASK_ID=$(create_ticket)
echo $(wrap_custom_id_inurl $(lookup_custom_id ${TASK_ID}))
