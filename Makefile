cleanup:
	iptables -D INPUT -m set --match-set geoblock src -j DROP || true
	ipset destroy geoblock

add:
	iprange --optimize lists/* > geoblock.txt
	ipset create geoblock hash:net
	while read line; do ipset add geoblock $$line; done < geoblock.txt
	touch /etc/ipset.conf
	ipset save > /etc/ipset.conf
	make service-deploy

service-deploy:
	cp ipset-persistent.service /etc/systemd/system/
	cp geoblock-persistent.service /etc/systemd/system/
	systemctl daemon-reload
	systemctl enable ipset-persistent.service 
	systemctl start ipset-persistent.service 
	systemctl enable geoblock-persistent.service 
	systemctl start geoblock-persistent.service 

status:
	sudo systemctl status ipset-persistent.service
	sudo systemctl status geoblock-persistent.service

uninstall:
	make cleanup
	systemctl stop ipset-persistent.service
	systemctl stop geoblock-persistent.service
	systemctl disable ipset-persistent.service
	systemctl disable geoblock-persistent.service
	rm /etc/systemd/system/ipset-persistent.service
	rm /etc/systemd/system/geoblock-persistent.service
	systemctl daemon-reload
	rm /etc/ipset.conf

.PHONY: cleanup add service-deploy status uninstall
