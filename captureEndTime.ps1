# This script gets the current time and stores into an environment
# variable called 'endTime' that can be accessed in Azure
# devOps task was $(endTime)

$endTime = Get-Date -UFormat %s
$endTimeFormatted = Get-Date -UFormat "%x %R"

Write-Host "==============================================================="
Write-Host "End Time: "$endTime
Write-Host "End Time Formatted: "$endTimeFormatted
Write-Host "==============================================================="

Write-Host ("##vso[task.setvariable variable=endTimeFormatted]$endTimeFormatted")
Write-Host ("##vso[task.setvariable variable=endTime]$endTime")
