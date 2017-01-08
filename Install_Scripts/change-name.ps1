param (
   [string]$computername
)

if ( $computername -eq "" ) {
   write-host "No Name"
   exit
}

Function Rename-Computer ([string]$NewComputerName) { 
   $comp = (gwmi win32_computersystem).Name.Trim()
   $ComputerInfo = Get-WmiObject -Class Win32_ComputerSystem 
   Write-Host "Renaming computer...`n`tOld name: $comp`n`tNew name: $apnewname"
   #Start-Sleep (10)
   $ComputerInfo.rename($NewComputerName) | Out-Null
}

function RestartMachine{
   $os = gwmi win32_operatingsystem
   $os.psbase.Scope.Options.EnablePrivileges = $True
   $os.Reboot()
}


if ( $env:computername -eq $computername ) {
  write-host "Name is already this"
} else {
  write-host "Changing computer name to $computername"
  Rename-Computer $computername
  RestartMachine
}
