Add-DnsServerPrimaryZone -NetworkId "10.10.10.0/24" -ReplicationScope Domain
Add-DnsServerPrimaryZone -NetworkId "10.10.20.0/24" -ReplicationScope Domain

ipconfig /registerdns
Add-DnsServerResourceRecordA -ZoneName "lab.internal" -Name "fw01" -IPv4Address 10.10.10.1 -CreatePtr