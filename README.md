## Prereqs

Geoip lists downloaded from [countryipblocks.net](https://www.countryipblocks.net/acl.php), select countries and CIDR format. 
Save lists into files in `lists/` folder

	- sudo apt install -y iprange ipset
	- make add 
	- make service-deploy
	- make status


## iptables man:

https://www.digitalocean.com/community/tutorials/how-to-list-and-delete-iptables-firewall-rules

## country ban gist:

https://gist.github.com/jasonruyle/8870296

## persistent ipset manual

https://selivan.github.io/2018/07/27/ipset-save-with-ufw-and-iptables-persistent-and.html
