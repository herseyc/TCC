### Script to create user accounts in Classroom AD ######

$users = Import-Csv -Delimiter "," -Path "C:\Scripts\fall2016.csv"

$description = "ITN255 - Spring 2017 - Hersey Cartwright"
$server = "classroom.local"
$password = "Set Temp Password"
$ou = "ou=HC-S2017,ou=ITN255,ou=Class,dc=classroom,dc=local"
$group = "ITN255"

foreach ($user in $users) {

   $account = $user.Email.split('@')
   $accountname = $account[0]

write-host "Accountname: $accountname"
write-host $user.Name

$name = $user.Name.split(',')
$lastname = $name[0]
$firstname = $name[1]

write-host "Lastname: $lastname"
write-host "Firstname: $firstname"

$displayname = "$firstname $lastname"

write-host "Displayname: $displayname"
write-host "------------------------------"
Write-Host "Adding $accountname to $ou on $server"
New-ADuser -Name "$displayname" -DisplayName "$displayname" -Description "$description" -SamAccountName $accountname -GivenName "$firstname" -Surname "$lastname" -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -Path $ou -Enabled $true -ChangePasswordAtLogon $true -PasswordNeverExpires $false -Server $server
Write-Host "Adding $accountname to $group Group"
Add-ADGroupMember -Identity $group -Member $accountname
write-host "------------------------------"


}
