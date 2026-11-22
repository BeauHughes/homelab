# On DC02
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.10.10.10, 10.10.10.11
Get-DnsServerForwarder   # if empty: Set-DnsServerForwarder -IPAddress 10.10.10.1
# On DC01
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.10.10.10, 10.10.10.11
Set-DhcpServerv4OptionValue -ScopeId 10.10.20.0 -DnsServer 10.10.10.10, 10.10.10.11