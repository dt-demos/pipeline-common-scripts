# Unix Shell script to send an create Dynatrace deployment API call 
# Assumes that will tag entities with an "environment" and "service" TAG
# arguments
# $1 = dynatrace-base-url, eg. http://<tenant>.live.dynatrace.com
# $2 = dynatrace-api-token
# $3 = release name that shows up in the dyntrace event
# $4 = dynatrace-api-token
# $5 = dynatrace-api-token
# $6 = dynatrace-api-token
# $7 = tag-value-environment
# $8 = tag-value-service
# in AzureDev Ops pilelines can use built in environment variables
# "$(dynatrace-base-url)" "$(dynatrace-api-token)" $(Build.DefinitionName) $(app-problem-number) $(System.TeamProject) $(System.TeamFoundationCollectionUri)/$(System.TeamProject)/_build/results?buildId=$(Build.BuildId)' TagEnvironment TagService

DYNATRACE_BASE_URL="$1"
DYNATRACE_API_TOKEN="$2"
DYNATRACE_API_URL="$1/api/v1/events"

AZ_RELEASE_DEFINITION_NAME="$3"
AZ_RELEASE_ID="$4"
AZ_RELEASE_TEAM_PROJECT="$5"
AZ_RELEASE_URL="$6"

ENVIONMENT_TAG="$7"
SERVICE_TAG="$8"

echo "================================================================="
echo "Dynatrace Deployment event:"
echo ""
echo "DYNATRACE_BASE_URL         = $DYNATRACE_BASE_URL"
echo "DYNATRACE_API_URL          = $DYNATRACE_API_URL"
echo "DYNATRACE_API_TOKEN        = $DYNATRACE_API_TOKEN"
echo "AZ_RELEASE_DEFINITION_NAME = $AZ_RELEASE_DEFINITION_NAME"
echo "AZ_RELEASE_ID              = $AZ_RELEASE_ID"
echo "AZ_RELEASE_TEAM_PROJECT    = $AZ_RELEASE_TEAM_PROJECT"
echo "AZ_RELEASE_URL             = $AZ_RELEASE_URL"
echo "ENVIONMENT_TAG             = $ENVIONMENT_TAG"
echo "SERVICE_TAG                = $SERVICE_TAG"
echo "================================================================="
POST_DATA=$(cat <<EOF
    {
        "eventType" : "CUSTOM_DEPLOYMENT",
        "source" : "AzureDevops" ,
        "deploymentName" : "$AZ_RELEASE_DEFINITION_NAME",
        "deploymentVersion" : "$AZ_RELEASE_ID"  ,
        "deploymentProject" : "$AZ_RELEASE_TEAM_PROJECT" ,
        "ciBackLink" : "$AZ_RELEASE_URL",
        "attachRules" : {
               "tagRule" : [
                   {
                        "meTypes":"SERVICE" ,
                        "tags" : [
                            {
                                "context" : "CONTEXTLESS",
                                "key": "environment",
                                "value" : "$ENVIONMENT_TAG"    
                            },
                            {
                                "context" : "CONTEXTLESS",
                                "key": "service",
                                "value" : "$SERVICE_TAG"    
                            }
                            ]
                   }
                   ]
        }
    }
EOF)
echo $POST_DATA
curl --url "$DYNATRACE_API_URL" -H "Content-type: application/json" -H "Authorization: Api-Token "$DYNATRACE_API_TOKEN -X POST -d "$POST_DATA"