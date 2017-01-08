### Script to create user accounts in Classroom AD ######

#CSV Name, Email exported from SIS Class Roster
$users = Import-Csv -Delimiter "," -Path "C:\Scripts\fall2016.csv"

$description = "ITN255 - Spring 2017 - Hersey Cartwright" # Class - Semester - Instructor
$server = "classroom.local" # Domain
$password = "Set Temp Password" # Temporary Password - Must be changed at first login
$ou = "ou=HC-S2017,ou=ITN255,ou=Class,dc=classroom,dc=local" # Class OU
$group = "ITN255" # Group for View Desktop Entitlement

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
