#command line args
#replace with what schema to be deteremined
$daemonType = $args[0]
$idSchema = $args[1]
$cityName = $args[2]
$time = $args[3]
$dayOfWeek = $args[4]


if($null -eq $daemonType -or $null -eq $idSchema -or $null -eq $cityName -or $null -eq $time -or $null -eq $dayOfWeek){
    Write-Host "Exiting early due to missing arguments -winTaskSetter.ps1"
    exit
}

#if task already exists. Note error supression here allows the code to continue if the task does not exist.
if (Get-ScheduledTask -TaskName $idSchema -ErrorAction SilentlyContinue) {
    #deleting pre-existing version to prevent incompadability w/o prompting user for confirmation
    Unregister-ScheduledTask -TaskName $idSchema -Confirm:$false
}
$exePath = Resolve-Path 'ambience.exe'
#schedule startup daemon
if ($daemonType -eq "boot") {
    #b as in boot daemon flag
    $action = New-ScheduledTaskAction -Execute $exePath -Argument 'b'
    $trigger = New-ScheduledTask -AtStartup
}
#schedule normal daemon
else {
    #what gets executed when daemon is triggered
    $action = New-ScheduledTaskAction -Execute $exePath -Argument $cityname
    #when daemon is triggered
    $trigger = New-ScheduledTaskTrigger -Weekly -At $time -DaysOfWeek $dayOfWeek
}
#this sends the task to task scheduler
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $idSchema
