# Summary

This repo contains reference scripts for use integrating Dynatrace into software delivery pipelines using the [Dynatrace Events API](https://www.dynatrace.com/support/help/extend-dynatrace/dynatrace-api/environment-api/events/post-event/)

In just a few steps, you can add Dynatrace information events for things like deployments, performance tests, or configuration changes. In doing so, your development and operations teams have additional context information during review and analysis of your applications.

# Scripts

## PowerShell
* captureStartTime.ps1 - save current time to environment variable
* captureEndTime.ps1 - save current time to environment variable
* azureDevopsCustomEvent.ps1 - add Dynatrace CUSTOM_INFO event
* azureDevopsDeploymentEvent.ps1 - add Dynatrace CUSTOM_DEPLOYMENT event

## Unix Shell
* dynatrace-deployment-event.sh - add Dynatrace CUSTOM_DEPLOYMENT event


