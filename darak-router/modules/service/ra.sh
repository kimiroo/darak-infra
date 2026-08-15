# Clear RA config
delete service router-advert

# Prefix, DNS suffix
for vid in 5 10 20 30 70 80 90 99; do
set service router-advert interface "br0.${vid}" prefix "fdab:d9c3:fb50:${vid}::/64"
set service router-advert interface "br0.${vid}" dnssl 'internal.darak.dev'
done

# Nameservers
set service router-advert interface br0.5 name-server 2a07:a8c0::ef:3c69
set service router-advert interface br0.5 name-server 2a07:a8c1::ef:3c69

set service router-advert interface br0.10 name-server 2a07:a8c0::ef:3c69
set service router-advert interface br0.10 name-server 2a07:a8c1::ef:3c69

set service router-advert interface br0.20 name-server 2a07:a8c0::12:2774
set service router-advert interface br0.20 name-server 2a07:a8c1::12:2774

set service router-advert interface br0.30 name-server 2a07:a8c0::59:cb3b
set service router-advert interface br0.30 name-server 2a07:a8c1::59:cb3b

set service router-advert interface br0.70 name-server 2a07:a8c0::4d:fa1f
set service router-advert interface br0.70 name-server 2a07:a8c1::4d:fa1f

set service router-advert interface br0.80 name-server 2a07:a8c0::5a:4515
set service router-advert interface br0.80 name-server 2a07:a8c1::5a:4515

set service router-advert interface br0.90 name-server 2a07:a8c0::4d:fa1f
set service router-advert interface br0.90 name-server 2a07:a8c1::4d:fa1f

set service router-advert interface br0.99 name-server fdab:d9c3:fb50:99::1