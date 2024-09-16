<# CREATE SCHEDULED TASK
Description: Creates a Windows scheduled task to execute a program with parameters passed as input 
Input: $TaskName, $Description, $Frequency, $Day, $Time, $Program, $Argument, $WorkingDirectory
Output: -
Use:
	CreateScheduledTask $TaskName $Description $Frequency $Day $Time $Program $Argument $WorkingDirectory
#>
function CreateScheduledTask {
    param(
        [Parameter(Mandatory=$true)]
        [string] $TaskName,

        [Parameter(Mandatory=$true)]
        [string] $Description,

        [Parameter(Mandatory=$true)]
        [string] $Frequency,
		
		[Parameter(Mandatory=$true)]
        [string] $Day,
		
		[Parameter(Mandatory=$true)]
        [string] $Time,
		
		[Parameter(Mandatory=$true)]
        [string] $Program,
		
        [Parameter(Mandatory=$true)]
        [string] $Argument,
        
		[Parameter(Mandatory=$true)]
        [string] $WorkingDirectory
    )
	
	$Action = New-ScheduledTaskAction -Execute $Program -Argument $Argument -WorkingDirectory $WorkingDirectory
			  
    switch ($Frequency) {
        "Daily" {
            $Trigger = New-ScheduledTaskTrigger -Daily -At $Time
        }  
        "Weekly" {
            $Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $Day -At $Time
        }  
        default {
            throw "Invalid entry"
        }
    }

    $Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
		
	$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -ExecutionTimeLimit ([TimeSpan]::FromDays(999))
	
    Register-ScheduledTask -TaskName $TaskName -Description $Description -Action $Action -Trigger $Trigger -Principal $Principal -Force -Settings $Settings

return
}

<# DELETE SCHEDULED TASK
Description: Deletes an existing Windows scheduled task
Input: $TaskName
Output: -
Use:
	DeleteScheduledTask $TaskName
#>
function DeleteScheduledTask {
    param(
        [Parameter(Mandatory=$true)]
        [string]$TaskName
    )

Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false

return
}