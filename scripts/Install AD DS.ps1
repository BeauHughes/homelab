Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

Install-ADDSForest -DomainName "lab.internal" -DomainNetbiosName "LAB" -InstallDns `
  -SafeModeAdministratorPassword (Read-Host -AsSecureString "DSRM password")

Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.10.10.10
Set-DnsServerForwarder -IPAddress 1.1.1.1, 1.0.0.1