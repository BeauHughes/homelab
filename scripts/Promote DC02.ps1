Enable-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)"
Resolve-DnsName _ldap._tcp.dc._msdcs.lab.internal -Type SRV
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-ADDSDomainController -DomainName "lab.internal" -InstallDns `
  -Credential (Get-Credential LAB\beau.admin) `
  -SafeModeAdministratorPassword (Read-Host -AsSecureString "DSRM password")