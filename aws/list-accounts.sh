#!/bin/bash


# after `aws sso login`
CACHE_FILE=$(ls -t ~/.aws/sso/cache/*.json | head -1)
ACCESS_TOKEN=$(cat "${CACHE_FILE}" | grep -o '"accessToken": "[^"]*' | cut -d '"' -f4)

# session alias
ACCT_SESSION_ALIAS=${1-tpay}

# echo ${ACCESS_TOKEN}

aws sso list-accounts --access-token ${ACCESS_TOKEN} --query 'accountList[].[accountId, accountName]' --output text | while read ACCOUNT_ID ACCOUNT_NAME; do

    ROLES=$(aws sso list-account-roles --access-token ${ACCESS_TOKEN} --account-id ${ACCOUNT_ID} --query 'roleList[].roleName' --output text)

    # [profile core-staging]
    # region=us-east-1
    # sso_session=tpay
    # sso_account_id=004618748470
    # sso_role_name=PowerUser
    # output=json
    for ROLE in ${ROLES}; do
        PROFILE_NAME=$(tr '[:upper:]' '[:lower:]' <<<"${ACCOUNT_NAME} ${ROLE}" | tr ' ' '_')
        cat <<EOF

[profile ${PROFILE_NAME}]
region=us-east-1
sso_session=${ACCT_SESSION_ALIAS}
sso_account_id=${ACCOUNT_ID}
sso_role_name=${ROLE}
output=json
EOF
    done
done
