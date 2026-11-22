Install-WindowsFeature DHCP -IncludeManagementTools
Add-DhcpServerInDC -DnsName "dc01.lab.internal" -IPAddress 10.10.10.10
Add-DhcpServerSecurityGroup
Restart-Service dhcpserver

Add-DhcpServerv4Scope -Name "Clients" -StartRange 10.10.20.10 -EndRange 10.10.20.200 `
  -SubnetMask 255.255.255.0 -LeaseDuration 8.00:00:00 -State Active
Set-DhcpServerv4OptionValue -ScopeId 10.10.20.0 -Router 10.10.20.1 `
  -DnsServer 10.10.10.10 -DnsDomain "lab.internal"
Add-DhcpServerv4ExclusionRange -ScopeId 10.10.20.0 -StartRange 10.10.20.10 -EndRange 10.10.20.99