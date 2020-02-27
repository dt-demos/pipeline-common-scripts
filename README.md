# Summary

This repo contains reference scripts for use integrating Dynatrace into software delivery pipelines.

Please share feedback and your examples with a Pull Request or to me @ rob.jahn@dyntrace.com

## Events

In just a few steps, you can add [Dynatrace Events API](https://www.dynatrace.com/support/help/extend-dynatrace/dynatrace-api/environment-api/events/post-event/) for things like deployments, performance tests, or configuration changes. In doing so, your development and operations teams have additional context information during review and analysis of your applications.

Read more in my [Dynatrace blog](https://www.dynatrace.com/news/blog/get-started-integrating-dynatrace-in-your-azure-devops-release-pipelines/)

# Scripts

## PowerShell
* captureStartTime.ps1 - save current time to environment variable
* captureEndTime.ps1 - save current time to environment variable
* azureDevopsCustomEvent.ps1 - add Dynatrace CUSTOM_INFO event
* azureDevopsDeploymentEvent.ps1 - add Dynatrace CUSTOM_DEPLOYMENT event

## Unix Shell
* dynatrace-deployment-event.sh - add Dynatrace CUSTOM_DEPLOYMENT event
* test-keptn-quality-gate.sh - used to test [http://keptn.sh](Keptn Quality Gate)

# Local testing

In the ```testing/``` folder are a few "wrapper" scripts that can be used to test these scripts.  Just make a copy of the template file.  You can update with your testing input.  If you keep the prefix of ```test```, the ```.gitinore``` file will ensure you dont check in any secrets.




