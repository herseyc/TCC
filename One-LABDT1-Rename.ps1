Param (
[string]$LabName
)

$usage = "One-LABDT1-Rename.ps1 -LabName <LabName>"

if ( $LabName -eq "" ) {
   write-host "LAB Name must be specified"
   write-host "Usage: $usage"
   exit
}
#Rename vApp Desktops

$labuser = "admin1@vmlab.local"
$labpass = "VMware1!"

#Get vApps in the LAB Cluster

$vapps = get-cluster -Name Lab | get-vapp | Where { $_.Name -eq $LabName } | select name

# Rename the LABDT1 to the vApp name
foreach ($vapp in $vapps) {

   $vapplabname = $vapp.name
   $vm = get-vapp -Name $vapp.name | get-VM | where {$_.Name -eq "LABDT1" -and $_.PowerState -eq "PoweredOn"}
   $vmname = $vm.name

   if ( $vmname ) {
      write-host "Setting $vapplabname $vmname to $vapplabname"
      #Rename Guest OS Compute Name to vApp Name
      $script = "powershell.exe C:\Install_Files\change-name.ps1 $vapplabname"
      $vm | Invoke-VMScript -GuestUser $labuser -GuestPassword $labpass -ScriptText $script
   } else {
      write-host "LABDT1 not found or not powered on in vApp $vapplabname"
   }

   $vmname = ""

}
