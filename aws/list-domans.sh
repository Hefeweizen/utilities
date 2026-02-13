#!/bin/bash


function prefix () { 
    prefix="${1:-prefix}"
    awk -v cl=${prefix} '{print cl " " $0}'
}


acct=$(aws sts get-caller-identity | jq -r '.Account')

for zone in $(aws route53 list-hosted-zones --query 'HostedZones[*].Id' --output text); do
    
    aws route53 list-resource-record-sets \
        --hosted-zone-id ${zone} \
        --query "ResourceRecordSets[*].{Name:Name, Type:Type}" \
        --output text |\
    prefix ${acct}

done
