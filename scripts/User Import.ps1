$pw = Read-Host -AsSecureString "Temporary password for new users"
Import-Csv C:\Lab\users.csv | ForEach-Object {
  $sam = ($_.FirstName.Substring(0,1) + $_.LastName).ToLower()
  $ou  = "OU=$($_.Department),OU=LAB,DC=lab,DC=internal"
  New-ADUser -Name "$($_.FirstName) $($_.LastName)" `
    -GivenName $_.FirstName -Surname $_.LastName `
    -SamAccountName $sam -UserPrincipalName "$sam@lab.internal" `
    -Department $_.Department -Title $_.Title `
    -Path $ou -AccountPassword $pw -Enabled $true -ChangePasswordAtLogon $true
  Add-ADGroupMember -Identity "GG-$($_.Department)" -Members $sam
  Write-Host "Created $sam in $($_.Department)"
}