#command line args
#replace with what schema to be deteremined
$idSchema = $args[0]
$cityName = $args[1]
$time = $args[2]
$dayOfWeek = $args[3]


Write-Host "arg[0]:$idSchema arg[1]:$cityName arg[2]:$time arg[3]:$dayOfWeek"
#if there are missing commandline arguments
if($idSchema -eq $null -or $cityName -eq $null -or $time -eq $null -or $dayOfWeek -eq $null){
    Write-Host "Exiting early due to missing arguments"
    exit
}
#if task already exists. Note error supression here allows the code to continue if the task does not exist.
if(Get-ScheduledTask -TaskName $idSchema -ErrorAction SilentlyContinue){
    #deleting pre-existing version to prevent incompadability w/o prompting user for confirmation
    Unregister-ScheduledTask -TaskName $idSchema -Confirm:$false
}

#this is what the task is going to do, .. = append parent dictory
$action = New-ScheduledTaskAction -Execute '..\ambience.exe' -Argument $cityname
#e.g. of time would be "10:02am" or "10:05pm"
#this sets what the trigger is
$trigger =  New-ScheduledTaskTrigger -Weekly -At $time -DaysOfWeek $dayOfWeek
#this sends the task to task scheduler
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $idSchema