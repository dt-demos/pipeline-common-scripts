#!/usr/bin/env bash
#
# Dynatrace Send Event
#
# Required enviroment variables
# - DYNATRACE_BASE_URL
# - DYNATRACE_API_TOKEN
# - EVENT_TYPE
# - TAG_RULE
#
# Optional enviroment variables
# - DEBUG - defaults to false
# - SOURCE - defaults to BitbucketPipelines
#
# These variables are set by BitBucket
# - BITBUCKET_BUILD_NUMBER
# - BITBUCKET_DEPLOYMENT_ENVIRONMENT
# - BITBUCKET_GIT_HTTP_ORIGIN
# - BITBUCKET_COMMIT
# - BITBUCKET_BRANCH
# - BITBUCKET_TAG
# - BITBUCKET_PR_DESTINATION_BRANCH
# - BITBUCKET_PROJECT_KEY
# - BITBUCKET_REPO_FULL_NAME
# - BITBUCKET_REPO_OWNER

source "$(dirname "$0")/common.sh"
DEBUG=${DEBUG:="false"}
enable_debug

info "----------------------------------------------------"
info "Executing Pipe"

# helper function for building up CUSTOM_PROPERTIES
add_custom_property() {
  # for first time add the open bracket, else add comma seperator
  if [ -z "${CUSTOM_PROPERTIES}" ]; then
    CUSTOM_PROPERTIES="{"
  else
    CUSTOM_PROPERTIES="${CUSTOM_PROPERTIES},"
  fi
}

# helper function for building up EVENT_PROPERTIES
add_event_property() {
  # if have values already, then add comma seperator
  if [ ! -z "${EVENT_PROPERTIES}" ]; then
    EVENT_PROPERTIES="${EVENT_PROPERTIES},"
  fi
}

# Required parameters
DYNATRACE_BASE_URL=${DYNATRACE_BASE_URL:?'DYNATRACE_BASE_URL variable missing.'}
DYNATRACE_API_TOKEN=${DYNATRACE_API_TOKEN:?'DYNATRACE_API_TOKEN variable missing.'}
EVENT_TYPE=${EVENT_TYPE?'EVENT_TYPE variable missing.'}
TAG_RULE=${TAG_RULE?'TAG_RULE variable missing.'}

# Optional parameters
SOURCE=${SOURCE:="BitbucketPipeline"}

# if passed in dates, convert ISO to EPOCH in milliseconds expected by DT API
# NOTE: this does not support offsets. Times must be in UTC
[ ! -z "${START}" ] && START="$(date -d "${START}" +%s)000"
[ ! -z "${END}" ] && END="$(date -d "${END}" +%s)000"

# Calculated values
DYNATRACE_API_URL="$DYNATRACE_BASE_URL/api/v1/events"

# build up CUSTOM_PROPERTIES variable
[ ! -z "${BITBUCKET_BUILD_NUMBER}" ] && add_custom_property && CUSTOM_PROPERTIES="${CUSTOM_PROPERTIES}\"buildNumber\":\"${BITBUCKET_BUILD_NUMBER}\""
[ ! -z "${BITBUCKET_DEPLOYMENT_ENVIRONMENT}" ] && add_custom_property && CUSTOM_PROPERTIES="${CUSTOM_PROPERTIES}\"deploymentEnvironment\":\"${BITBUCKET_DEPLOYMENT_ENVIRONMENT}\""
[ ! -z "${BITBUCKET_GIT_HTTP_ORIGIN}" ] && add_custom_property && CUSTOM_PROPERTIES="${CUSTOM_PROPERTIES}\"gitHttpOrigin\":\"${BITBUCKET_GIT_HTTP_ORIGIN}\""
[ ! -z "${BITBUCKET_COMMIT}" ] && add_custom_property && CUSTOM_PROPERTIES="${CUSTOM_PROPERTIES}\"gitCommit\":\"${BITBUCKET_COMMIT}\""
[ ! -z "${BITBUCKET_BRANCH}" ] && add_custom_property && CUSTOM_PROPERTIES="${CUSTOM_PROPERTIES}\"gitBranch\":\"${BITBUCKET_BRANCH}\""
[ ! -z "${BITBUCKET_TAG}" ] && add_custom_property && CUSTOM_PROPERTIES="${CUSTOM_PROPERTIES}\"gitTag\":\"${BITBUCKET_TAG}\""
[ ! -z "${BITBUCKET_PR_DESTINATION_BRANCH}" ] && add_custom_property && CUSTOM_PROPERTIES="${CUSTOM_PROPERTIES}\"prDestinationBranch\":\"${BITBUCKET_PR_DESTINATION_BRANCH}\""
[ ! -z "${BITBUCKET_PROJECT_KEY}" ] && add_custom_property && CUSTOM_PROPERTIES="${CUSTOM_PROPERTIES}\"projectKey\":\"${BITBUCKET_PROJECT_KEY}\""
[ ! -z "${BITBUCKET_REPO_FULL_NAME}" ] && add_custom_property && CUSTOM_PROPERTIES="${CUSTOM_PROPERTIES}\"repoFullName\":\"${BITBUCKET_REPO_FULL_NAME}\""
[ ! -z "${BITBUCKET_REPO_OWNER}" ] && add_custom_property && CUSTOM_PROPERTIES="${CUSTOM_PROPERTIES}\"repoOwner\":\"${BITBUCKET_REPO_OWNER}\""
# if value, then add closing bracket
[ ! -z "${CUSTOM_PROPERTIES}" ] && CUSTOM_PROPERTIES="${CUSTOM_PROPERTIES}}"

# build up EVENT_PROPERTIES variable
case $EVENT_TYPE in

  CUSTOM_ANNOTATION)
    # Required parameters
    ANNOTATION_DESCRIPTION=${ANNOTATION_DESCRIPTION:?'ANNOTATION_DESCRIPTION must be supplied for CUSTOM_ANNOTATION'}
    ANNOTATION_TYPE=${ANNOTATION_TYPE:?'ANNOTATION_TYPE must be supplied for CUSTOM_ANNOTATION'}
    # append values to EVENT_PROPERTIES
    [ ! -z "${ANNOTATION_DESCRIPTION}" ] && add_event_property && EVENT_PROPERTIES="${EVENT_PROPERTIES}\"annotationDescription\":\"${ANNOTATION_DESCRIPTION}\""
    [ ! -z "${ANNOTATION_TYPE}" ] && add_event_property && EVENT_PROPERTIES="${EVENT_PROPERTIES}\"annotationType\":\"${ANNOTATION_TYPE}\""
    ;;

  CUSTOM_CONFIGURATION)
    # Required parameters
    DESCRIPTION=${DESCRIPTION:?'DESCRIPTION must be supplied for CUSTOM_CONFIGURATION'}
    CONFIGURATION=${CONFIGURATION:?'CONFIGURATION must be supplied for CUSTOM_CONFIGURATION'}
    # append values to EVENT_PROPERTIES
    [ ! -z "${DESCRIPTION}" ] && add_event_property && EVENT_PROPERTIES="${EVENT_PROPERTIES}\"description\":\"${DESCRIPTION}\""
    [ ! -z "${CONFIGURATION}" ] && add_event_property && EVENT_PROPERTIES="${EVENT_PROPERTIES}\"configuration\":\"${CONFIGURATION}\""
    [ ! -z "${ORIGINAL_CONFIGURATION}" ] && add_event_property && EVENT_PROPERTIES="${EVENT_PROPERTIES}\"original\":\"${ORIGINAL_CONFIGURATION}\""
    ;;

  CUSTOM_DEPLOYMENT)
    # Required parameters
    DEPLOYMENT_NAME=${DEPLOYMENT_NAME:?'DEPLOYMENT_NAME must be supplied for CUSTOM_DEPLOYMENT'}
    # Optional values
    DEPLOYMENT_PROJECT=${DEPLOYMENT_PROJECT:="$BITBUCKET_PROJECT_KEY"}
    DEPLOYMENT_VERSION=${DEPLOYMENT_VERSION:="$BITBUCKET_BUILD_NUMBER"}
    [ ! -z $BITBUCKET_REPO_FULL_NAME ] && CI_BACK_LINK="https://bitbucket.org/${BITBUCKET_REPO_FULL_NAME}/addon/pipelines/home#!/results/${BITBUCKET_BUILD_NUMBER}"
    # append values to EVENT_PROPERTIES
    [ ! -z "${DEPLOYMENT_NAME}" ] && add_event_property && EVENT_PROPERTIES="${EVENT_PROPERTIES}\"deploymentName\":\"${DEPLOYMENT_NAME}\""
    [ ! -z "${DEPLOYMENT_VERSION}" ] && add_event_property && EVENT_PROPERTIES="${EVENT_PROPERTIES}\"deploymentVersion\":\"${DEPLOYMENT_VERSION}\""
    [ ! -z "${DEPLOYMENT_PROJECT}" ] && add_event_property && EVENT_PROPERTIES="${EVENT_PROPERTIES}\"deploymentProject\":\"${DEPLOYMENT_PROJECT}\""
    [ ! -z "${DEPLOYMENT_REMEDIATION_ACTION}" ] && add_event_property && EVENT_PROPERTIES="${EVENT_PROPERTIES}\"remediationAction\":\"${DEPLOYMENT_REMEDIATION_ACTION}\""
    [ ! -z "${CI_BACK_LINK}" ] && add_event_property && EVENT_PROPERTIES="${EVENT_PROPERTIES}\"ciBackLink\":\"${CI_BACK_LINK}\""
    ;;

  CUSTOM_INFO)
    # Required parameters
    TITLE=${TITLE:?'TITLE must be supplied for CUSTOM_INFO'}
    DESCRIPTION=${DESCRIPTION:?'DESCRIPTION must be supplied for CUSTOM_INFO'}
    # append values to EVENT_PROPERTIES
    [ ! -z "${TITLE}" ] && add_event_property && EVENT_PROPERTIES="${EVENT_PROPERTIES}\"title\":\"${TITLE}\""
    [ ! -z "${DESCRIPTION}" ] && add_event_property && EVENT_PROPERTIES="${EVENT_PROPERTIES}\"description\":\"${DESCRIPTION}\""
    ;;
  *)
    fail "Unknown event type $EVENT_TYPE"
    ;;
esac

# build up POST_BODY variable
POST_BODY="{\"eventType\":\"${EVENT_TYPE}\""
POST_BODY="${POST_BODY},\"source\":\"${SOURCE}\""
POST_BODY="${POST_BODY},\"attachRules\": { \"tagRule\":${TAG_RULE} }"
[ ! -z "$EVENT_PROPERTIES" ] && POST_BODY="${POST_BODY},${EVENT_PROPERTIES}"
[ ! -z "$CUSTOM_PROPERTIES" ] && POST_BODY="${POST_BODY},\"customProperties\":${CUSTOM_PROPERTIES}"
[ ! -z $START ] && POST_BODY="${POST_BODY},\"start\":${START}"
[ ! -z $END ] && POST_BODY="${POST_BODY},\"end\":${END}"
# add the closing bracket
POST_BODY="${POST_BODY}}"

if [[ "${DEBUG}" == "true" ]]; then
  ARGS+=( --verbose )
fi

ARGS=(
  --request POST
  --silent
  --url "${DYNATRACE_API_URL}"
  --header "Content-type: application/json"
  --header "Authorization: Api-Token ${DYNATRACE_API_TOKEN}"
  --data "${POST_BODY}"
)

info "----------------------------------------------------"
info "Calling Dynatrace Push Event API"
debug "DYNATRACE_BASE_URL = ${DYNATRACE_BASE_URL}"
debug "POST_BODY          = $POST_BODY"
debug "EVENT_PROPERTIES   = ${EVENT_PROPERTIES}"
debug "CUSTOM_PROPERTIES  = ${CUSTOM_PROPERTIES}"
info "----------------------------------------------------"
status=$(curl "${ARGS[@]}")
debug "API call results = $status"
debug "----------------------------------------------------"
if [[ "$status" == *"error"* ]]; then
  fail "Error: Failed sending Dynatrace $EVENT_TYPE event: $status"
  exit 1
else
  success "Success: Sending Dynatrace $EVENT_TYPE event"
fi
