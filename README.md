 SSLVPN All In One Docker Image: `baselibrary/sslvpn`
=========

 封装常用的SSLVPN客户端，自动连接设置的VPN并启动SSH和Socks 5 代理.

[![](http://dockeri.co/image/baselibrary/sslvpn)](https://registry.hub.docker.com/u/baselibrary/sslvpn/)

## 支持的TAGS
- `latest`
- `1.0`   

## 如何使用
### 启动一个实例
    
    docker run -d \
      --device /dev/ppp \
      --cap-add=NET_ADMIN \
      -e VPN_TYPE=fortinet \
      -e VPN_HOST=IP \
      -e VPN_PORT=10443
      -e VPN_USER=username \
      -e VPN_PASS=password \
      baselibrary/sslvpn:1.0

## Environment Variables
### VPN_TYPE
目前支持以下两种类型的VPN厂商

- `fortinet`
- `openvpn`

### VPN_HOST
>适用VPN类型: 所有

远程VPN服务器的地址

### VPN_USER
>适用VPN类型: 所有

连接VPN的账户的用户名

### VPN_PASS
>适用VPN类型: 所有

连接VPN的账户的密码

### VPN_SEED
>适用VPN类型: OpenVPN

如果使用`Google Authenticator`的认证方式，设置16位种子

### VPN_ROUTE
>适用VPN类型: 所有

如果需要自定义连接VPN后的路由，通过设置VPN_ROUTE为需要路由的源地址，如:   `10.138.111.0/255.255.255.0`

### VPN_CA
>适用VPN类型: OpenVPN

OpenVPN的CA证书.

### VPN_CLIENT_CERT
>适用VPN类型: OpenVPN

OpenVPN的客户端\用户证书.

### VPN_CLIENT_KEY
>适用VPN类型: OpenVPN

OpenVPN的客户端\用户证书的KEY.

### VPN_TLS_AUTH
>适用VPN类型: OpenVPN

OpenVPN的TLS auth key.

### VPN_TRUSTED_CERT
>适用VPN类型: Fortinet

Fortinet VPN信任的证书sha签名.

### SSH_PORT
>适用VPN类型: 所有

SSH的端口，默认`20022`.

### SSH_PASS
>适用VPN类型: 所有

SSH的密码，默认为空，不设置.

### AUTHORIZED_KEYS
>适用VPN类型: 所有

SSH的AUTHORIZED KEYS，默认为空，不设置.

### SOCK_PORT
>适用VPN类型: 所有

SOCK代理的端口，默认`10080`.

### SOCK_PASS
>适用VPN类型: 所有

SOCK代理的密码，默认为空，不设置.


 
## 注意 

+ SSLVPN需要挂载相应的设备:
   OpenVPN需要挂载`/dev/net/tun`
   Fortinet需要挂载`/dev/ppp`
+ 启动容器必须给实例设置网络管理的权限，使用如下参数:
   `--cap-add=NET_ADMIN`
+ Fortinet的VPN采用ppp协议，需要使用host网络
+ 可以通过环境变量来改变SSH相关的设置，如果不设置任何SSH相关变量，SSH服务默认不启动

 
