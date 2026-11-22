$domain = "DC=lab,DC=internal"
New-ADOrganizationalUnit -Name "LAB" -Path $domain
$root = "OU=LAB,$domain"
"Staff", "Faculty", "Students", "Admins", "Lab Computers", "Servers", "Groups" |
  ForEach-Object { New-ADOrganizationalUnit -Name $_ -Path $root }

$groups = "OU=Groups,OU=LAB,DC=lab,DC=internal"
"Staff", "Faculty", "Students", "IT Admins" | ForEach-Object {
  New-ADGroup -Name "GG-$_" -GroupScope Global -GroupCategory Security -Path $groups
}

New-ADUser -Name "Beau Admin" -SamAccountName "beau.admin" `
  -UserPrincipalName "beau.admin@lab.internal" `
  -Path "OU=Admins,OU=LAB,DC=lab,DC=internal" `
  -AccountPassword (Read-Host -AsSecureString "Password for beau.admin") -Enabled $true
Add-ADGroupMember -Identity "Domain Admins" -Members "beau.admin"
Add-ADGroupMember -Identity "GG-IT Admins" -Members "beau.admin"