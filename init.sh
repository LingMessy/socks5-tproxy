chmod +x ./socks5-tproxy.sh
cp ./socks5-tproxy.service /etc/systemd/system/
systemctl start socks5-tproxy.service
systemctl enable socks5-tproxy.service
