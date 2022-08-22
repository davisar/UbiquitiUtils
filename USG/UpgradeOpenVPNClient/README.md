# Upgrade Open VPN Client

## The Problem
The USG has an out of date version of the OpenVPN Client which Ubiquiti seems to have decided is not particularly necessary to keep up to date.

The result of this is that if you are attempting to route traffic from your network out over a VPN service using OpenVPN this may fail if the VPN service that you are using requires TLS 1.2.

The version of the OpenVPN client that comes with the current (as of August 2022) firmware is version 2.3.2. This client version does not support TLS 1.2.

After logging into the USG you can check the version currently running by running `sudo openvpn --version`

## Symptoms and/or Issue Repro

### TLS Handshake errors (Unconfirmed)

```
Aug 21 17:19:29 ubnt openvpn[2850]: TLS Error: TLS key negotiation failed to occur within 60 seconds (check your network connectivity)
Aug 21 17:19:29 ubnt openvpn[2850]: TLS Error: TLS handshake failed
```

## Running the script

1. Get your connection and account info to connect to the USG
1. SSH to the USG using your SSH client of choice (note: on Windows 11 and most unix/linux machines you can just open up the command prompt and use `ssh`)
1. Also open a file copying client (ex: Filezilla) and connect to the USG
    1. Copy the UpgradeOpenVPN.sh script to the USG (recommended destination location: `/home/<your_user>/`)
1. In the SSH Client perform the following actions:
    1. (optional) run `sudo openvpn --version` to verify the current version.
    1. Move to the directory where the script is stored. If following along you can do `cd ~` to get to your user's home directory.
    1. run the command: `sudo ./UpgradeOpenVPN.sh`
        - this runs the command as the `root` user. This is necessary for the high-privileged operations that are necessary.
        - Note that this command will take a while as there are a lot of packages to install and manage.

## What the script does
This script verifies that you are running as root and then takes the following (general) actions:
- Updates packages
- Installs new packages
- Downloads OpenVPN 2.4.12
- Configures & Installs the updated OpenVPN Client

# Credit where credit is due
Lots of people blazing the way, but especially to effectual and nvitija on the community.ui.com forums. You can find the [thread on how to do it all here](https://community.ui.com/questions/Connect-your-Unifi-USG-to-a-VPN-Provider-Includes-config-for-optional-extra-wireless-networks-per-c/67d49971-1841-4ccc-b0a1-71e3aaf6eb6a#answer/f9f7fb01-f9a9-47af-8986-5b95c016132a) - I've really just taken the extra step of wrapping it up in a script.