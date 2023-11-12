(!) Use at your own risk, make sure you have alternative ways to access your server before making changes to firewall (like KVM etc.).

It is basically a convenient way to block countries by IP with iptables. Step-by-step instructions are combined into one Makefile to compile and optimize multiple ip blocks. Only three iptables rule added as a result, which is easily revertable. Two systemd services run at system startup and load ip lists to keep geoblock persistent.

## Prereqs

Geoip lists downloaded from [countryipblocks.net](https://www.countryipblocks.net/acl.php), select countries and CIDR format. 
Save lists into files in `lists/` folder. A couple of useful lists are provided as an example. Multiple lists will be automatically combined and optimized. Remember to update lists from time to time.

Install `iprange` and `ipset` with:

	sudo apt install -y iprange ipset

## Installation

`make add` will copy everything where it supposed to be and start services: 

	sudo make add 

To check services status:

	sudo make status

Only one iptables rule is added as a result. To delete geoblock rule from iptables:

	sudo make cleanup

To uninstall - stop and remove services, iptables rule and ipset list:

	sudo make uninstall

## How it works

After combining and optimizing every list from `lists` folder into one `geoblock.txt` file, new `geoblock` list is created with `ipset`, then every line from `geoblock.txt` is put into that list, finally the list is saved to `/etc/ipset.conf` file.

Then there are two systemd services:

- `ipset-persistent.service` is configured so it starts at the right time in server startup sequence and loads `/etc/ipset.conf`, so `geoblock` set is loaded and ready to be used by iptables.
- `geoblock-persistent.service` starts next and runs a script that sets up a firewall rule to block incoming traffic from IP addresses listed in the `geoblock` set, log the blocked attempts up to a limit, and then drop the packets.

## Some sources that were used to make this

### iptables man:

https://www.digitalocean.com/community/tutorials/how-to-list-and-delete-iptables-firewall-rules

### country ban gist:

https://gist.github.com/jasonruyle/8870296

### persistent ipset manual

https://selivan.github.io/2018/07/27/ipset-save-with-ufw-and-iptables-persistent-and.html

## Contributors

- [nisenbeck](https://github.com/nisenbeck) - added rate limited logging of blocked packets