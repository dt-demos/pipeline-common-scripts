#!/usr/bin/env bash
#
# Dynatrace Send Event
#
# Required enviroment variables
# - DYNATRACE_BASE_URL
# - DYNATRACE_API_TOKEN
# - DEPLOYMENT_PROJECT
# - DEPLOYMENT_NAME
# - DEPLOYMENT_VERSION
# - SOURCE
# - CI_BACK_LINK
# - EVENT_TYPE
# - TAG_RULE
#
# Optional
# - DEBUG  -- values 'false' and 'true'
# 

info "Executing dynatrace-send-event..."

# Required parameters
DYNATRACE_BASE_URL=${DYNATRACE_BASE_URL:?'DYNATRACE_BASE_URL variable missing.'}
DYNATRACE_API_TOKEN=${DYNATRACE_API_TOKEN:?'DYNATRACE_API_TOKEN variable missing.'}

DEPLOYMENT_PROJECT=${DEPLOYMENT_PROJECT:?'DEPLOYMENT_PROJECT variable missing.'}
DEPLOYMENT_NAME=${DEPLOYMENT_NAME:?'DEPLOYMENT_NAME variable missing.'}
DEPLOYMENT_VERSION=${DEPLOYMENT_VERSION:?'DEPLOYMENT_VERSION variable missing.'}
SOURCE=${SOURCE:?'SOURCE variable missing.'}
CI_BACK_LINK=${CI_BACK_LINK:?'SOURCE variable missing.'}

EVENT_TYPE=${EVENT_TYPE:="$EVENT_TYPE"}

# Optional Value
DEBUG=${DEBUG:="false"}


# Calculated values
DYNATRACE_API_URL="$DYNATRACE_BASE_URL/api/v1/events"

CUSTOM_PROPERTIES=$(cat <<EOF
{
  "buildNumber":""
  "deploymentEnvironment":""
  "gitHttpOrigin":""
  "gitCommit":""
  "gitBranch":""
  "gitTag":""
  "prDestinationBranch":""
  "projectKey":""
  "repoFullName":""
  "repoOwner":""
}
EOF
)

# Event Type Checks
case $EVENT_TYPE in

  CUSTOM_ANNOTATION)
    ANNOTATION_TYPE=${ANNOTATION_TYPE:?'ANNOTATION_TYPE must be supplied for CUSTOM_ANNOTATION'}
    ANNOTATION_DESCRIPTION=${ANNOTATION_DESCRIPTION:?'ANNOTATION_DESCRIPTION must be supplied for CUSTOM_ANNOTATION'}
    ;;

  CUSTOM_CONFIGURATION)
    DESCRIPTION=${DESCRIPTION:?'DESCRIPTION must be supplied for CUSTOM_CONFIGURATION'}
    CONFIGURATION=${CONFIGURATION:?'CONFIGURATION must be supplied for CUSTOM_CONFIGURATION'}
    ;;

  CUSTOM_DEPLOYMENT)
    DEPLOYMENT_NAME=${DEPLOYMENT_NAME:?'DEPLOYMENT_NAME must be supplied for CUSTOM_DEPLOYMENT'}
    DEPLOYMENT_DESCRIPTION=${DEPLOYMENT_DESCRIPTION:?'DEPLOYMENT_DESCRIPTION must be supplied for CUSTOM_DEPLOYMENT'}

    # customize this example
    #CUSTOM_PROPERTIES=$(cat <<EOF
    # {
    #  "buildNumber":"$BITBUCKET_BUILD_NUMBER",
    #  "deploymentEnvironment":"$BITBUCKET_DEPLOYMENT_ENVIRONMENT",
    #  "gitHttpOrigin":"$BITBUCKET_GIT_HTTP_ORIGIN",
    #  "gitCommit":"$BITBUCKET_COMMIT",
    #  "gitBranch":"$BITBUCKET_BRANCH",
    #  "gitTag":"$BITBUCKET_TAG",
    #  "prDestinationBranch":"$BITBUCKET_PR_DESTINATION_BRANCH",
    #  "projectKey":"$BITBUCKET_PROJECT_KEY",
    #  "repoFullName":"$BITBUCKET_REPO_FULL_NAME",
    #  "repoOwner":"$BITBUCKET_REPO_OWNER"
    # }
EOF
    )

    DATA=$(cat <<EOF
    {
      "eventType":"$EVENT_TYPE",
      "source":"$SOURCE",
      "deploymentName":"$DEPLOYMENT_NAME",
      "deploymentVersion":"$DEPLOYMENT_VERSION",
      "deploymentProject":"$DEPLOYMENT_PROJECT",
      "ciBackLink":"$CI_BACK_LINK",
      "customProperties":$CUSTOM_PROPERTIES,
      "attachRules":{
        "tagRule":$TAG_RULE
      }
    }
EOF
    )
    ;;

  CUSTOM_INFO)
    DESCRIPTION=${DESCRIPTION:?'DESCRIPTION must be supplied for CUSTOM_INFO'}
    ;;

  *)
    fail "Unknown event type"
    ;;
esac

if [[ "${DEBUG}" == "true" ]]; then
  info "DYNATRACE_API_URL  = $DYNATRACE_API_URL"
  info "---"
  info "$DATA"
  info "---"
  ARGS+=( --verbose )
fi

ARGS=(
  --request POST
  --url "${DYNATRACE_API_URL}"
  --header "Content-type: application/json"
  --header "Authorization: Api-Token ${DYNATRACE_API_TOKEN}"
  --data "${DATA}"
)

if curl "${ARGS[@]}"; then
  success "Success: Sending Dynatrace $EVENT_TYPE event"
else
  fail "Error: Failed sending Dynatrace $EVENT_TYPE evente"
fi
