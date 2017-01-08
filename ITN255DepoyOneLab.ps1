########################################################################################################
# PowerCLI script to Deploy TCC VMware IT Academy Labs for ITN254/ITN255/ITN231 from Master vApp
# Usage DeployOneLab.ps1
#
# Distributes vApps across available hosts
# Creates Isolated vSwitch
# Creates Promiscuous Mode PortGroup
# Creates Standard PortGroup
# Clones Master vApp
# Attaches VM Network Adapters to Correct Port Groups
#
# Requires active connection to vCenter Server (using Connect-VIServer)
#
# History:
# 12/11/2015 - Hersey http://www.vhersey.com/ - Created
#
########################################################################################################
Param (
[string]$ESXHost,
[string]$LabName
)

$usage = "DeployOneLab.ps1 -ESXHost <ESXHostName> -LabName <LabName>"

if ( $ESXost -eq "" ) {
   write-host "ESXi Host must be specified"
   write-host "Usage: $usage"
   exit
}

if ( $LabName -eq "" ) {
   write-host "LAB Name must be specified"
   write-host "Usage: $usage"
   exit
}

############Lab Variables##########################
#Cluster Name
$ClusterName = "LAB"

#Master vApp
$MastervApp = "ITN255LABMASTER"

#Datastore
$Datastore = "VMWARELABS"

#ClassRoom PortGroup
$ClassRoomPG = "VM Network"

#Master vApp Promiscuous Mode PortGroup
$vAppPMNetwork = "LABPM"

#Master vApp Standard PortGroup
$vAppStdNetwork = "LAB"


##################################################

$DeployHost = Get-VMHost -Name $ESXHost

#Get Datastore for vApp Deployment
$vAppDatastore = Get-Datastore -Name $Datastore


Write-Host "Deploying Lab $LabName to $ESXHost"

#Create Isolated Lab vSwitch
$PMPGName = "$LabName-PM"
Write-Host "Creating $LabName vSwitch"
$vSwitch = New-VirtualSwitch -VMHost $DeployHost -Name $LabName
  
#Create Promiscuous Mode PortGroup
Write-Host "Creating Promiscuous Mode PortGroup $PMPGName on vSwitch $LabName"
$vAppPMPG = New-VirtualPortGroup -Name $PMPGName -VirtualSwitch $vSwitch
  
#Set Promiscuous Mode on PortGroup
Write-Host "Setting Promiscuous Mode PortGroup $PMPGName on vSwitch $LabName"
Get-VirtualPortGroup -VirtualSwitch $vSwitch -Name $PMPGName  | Get-SecurityPolicy | Set-SecurityPolicy -AllowPromiscuous $true
  
#Create Non-Promiscuous Mode Port Group
Write-Host "Creating PortGroup $LabName on vSwitch $LabName"
$vAppPG = New-VirtualPortGroup -Name $LabName -VirtualSwitch $vSwitch

Write-Host "Deploying $LabName"
New-vApp -VApp $MastervApp -Name $LabName -Location $DeployHost -VMHost $DeployHost -Datastore $vAppDatastore
  
#Connect VM Network Adapters to Correct PortGroups  
$vAppVMs = Get-VApp $LabName | Get-VM
ForEach ($vAppVM in $vAppVMs ) {

  Get-VM -Location $LabName $vAppVM | Get-NetworkAdapter | Where {$_.NetworkName -eq $vAppPMNetwork}  | Set-NetworkAdapter -Portgroup $vAppPMPG -Confirm:$false
  Get-VM -Location $LabName $vAppVM | Get-NetworkAdapter | Where {$_.NetworkName -eq $vAppStdNetwork}  | Set-NetworkAdapter -Portgroup $vAppPG -Confirm:$false

}

Get-vApp -Name $LabName | Start-vApp -RunAsync

Write-Host "Lab $LabName Deployed"
 
