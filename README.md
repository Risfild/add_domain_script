# add_domain_script
Script for automatic adding of domains to DHCP config

This script is intended for use after installing automatic routing by domains from this repository: https://github.com/itdoginfo/domain-routing-openwrt

Script functionality:
1) Adding new domains to the dhcp config and checking the domain for validity using nslookup
2) Removing from the list of domains
3) Displaying the list of domains
4) Automatically restarting the dnsmasq service when exiting the script to apply changes

How to use the script?
1) Download the script to a router with openWRT firmware and domain-routing installed and configured from https://github.com/itdoginfo/domain-routing-openwrt
2) Mark the script as executable using chmod +x add_domain.sh
3) Run the script and follow the instructions

Example of a script execution:
![изображение](https://github.com/user-attachments/assets/79235a83-5b09-49d1-9861-605062b97304)

Many thanks to @itdoginfo for providing the guide on setting up domain routing!
