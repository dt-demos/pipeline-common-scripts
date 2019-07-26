# This script pushes Dynatrace CUSTOM_DEPLOYMENT event to the passed in Dyntrace tenant
# Assumes that will tag entities with an "environment" and "service" TAG

# arguments
# $0 = dynatrace-base-url, eg. http://<tenant>.live.dynatrace.com
# $1 = dynatrace-api-token
# $2 = tag-value-environment
# $3 = tag-value-service

# read Dynatrace values from the pipeline variables
$DYNATRACE_API_URL=$Args[0] + "/api/v1/events"
$DYNATRACE_API_TOKEN=$Args[1]

# set the data for the API call
# adjust the number of tags in the JSON below and tag variables values
$TAG_VALUE_ENVIRONMENT=$Args[2]
$TAG_VALUE_SERVICE=$Args[3]

# set values that are passes as Dyntrace event context
# you can adjust these as you see fit
$DEPLOYMENT_PROJECT="Azure DevOps project: $($env:SYSTEM_TEAMPROJECT)"
$DEPLOYMENT_NAME="$($env:RELEASE_DEFINITIONNAME) $($env:RELEASE_RELEASENAME)"
$SOURCE="Pipeline: $($env:RELEASE_DEFINITIONNAME)"
$DEPLOYMENT_VERSION="$($env:RELEASE_RELEASENAME)"
$CI_BACKLINK="$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)$($env:SYSTEM_TEAMPROJECT)/_releaseProgress?releaseId=$($env:RELEASE_RELEASEID)&_a=release-pipeline-progress"


$REQUEST_BODY=@"
{
    "eventType" : "CUSTOM_DEPLOYMENT",
    "deploymentName" : "$DEPLOYMENT_NAME",
    "source" : "$SOURCE",
    "deploymentVersion" : "$DEPLOYMENT_VERSION"  ,
    "deploymentProject" : "$DEPLOYMENT_PROJECT" ,
    "ciBackLink" : "$CI_BACKLINK",
    "attachRules" : {
            "tagRule" : [
                {
                    "meTypes":"SERVICE" ,
                    "tags" : [
                        {
                            "context" : "CONTEXTLESS",
                            "key": "environment",
                            "value" : "$TAG_VALUE_ENVIRONMENT"    
                        },
                        {
                            "context" : "CONTEXTLESS",
                            "key": "service",
                            "value" : "$TAG_VALUE_SERVICE"    
                        }
                        ]
                }
                ]
    }
}
"@
$HEADERS = @{ Authorization = "Api-Token $DYNATRACE_API_TOKEN" }

Write-Host "==============================================================="
Write-Host "DEPLOYMENT_PROJECT    : "$DEPLOYMENT_PROJECT
Write-Host "DEPLOYMENT_NAME       : "$DEPLOYMENT_NAME
Write-Host "DEPLOYMENT_VERSION    : "$DEPLOYMENT_VERSION
Write-Host "CI_BACKLINK           : "$CI_BACKLINK
Write-Host ""
Write-Host "DYNATRACE_API_URL     : "$DYNATRACE_API_URL
Write-Host "TAG_VALUE_ENVIRONMENT : "$TAG_VALUE_ENVIRONMENT
Write-Host "TAG_VALUE_SERVICE     : "$TAG_VALUE_SERVICE
Write-Host "REQUEST_BODY          : "$REQUEST_BODY
Write-Host "==============================================================="
Write-Host "Calling Dynatrace Event API..."

$RESULT_BODY = Invoke-RestMethod -Uri $DYNATRACE_API_URL -Method Post -Body "$REQUEST_BODY" -ContentType "application/json" -Headers $HEADERS

# show the full body for debugging
$RESPONSE_JSON = $RESULT_BODY | ConvertTo-Json -Depth 5
Write-Host "Dynatrace API Response: "$RESPONSE_JSON
