#!/bin/bash

# https://www.dynatrace.com/support/help/dynatrace-api/environment-api/events-v2/post-event
# expects DT_BASEURL & DT_API_TOKEN to be set
# export DT_BASEURL=[YOUR URL]
# export DT_API_TOKEN=[YOUR API TOKEN]

TITLE=$1
EVENT_TYPE=$2
ENTITY_SELECTOR=$3

# exampleentity selector
# type(SERVICE),tag(keptn_project:casdemo,keptn_service:casdemoapp,keptn_stage:production)
# type(SERVICE),entityName.equals(BookingService)
# type(HOST),fromRelationship.isInstanceOf(type(HOST_GROUP),entityName(cloud-burst-hosts))

# event types
# AVAILABILITY_EVENT
# CUSTOM_ALERT
# CUSTOM_ANNOTATION
# CUSTOM_CONFIGURATION
# CUSTOM_DEPLOYMENT
# CUSTOM_INFO
# ERROR_EVENT
# MARKED_FOR_TERMINATION
# PERFORMANCE_EVENT
# RESOURCE_CONTENTION_EVENT

# can also pass in 
# startTime
# endTime

PAYLOAD='
{
  "title": "'$TITLE'",
  "eventType": "'$EVENT_TYPE'",
  "entitySelector": "'$ENTITY_SELECTOR'",
  "properties":{
    "Triggered by": "Demo Script"
  }
}
'
echo "=============================================================="
echo "SENDING THE FOLLOWING HTTP PAYLOAD TO "
echo "  $DT_BASEURL/api/v2/events/ingest"
echo "=============================================================="
echo $PAYLOAD
echo "=============================================================="
curl -s -X POST \
          "$DT_BASEURL/api/v2/events/ingest" \
          -H 'accept: application/json; charset=utf-8' \
          -H "Authorization: Api-Token $DT_API_TOKEN" \
          -H 'Content-Type: application/json; charset=utf-8' \
          -d "$PAYLOAD" \
          -o curloutput.txt

echo "API RESPONSE:"
echo "=============================================================="
echo ""
cat curloutput.txt
