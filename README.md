# Summary

This repo contains reference scripts for use integrating Dynatrace into software delivery pipelines.

Please share feedback and your examples with a Pull Request or to me @ rob.jahn@dyntrace.com

## Events

In just a few steps, you can add [Dynatrace Events API](https://www.dynatrace.com/support/help/extend-dynatrace/dynatrace-api/environment-api/events/post-event/) for things like deployments, performance tests, or configuration changes. In doing so, your development and operations teams have additional context information during review and analysis of your applications.

Read more in my [Dynatrace blog](https://www.dynatrace.com/news/blog/get-started-integrating-dynatrace-in-your-azure-devops-release-pipelines/)

# Scripts

## PowerShell
* azureDevopsCaptureStartTime.ps1 - save current time to environment variable
* azureDevopsCaptureEndTime.ps1 - save current time to environment variable
* azureDevopsCustomEvent.ps1 - add Dynatrace CUSTOM_INFO event
* azureDevopsDeploymentEvent.ps1 - add Dynatrace CUSTOM_DEPLOYMENT event

## Unix Shell
* bitbucketPushEvent.sh - push events from one script.  Used bitbucket built-in vars for various properties in the event
* dynatrace-deployment-event.sh - add Dynatrace CUSTOM_DEPLOYMENT event
* dynatrace-push-event.sh - add misc events from on script. Modify for your CI/CD tool
* test-keptn-quality-gate.sh - used to test [http://keptn.sh](Keptn Quality Gate)
* send-traffic.sh - simple script to send load with request attributes
* wait-till-ready.sh - simply script to add after a deployment event

# Local testing

In the ```testing/``` folder are a few "wrapper" scripts that can be used to test these scripts.  Just make a copy of the template file.  You can update with your testing input.  If you keep the prefix of ```test```, the ```.gitinore``` file will ensure you dont check in any secrets.




