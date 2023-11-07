#!/bin/bash

iptables -N LOGGING
iptables -A INPUT -m set --match-set geoblock src -j LOGGING
iptables -A LOGGING -m limit --limit 10/min -j LOG --log-prefix "geoblock: " --log-level 6
iptables -A LOGGING -j DROP
