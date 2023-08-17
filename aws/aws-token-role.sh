#!/bin/bash

# Copyright (C) 2023 Hefeweizen (https://github.com/Hefeweizen)
# Permission to copy and modify is granted under the Apace License 2.0

#
# Authenticate to AWS with MFA, then assume role
#
# based on inital script from: https://gist.github.com/ogavrisevs/2debdcb96d3002a9cbf2
#
# when installing, cp to ~/bin, and then adust user_profile; and arn of mfa.
# Also make sure default_role_arn includes account number
#

# check that aws cli is installed
AWS_CLI=`which aws`

if [ $? -ne 0 ]; then
  echo "AWS CLI is not installed; exiting"
  exit 1
else
  echo "Using AWS CLI found at $AWS_CLI"
fi

if [ $# -ne 1 ]; then
  echo "Usage: $0  <MFA_TOKEN_CODE> <ROLE_ARN>"
  echo "Where:"
  echo "   <MFA_TOKEN_CODE> = Code from virtual MFA device"
  echo "   <ROLE_ARN> = Role arn to assume"
  exit 2
fi

AWS_USER_PROFILE=userName
AWS_2AUTH_PROFILE=2auth
ARN_OF_MFA=arn:aws:iam:::mfa/userName
MFA_TOKEN_CODE=$1
DEFAULT_ROLE_ARN='arn:aws:iam:::role/roleName'
ROLE_ARN=${2:-$DEFAULT_ROLE_ARN}
DURATION=43200 # 12 hours
SESSION_NAME=$(hostname)

echo "MFA ARN: $ARN_OF_MFA"
echo "MFA Token Code: $MFA_TOKEN_CODE"
# set -x

# First, auth with MFA device, gaining session token
read AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN <<< \
$( aws --profile $AWS_USER_PROFILE sts get-session-token \
  --duration $DURATION  \
  --serial-number $ARN_OF_MFA \
  --token-code $MFA_TOKEN_CODE \
  --output json  | \
  jq -r '.Credentials | "\(.AccessKeyId) \(.SecretAccessKey) \(.SessionToken)"')

# push these temp creds into environment for subsequent assume-role
export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN

# Second, use temp session creds to assume role; will get a "long-lasting" creds
read AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN <<< \
$( aws sts assume-role \
  --role-arn ${ROLE_ARN} \
  --role-session-name ${SESSION_NAME} \
  --output json  | \
  jq -r '.Credentials | "\(.AccessKeyId) \(.SecretAccessKey) \(.SessionToken)"')

aws --profile $AWS_2AUTH_PROFILE configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws --profile $AWS_2AUTH_PROFILE configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws --profile $AWS_2AUTH_PROFILE configure set aws_session_token "$AWS_SESSION_TOKEN"
