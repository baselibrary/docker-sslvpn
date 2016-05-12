FROM baselibrary/python:2.7
MAINTAINER ShawnMa <qsma@thoughtworks.com>

## Packages
RUN \
  apt-get update &&\
  apt-get install -y expect ppp iptables openvpn openssh-server &&\
  pip install gacli &&\
  rm -rf /var/lib/apt/lists/*
COPY package /opt/sslvpn/

## Configurations
RUN \
  mkdir -p /var/run/sshd &&\
  sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config &&\
  sed -i "s/UsePAM.*/UsePAM no/g"                                 /etc/ssh/sshd_config &&\
  sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g"              /etc/ssh/sshd_config

## Environments
ENV VPN_TYPE  ""
ENV VPN_USER  ""
ENV VPN_PASS  ""
ENV TOTP_SEED ""
ENV PYTHONIOENCODING UTF-8

## Scripts
ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod a+x            /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

VOLUME ["/var/lib/sslvpn"]

