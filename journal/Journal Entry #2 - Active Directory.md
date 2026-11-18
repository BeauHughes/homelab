# Journal Entry #2 — Active Directory (Step 3, Week 2)

## What I built
Promoted DC01 to the first domain controller in a new forest, with OUs,
security groups, 25 users and reverse DNS.

## Domain facts
| Item              | Value                              |
|-------------------|------------------------------------|
| Domain (DNS)      | lab.internal                       |
| NetBIOS name      | LAB                                |
| Domain controller | DC01 (10.10.10.10), also runs DNS  |
| DNS forwarder     | 1.1.1.1                            |
| My admin account  | LAB\beau.admin (Domain Admins)     |

Passwords (DSRM, beau.admin, temp user password) are in my password manager.

## OU structure
'''
lab.internal
└── LAB
    ├── Staff
    ├── Faculty
    ├── Students
    ├── Admins
    ├── Lab Computers
    ├── Servers
    └── Groups
'''

## Groups
| Group        | Members        |
|--------------|----------------|
| GG-Staff     |8               |
| GG-Faculty   |8               |
| GG-Students  |9               |
| GG-IT Admins |1               |

## Decisions and why
- Everything under one LAB OU because: AD’s built-in Users and Computers containers can’t have Group Policy linked to them. Putting everything under my own OU lets me apply GPOs and delegate admin rights exactly where I want.
- Named admin account instead of Administrator because: To help with accountability for different admins. Logs show which person made each change, and the built-in Administrator is the first account attackers try.
- Reverse zones stored in AD (ReplicationScope Domain) because: Zones stored in AD replicate automatically to every DC, so DC02 gets a copy next week with no extra setup

## What broke and how I fixed it

### 1. FW01 lost its configuration after a reboot
- Symptom: After a reboot, FW01’s console showed factory-default IPs (LAN 192.168.1.1) and none of my settings.
- Cause: OPNsense was running from the installer ISO in memory (live mode). It was never installed to the disk, so everything disappeared on reboot. That’s also why the default password opnsense worked.
- How I found it: The console’s interface list didn’t match my setup.
- Fix: Logged in as installer, installed to disk, removed the ISO, reconfigured.
- Lesson: Reboot and confirm a change survives before calling it done.

### 2. DC01 couldn't resolve internet names ("DNS server failure")
- Symptom: Can't access the internet.
- Cause: FW01 lost it's configuration so traffic is not being routed correctly.
- How I found it: ping 1.1.1.1 replied “Destination host unreachable” from DC01’s own IP, so traffic never left DC01. That pointed to the gateway (FW01), not DNS.
- Fix: Reinstall FW01 with the correct configuration.
- Lesson: A DNS error isn’t always a DNS problem. Check the network path one hop at a time.

### 3. User import script failed
- Symptom: The following script does not import the users correctly when ran with powershell. 

Script: scripts/Import-LabUsers.ps1

- Cause: Read-Host grabbed the next pasted line and assigned it to the $pw variable.
- Fix: Run the first line of the script first and set the temporary password, then run the rest of the script.

## Done-when tests
| Test                                   | Result |
|----------------------------------------|--------|
| User count under OU=LAB (expect 26)    |26      |
| Get-ADGroupMember GG-Faculty (expect 8)|8       |
| nslookup dc01.lab.internal             |10.10.10.10|
| nslookup 10.10.10.10                   |dc01.lab.internal|
| nslookup fw01.lab.internal             |10.10.10.1|
| nslookup 10.10.10.1                    |fw01.lab.internal|
| dcdiag /q                              |warning |

## What I'd say in an interview
1. What does the _ldap._tcp.dc._msdcs SRV record do, and why does a
   client need it?
When a computer joins the domain or a user logs on, Windows asks DNS for _ldap._tcp.dc._msdcs.lab.internal. DNS answers with the domain controller’s name and port (DC01, port 389). Without that record, clients get “the domain could not be contacted,” so they can’t join or log on.

2. Why should a DC point its DNS at itself and not at 8.8.8.8?
AD stores its SRV records in the DC’s own DNS. 8.8.8.8 knows nothing about lab.internal, so a DC pointed there can’t find itself or other DCs, and logons and replication break. Internet names still resolve through the forwarder.

3. What's the difference between an OU and a security group?
An OU is a folder used to organized groups of people or computers. Security groups give access to specific resources and can be given to users within an OU. OUs are also where you link Group Policy and delegate admin rights. You can’t give an OU permissions on a share, and you can’t link a GPO to a group.

## Still unsure about
- How a client actually joins the domain.