# Clear base system config
delete system host-name
delete system name-server
delete system time-zone
delete service ntp

# Configure base system
set system host-name darak-router

set system name-server 2a07:a8c0::ef:3c69
set system name-server 2a07:a8c1::ef:3c69
set system name-server 45.90.28.99
set system name-server 45.90.30.99

set system time-zone Asia/Seoul
set service ntp server ntp.kriss.re.kr prefer
set service ntp server pool.ntp.org pool