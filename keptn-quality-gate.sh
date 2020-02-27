#!/bin/bash

# this script assumes you have the jq installed. https://github.com/stedolan/jq/wiki/Installation

# required parameters
if [ $# -lt 7 ]
then
  echo "ERROR: missing arguments."
  exit 1
fi

keptnApiUrl=$1        # e.g. https://api.keptn.<YOUR VALUE>.xip.io
keptnApiToken=$2
start=$3              # e.g. 2019-11-21T11:00:00.000Z
end=$4                # e.g. 2019-11-21T11:00:10.000Z
project=$5            # e.g. keptnorders
service=$6            # e.g. frontend
stage=$7              # e.g. staging

echo "================================================================="
echo "Keptn Quality Gate:"
echo ""
echo "keptnApiUrl = $keptnApiUrl"
echo "start       = $start"
echo "end         = $end"
echo "project     = $project"
echo "service     = $service"
echo "stage       = $stage"
echo "================================================================="

POST_DATA=$(cat <<EOF
{
  "data": {
    "start": "$start",
    "end": "$end",
    "project": "$project",
    "service": "$service",
    "stage": "$stage",
    "teststrategy": "manual"
  },
  "type": "sh.keptn.event.start-evaluation"
}
EOF
)

echo "Sending start Keptn Evaluation"
ctxid=$(curl -s -k -X POST --url "${keptnApiUrl}/v1/event" -H "Content-type: application/json" -H "x-token: ${keptnApiToken}" -d "$POST_DATA"|jq -r ".keptnContext")
echo "keptnContext ID = $ctxid"

loops=20
i=0
while [ $i -lt $loops ]
do
    i=`expr $i + 1`
    result=$(curl -s -k -X GET "${keptnApiUrl}/v1/event?keptnContext=${ctxid}&type=sh.keptn.events.evaluation-done" -H "accept: application/json" -H "x-token: ${keptnApiToken}")
    status=$(echo $result|jq -r ".data.evaluationdetails.result")
    if [ "$status" = "null" ]; then
      echo "Waiting for results (attempt $i of 20)..."
      sleep 5
    else
      break
    fi
done

echo "================================================================="
echo "eval status = ${status}"
echo "eval result = $(echo $result|jq)"
echo "================================================================="
if [ "$status" = "pass" ]; then
        echo "Keptn Quality Gate - Evaluation Succeeded"
else
        echo "Keptn Quality Gate - Evaluation failed!"
        echo "For details visit the Keptn Bridge!"
        exit 1
fi
