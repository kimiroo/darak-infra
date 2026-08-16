# Delete HAProxy config
rm -rf /config/haproxy || true

# HAProxy Config File
mkdir -p /config/haproxy

tee /config/haproxy/haproxy.cfg << EOF
global
    maxconn 4096

defaults
    log global
    mode tcp
    timeout connect 5s
    timeout client 86400s
    timeout server 86400s

frontend k3s-api
    bind 10.45.20.1:6443
    mode tcp
    default_backend k3s-api-backend

backend k3s-api-backend
    mode tcp
    balance roundrobin
    option httpchk GET /readyz
    http-check expect status 401
    default-server check-ssl verify none inter 2s fall 2 rise 2
    server master-01 10.10.20.11:6443 check
    server master-02 10.10.20.21:6443 check
    server master-03 10.10.20.31:6443 check
EOF

# HAProxy Container
run add container image 'docker.io/library/haproxy:lts'

set container name k3s-api-haproxy image 'docker.io/library/haproxy:lts'
set container name k3s-api-haproxy allow-host-networks
set container name k3s-api-haproxy volume cfg source '/config/haproxy/haproxy.cfg'
set container name k3s-api-haproxy volume cfg destination '/usr/local/etc/haproxy/haproxy.cfg'
set container name k3s-api-haproxy volume cfg mode 'ro'