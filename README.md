# nftables + tproxy + redsocks2 实现SOCKS5(TCP/UDP)透明代理



**使用nftables重定向流量**

```shell
define whitelist = {
    0.0.0.0/8,
    10.0.0.0/8,
    127.0.0.0/8,
    169.254.0.0/16,
    172.16.0.0/12,
    192.0.0.0/24,
    192.0.2.0/24,
    192.88.99.0/24,
    192.168.0.0/16,
    198.18.0.0/15,
    198.51.100.0/24,
    203.0.113.0/24,
    224.0.0.0/4,
    240.0.0.0-255.255.255.255
}

define TCP_PROXY_PORT = 12345

define UDP_PROXY_PORT = 12346

table inet mangle {
    set byp4 {
        typeof ip daddr
        flags interval
        elements = $whitelist
    }


    chain prerouting {
        type filter hook prerouting priority mangle; policy accept;
        ip daddr @byp4 return
        meta l4proto tcp tproxy to :$TCP_PROXY_PORT meta mark set 0x00000440 accept
        meta l4proto udp tproxy to :$UDP_PROXY_PORT meta mark set 0x00000440 accept
    }
    
    # Only for local mode
    chain output {
        type route hook output priority mangle; policy accept;
        ip daddr @byp4 return
        meta l4proto tcp meta mark set 0x00000440
        meta l4proto udp meta mark set 0x00000440
    }
}
```



**设置路由，给流量打上标记**

```shell
ip rule add fwmark 1088 table 100
ip route add local default dev lo table 100
```



**主要参考（含有ipv6设置）**

> https://github.com/heiher/hev-socks5-tproxy



**redsocks2配置**

```
base {
        log_debug = off;
        log_info = on;
        log = stderr;
        daemon = on;

        // nftables要设置成generic
        redirector = generic;

        reuseport = off;
}

redsocks {
        local_ip = 0.0.0.0;
        local_port = 12345;

        ip = 10.8.1.253;
        port = 1080;
        type = socks5;

        autoproxy = 0;
        timeout = 10;
}

redudp {
        local_ip = 10.9.250.99;
        local_port = 12346 ;

        ip = 10.8.1.253;
        port = 1080;
        type = socks5;

        udp_timeout = 30;
}
```



**redsocks2**

> https://github.com/semigodking/redsocks
