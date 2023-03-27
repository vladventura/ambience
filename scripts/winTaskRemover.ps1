#command line args
#replace with what schema to be deteremined
$idSchema = $args[0]

#if there are missing commandline arguments exit early
if($idSchema -eq $null ){
    Write-Host "Exiting early due to missing arguments"
    exit
}
#check to see if task exists before removing it
if(Get-ScheduledTask -TaskName $idSchema -ErrorAction SilentlyContinue){
    #removing said task without user confirmation
    Unregister-ScheduledTask -TaskName $idSchema -Confirm:$false
}else{
Write-Host "Task: $idSchema not found!
}