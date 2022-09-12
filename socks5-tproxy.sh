#!/bin/bash 

nft -f ./nft.conf

ip rule add fwmark 1088 table 100
ip route add local default dev lo table 100

redsocks2 -c ./redsocks2.conf

