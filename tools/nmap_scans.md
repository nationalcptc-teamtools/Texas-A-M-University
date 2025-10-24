# INITIAL ENUMERATION STEPS FOR ALL MACHINES

DO NOT SCAN ANY OT NETWORK IPs, TRIPLE CHECK TO ENSURE THE RANGES DO NOT INCLUDE OT OR ANY OUT-OF-SCOPE ELEMENTS.

### Multimap

For an explicit list of IPs to scan (triple scan approach), use multimap.sh and specify the specific IPs. This should be done only once the specific Live Hosts are identified.

### Ping Sweep

Ensure to exclude the OT subnet by creating an `exclude_ot.txt` file. DO NOT SCAN THE OT SUBNET WITH THESE COMMANDS.

To be safe, run the `iptables.sh` script after updating it with the out-of-scope IPs.

Put the live IPs into a list OR use the subnet itself:

`nmap -sn 192.168.1.0/24 --open --exclude-file exclude_ot.txt -oG subnet_1.gnmap`
`cat subnet_1.gnmap | grep "Up" | cut -d " " -f2 > live_hosts_<subnet>.txt`

If we get a big subnet like /16s, always a good idea to run a `masscan` to identify LIVE HOSTS and then feed them into service scans next.
EXCLUDE OT AND OTHER OUT-OF-SCOPE ITEMS.

`masscan 10.0.0.1/24 --excludeFile <file> --rate 10000 --open-only -oL output.txt`

### Service and Port Scans

It is recommended to use multimap for this, but up to you.

### Version and Vulnerability Checks

In addition to automatic checks, manually search service and OS version numbers.

`nmap -sV --script=vuln,vulners --open -p <ports> <target>`
`searchsploit "<Product> <version>"`

### UDP Scans

It is recommended to use multimap for this, but up to you.

### Web Screenshotting Tools

Using tools like `aquatone` or `EyeWitness` it can be very easy to compile web screenshots and try out default credentials in an automated way. Once you have a list of web ports/IPs that can be extracted from `nmap` output, consider feeding them into a screenshotting tool to get a report:

EyeWitness:
`sudo ./EyeWitness.py -x /path/to/nmap.xml --web ---threads 10 --timeout 30 --headless -d /path/to/screens`

### Sharing Outputs

NMAP Scan outputs (and those from multimap) should be saved in OneNote / Teams. Ensure that the data is only stored locally, as customer data must not leave the network.


