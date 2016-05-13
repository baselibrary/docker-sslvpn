## ThoughtWorks Docker Image: sslvpn

[![](http://dockeri.co/image/baselibrary/sslvpn)](https://registry.hub.docker.com/u/baselibrary/sslvpn/)

### SSLVPN Docker Image

* `latest`: sslvpn 1.0
* `1.0`   : sslvpn 1.0

### Installation

  docker pull baselibrary/sslvpn:1.0

### Usage

  目前支持的SSLVPN类型:
    * Fortinet
    * OpenVPN

  Fortinet的使用方法:
  	docker run -d --device /dev/ppp --cap-add=NET_ADMIN -e VPN_USER=username -e VPN_PASS=password -e VPN_TYPE=fortinet --net=host baselibrary/sslvpn:1.0 --args

  	* 挂载 --device /dev/ppp 设备
  	* 通过环境变量设置VPN类型
  	* 通过环境变量设置用户名和密码
  	* 必须使用主机网络
  	* --cap-add=NET_ADMIN 设置容器操作网络的权限


  OpenVPN的使用方法:
  	docker run -d --device /dev/net/tun --cap-add=NET_ADMIN -v /var/lib/sslvpn:/var/lib/sslvpn -e VPN_USER=username -e AUTH_SEED=XXX -e VPN_TYPE=openvpn --net=host baselibrary/sslvpn:1.0 --client --remote $IP $PORT --dev tun --proto tcp --resolv-retry infinite --ca /var/lib/sslvpn/ca.crt --cert /var/lib/sslvpn/my_id.crt --key /var/lib/sslvpn/id.key --tls-auth /var/lib/sslvpn/ta.key 1 --remote-cert-tls server --nobind --comp-lzo --persist-key --persist-tun --auth-user-pass

  	* 挂载 --device dev/net/tun 设备
  	* 通过环境变量设置VPN类型
  	* 通过环境变量设置用户名和密码
  	* 可以使用主机网络或容器网络
  	* --cap-add=NET_ADMIN 设置容器操作网络的权限
  	* 支持密码和Google Authenticator Token两种认证方式，使用Google Authenticator Token时候设置环境变量AUTH_SEED (16位种子代码)


  可以通过环境变量来改变SSH相关的设置，如果不设置任何SSH相关变量，SSH服务默认不启动:
  	*AUTHORIZED_KEYS  SSH的authorized key
  	*SSH_PASS  SSH的密码(用户root)
  	*SSH_PORT  SSH服务的端口


