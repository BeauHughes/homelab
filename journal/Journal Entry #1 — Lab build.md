# Journal Entry #1 — Lab build (Nov 16–22, 2026)

## What I built
Hyper-V lab with a firewall, a server and a client on two subnets.

## Network
| VM   | Role                  | IP           | Network      |
|------|-----------------------|--------------|--------------|
| FW01 | OPNsense firewall     | 10.10.10.1   | LAN-Servers  |
|      |                       | 10.10.20.1   | LAN-Clients  |
|      |                       | DHCP (home)  | WAN          |
| DC01 | Windows Server 2025   | 10.10.10.10  | LAN-Servers  |
| CL01 | Windows 11 Enterprise | 10.10.20.50  | LAN-Clients  |

Accounts (passwords in password manager): root on FW01,
Administrator on DC01, user on CL01.

## Decisions and why
- Two subnets so DHCP relay, DNS and firewall rules have to work.
- Secure Boot off on FW01: OPNsense won't boot with it on.
- Full VM wizard, not Quick Create: needed control over memory and adapters.

## What broke and how I fixed it
- Symptom: After a reboot, FW01 rejected my password and DC01 lost internet (“Destination host unreachable”).
- Cause: OPNsense was running from the installer in memory, not installed to disk, so its configuration disappeared on reboot.
- Fix: Installed OPNsense to disk, removed the ISO, and reconfigured.

- Symptom: Quick Create only let me attach FW01 to one virtual switch, but it needs three.
- Cause: Hyper-V only connects one network adapter when a VM is created (Quick Create
  and the full wizard both work this way). Quick Create also picks defaults, like
  dynamic memory, that OPNsense doesn't handle well.
- Fix: Rebuilt FW01 with the full New Virtual Machine wizard, then added the second
  and third adapters in Settings → Add Hardware → Network Adapter.

## What I'd say in an interview
CL01 sends anything outside its own subnet to its default gateway, 10.10.20.1, which is FW01’s client interface. FW01 checks the traffic against the firewall rule I added for the client network, then uses NAT to swap CL01’s private address for its own WAN address and sends it out to my home router. DNS lookups go to FW01’s resolver first.

## Still unsure about
- How to set up the domain controller and connect to the domain on the client.