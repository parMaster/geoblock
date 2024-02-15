CODES := $(filter-out $@,$(MAKECMDGOALS))
BASE_URL := https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/
load:
# Loads the IP ranges for the specified country code from the herrbischoff/country-ip-blocks repository
# Usage: make load <country-code> <country-code> ...
# Example: make load ch ru by
# Note, that error message like "make: *** No rule to make target 'ch'.  Stop." is expected
	@for code in $(CODES); do \
		curl -s $(BASE_URL)$$code.cidr > lists/$$code.cidr; \
	done
	@echo "Download complete!"

cleanup:
	iptables -D INPUT -m set --match-set geoblock src -j LOGGING || true
	iptables -D LOGGING -m limit --limit 10/min -j LOG --log-prefix "geoblock: " --log-level 6 || true
	iptables -D LOGGING -j DROP || true
	iptables -X LOGGING || true
	ipset destroy geoblock || true

add:
	iprange --optimize lists/* > geoblock.txt
	ipset create geoblock hash:net
	while read line; do ipset add geoblock $$line; done < geoblock.txt
	touch /etc/ipset.conf
	ipset save > /etc/ipset.conf
	make service-deploy

service-deploy:
	cp geoblock.sh /usr/local/bin/
	chmod +x /usr/local/bin/geoblock.sh
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
	rm /usr/local/bin/geoblock.sh

.PHONY: cleanup add service-deploy status uninstall load
