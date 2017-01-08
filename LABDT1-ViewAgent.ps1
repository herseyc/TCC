
#Install View Agent on Lab vApp LABDT1

$labuser = "admin1@vmlab.local"
$labpass = "VMware1!"

#Get vApps in the LAB Cluster

$vapps = get-cluster -Name Lab | get-vapp | select name

# Rename the LABDT1 to the vApp name
foreach ($vapp in $vapps) {

   $labname = $vapp.name
   $vm = get-vapp -Name $vapp.name | get-VM | where {$_.Name -eq "LABDT1" -and $_.PowerState -eq "PoweredOn"}
   $vmname = $vm.name

   if ( $vmname ) {
      write-host "Installing View Agent on $labname $vmname"
      #Rename Guest OS Compute Name to vApp Name
      $script = "C:\Install_Files\VDM-Install.bat"
      $vm | Invoke-VMScript -GuestUser $labuser -GuestPassword $labpass -ScriptText $script
   } else {
      write-host "LABDT1 not found or not powered on in vApp $labname"
   }

   $vmname = ""

}
