<#
.SYNOPSIS
  Creates one lab user: AD account in the right OU and group, temp password, log entry.
.EXAMPLE
  .\New-LabUser.ps1 -FirstName Jane -LastName Doe -Department Faculty -Title "Chemistry Instructor"
#>
param(
  [Parameter(Mandatory)][string]$FirstName,
  [Parameter(Mandatory)][string]$LastName,
  [Parameter(Mandatory)][ValidateSet("Staff","Faculty","Students")][string]$Department,
  [string]$Title = ""
)
$ErrorActionPreference = "Stop"
$logFile = "C:\Lab\Logs\NewHires.log"

# Username: first initial + last name; add a number if it's taken (jdoe, jdoe2, ...)
$base = ($FirstName.Substring(0,1) + $LastName).ToLower() -replace '[^a-z0-9]', ''
$sam = $base; $n = 1
while (Get-ADUser -Filter "SamAccountName -eq '$sam'") { $n++; $sam = "$base$n" }

# Temporary password: 12 random characters plus one uppercase, digit and symbol
$chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789'
$plain = (-join (1..12 | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })) + 'K7!'
$secure = ConvertTo-SecureString $plain -AsPlainText -Force

New-ADUser -Name "$FirstName $LastName" -GivenName $FirstName -Surname $LastName `
  -SamAccountName $sam -UserPrincipalName "$sam@lab.internal" `
  -Department $Department -Title $Title `
  -Path "OU=$Department,OU=LAB,DC=lab,DC=internal" `
  -AccountPassword $secure -Enabled $true -ChangePasswordAtLogon $true
Add-ADGroupMember -Identity "GG-$Department" -Members $sam

# Log who did what and when (never the password)
New-Item -ItemType Directory -Path (Split-Path $logFile) -Force | Out-Null
"$(Get-Date -Format s),$env:USERNAME,created,$sam,$Department" | Add-Content $logFile

Write-Host "Created $sam in $Department. Temporary password: $plain"
Write-Host "Give it to the user securely. It is not saved anywhere."