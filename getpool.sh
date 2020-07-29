#!/bin/bash

#Author: Naresh Padiyar
#Description: Bash Script To Display Node Health Status From F5 Load Balancer LTM Pool


F5_LTM_NODE=$1
F5_LTM_POOL=$2
F5_USER=$3
F5_PASSWORD=$4
F5_PORT=$5
shift 5;
POOL_MEMBERS=$*
WORKSPACE=`pwd`

function GET_POOL_DETAILS {

${WORKSPACE}/f5poolmembers.py --host=${F5_LTM_NODE} --username=${F5_USER} --password=${F5_PASSWORD} --poolname=${F5_LTM_POOL} | tail -2 | head -1 >${WORKSPACE}/POOL_DETAILS

}


function CONVERT_TO_JSON {

cat ${WORKSPACE}/POOL_DETAILS | sed s/u\'/\'/g | sed s/\'/\"/g >${WORKSPACE}/JSON_1
cat ${WORKSPACE}/JSON_1 | tr -d '.~?-' >${WORKSPACE}/JSON_2
cat ${WORKSPACE}/JSON_2 | sed s/https://g  | sed s/:443//g >${WORKSPACE}/JSON_3
cat ${WORKSPACE}/JSON_3 | tr -d '/%' >${WORKSPACE}/POOL_DETAILS.json
rm -f ${WORKSPACE}/POOL_DETAILS ${WORKSPACE}/JSON_1 ${WORKSPACE}/JSON_2 ${WORKSPACE}/JSON_3

}


function GET_DETAILS {

NODE_STATUS=`cat ${WORKSPACE}/POOL_DETAILS.json | ${WORKSPACE}/jq -c ."entries"."localhostmgmttmltmpool${JSON_POOL_NAME}membersCommon${JSON_POOL_NAME}stats"."nestedStats"."entries"."localhostmgmttmltmpool${JSON_POOL_NAME}membersCommon${JSON_POOL_NAME}membersstats"."nestedStats"."entries"."localhostmgmttmltmpool${JSON_POOL_NAME}membersCommon${JSON_POOL_NAME}membersCommon${POOL_MEMBER_IP}${F5_PORT}stats"."nestedStats"."entries"."statusenabledState" | cut -d ':' -f2 | tr -d '"{}'`
CONNECTION_COUNT=`cat ${WORKSPACE}/POOL_DETAILS.json | ${WORKSPACE}/jq -c ."entries"."localhostmgmttmltmpool${JSON_POOL_NAME}membersCommon${JSON_POOL_NAME}stats"."nestedStats"."entries"."localhostmgmttmltmpool${JSON_POOL_NAME}membersCommon${JSON_POOL_NAME}membersstats"."nestedStats"."entries"."localhostmgmttmltmpool${JSON_POOL_NAME}membersCommon${JSON_POOL_NAME}membersCommon${POOL_MEMBER_IP}${F5_PORT}stats"."nestedStats"."entries"."curSessions" | cut -d ':' -f2 | tr -d '"{}'`

echo -e "NODE $POOL_MEMBER"
echo -e "STATUS $NODE_STATUS"
echo -e "CONNECTION_COUNT $CONNECTION_COUNT"
}


GET_POOL_DETAILS

CONVERT_TO_JSON

for POOL_MEMBER in $POOL_MEMBERS; do

JSON_POOL_NAME=`echo $F5_LTM_POOL | tr -d '-' | tr -d '.'`
POOL_MEMBER_IP=`nslookup $POOL_MEMBER | tail -2 | head -1 | awk '{ print $2 }' | tr -d '.'`
echo -e "Fetching Details for $LTM_ENV Pool Member $POOL_MEMBER from Pool $LTM_POOL"

GET_DETAILS

rm -f ${WORKSPACE}/POOL_DETAILS.json

done
