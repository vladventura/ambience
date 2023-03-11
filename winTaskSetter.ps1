#command line args
$cityname = $args[0]
$time = $args[1] #format: xx:xxam or xx:xxpm e.g. 10:01am or 10:01pm. Note: can do just do xx<am or pm>.
$taskName = "ambienceDaemon"
#if vital arguments are null
if($cityname -eq $null -or $time -eq $null){
    Write-Host "Exiting early due to missing arguments"
    exit
}
#if task already exists. Note error supression here allows the code to continue if the task does not exist.
if(Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue){
    #deleting pre-existing version to prevent incompadability
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

#this is what the task is going to do, .. = append parent dictory
$action = New-ScheduledTaskAction -Execute '..\ambience.exe' -Argument $cityname
#e.g. of time would be "10:02am" or "10:05pm"
#this sets what the trigger is
$trigger =  New-ScheduledTaskTrigger -Once -At $time
#this sends the task to task scheduler
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "ambienceDaemon"