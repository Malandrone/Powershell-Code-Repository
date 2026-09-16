<# PowerOn-VM
Author: Giuseppe Malandrone
Description: Check whether the virtual machine is powered off and, if so, power it on.
Input: -
Output: -
Use: Save this file to C:\Script\ and create a scheduled task with following parameters:
		Program: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
		Arguments:-NoProfile -ExecutionPolicy Bypass -File "C:\Script\PowerOn-VM.ps1"
		Initial path: (empty) 
#>


$timestamp = ((Get-Date -Format "yyyy-MM-dd HH:mm:ss").toString()).replace(" ","_").replace(":","-");
$LogFileName = "VM_powerON_log_"+$timestamp+".txt"
$LogFilePath = ("D:\PowerOnVMLogs\"+$LogFileName)  #to edit
$VBoxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe";
Start-Transcript -Path $LogFilePath

#VM_NAME
$VMName = "VM_NAME";
$vmInfo = & $VBoxManage showvminfo $VMName --machinereadable |
           Where-Object { $_ -like "VMState*" } |
           ForEach-Object { ($_ -split '=')[1].Trim('"') }
$vmState = $vmInfo[0]
if ($vmState -eq "poweroff") {	
	$timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss").toString();
	$LogRecord = ($timestamp + " : The VM "+$VMName+" is powered off; I’m sending the power-on command.") ;	
    Write-Host $LogRecord
    & $VBoxManage startvm $VMName --type headless
}

Stop-Transcript