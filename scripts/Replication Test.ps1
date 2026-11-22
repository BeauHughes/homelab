New-ADUser -Name "Repl Test" -Path "OU=Staff,OU=LAB,DC=lab,DC=internal" -Server DC02
repadmin /syncall /AdeP
Get-ADUser "Repl Test" -Server DC01
Remove-ADUser "Repl Test" -Confirm:$false