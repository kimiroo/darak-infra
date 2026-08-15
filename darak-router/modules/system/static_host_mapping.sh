# Clear static host mapping config
delete system static-host-mapping

# darak-router
set system static-host-mapping host-name 'darak-router.internal.darak.dev' inet '10.5.0.1'
set system static-host-mapping host-name 'darak-router.internal.darak.dev' inet 'fdab:d9c3:fb50:5::1'

# darak-ap-01
set system static-host-mapping host-name 'darak-ap-01.internal.darak.dev' inet '10.5.0.10'
set system static-host-mapping host-name 'darak-ap-01.internal.darak.dev' inet 'fdab:d9c3:fb50:5::10'

# darak-ap-02
set system static-host-mapping host-name 'darak-ap-02.internal.darak.dev' inet '10.5.0.20'
set system static-host-mapping host-name 'darak-ap-02.internal.darak.dev' inet 'fdab:d9c3:fb50:5::20'



# pve-node-01
set system static-host-mapping host-name 'pve-node-01.internal.darak.dev' inet '10.10.10.10'
set system static-host-mapping host-name 'pve-node-01.internal.darak.dev' inet 'fdab:d9c3:fb50:10:10::10'

# pve-node-02
set system static-host-mapping host-name 'pve-node-02.internal.darak.dev' inet '10.10.10.20'
set system static-host-mapping host-name 'pve-node-02.internal.darak.dev' inet 'fdab:d9c3:fb50:10:10::20'

# pve-node-03
set system static-host-mapping host-name 'pve-node-03.internal.darak.dev' inet '10.10.10.30'
set system static-host-mapping host-name 'pve-node-03.internal.darak.dev' inet 'fdab:d9c3:fb50:10:10::30'

# pve-node-04
set system static-host-mapping host-name 'pve-node-04.internal.darak.dev' inet '10.10.10.40'
set system static-host-mapping host-name 'pve-node-04.internal.darak.dev' inet 'fdab:d9c3:fb50:10:10::40'

# file-node-01
set system static-host-mapping host-name 'file-node-01.internal.darak.dev' inet '10.10.10.50'
set system static-host-mapping host-name 'file-node-01.internal.darak.dev' inet 'fdab:d9c3:fb50:10:10::50'

# pi-node-01
set system static-host-mapping host-name 'pi-node-01.internal.darak.dev' inet '10.10.10.60'
set system static-host-mapping host-name 'pi-node-01.internal.darak.dev' inet 'fdab:d9c3:fb50:10:10::60'



# rocky-master-01
set system static-host-mapping host-name 'rocky-master-01.internal.darak.dev' inet '10.10.20.11'
set system static-host-mapping host-name 'rocky-master-01.internal.darak.dev' inet 'fdab:d9c3:fb50:10:20::11'

# rocky-worker-01
set system static-host-mapping host-name 'rocky-worker-01.internal.darak.dev' inet '10.10.20.12'
set system static-host-mapping host-name 'rocky-worker-01.internal.darak.dev' inet 'fdab:d9c3:fb50:10:20::12'

# rocky-master-02
set system static-host-mapping host-name 'rocky-master-02.internal.darak.dev' inet '10.10.20.21'
set system static-host-mapping host-name 'rocky-master-02.internal.darak.dev' inet 'fdab:d9c3:fb50:10:20::21'

# rocky-worker-02
set system static-host-mapping host-name 'rocky-worker-02.internal.darak.dev' inet '10.10.20.22'
set system static-host-mapping host-name 'rocky-worker-02.internal.darak.dev' inet 'fdab:d9c3:fb50:10:20::22'

# rocky-master-03
set system static-host-mapping host-name 'rocky-master-03.internal.darak.dev' inet '10.10.20.31'
set system static-host-mapping host-name 'rocky-master-03.internal.darak.dev' inet 'fdab:d9c3:fb50:10:20::31'

# rocky-worker-03
set system static-host-mapping host-name 'rocky-worker-03.internal.darak.dev' inet '10.10.20.32'
set system static-host-mapping host-name 'rocky-worker-03.internal.darak.dev' inet 'fdab:d9c3:fb50:10:20::32'

# rocky-docker-01
set system static-host-mapping host-name 'rocky-docker-01.internal.darak.dev' inet '10.10.20.41'
set system static-host-mapping host-name 'rocky-docker-01.internal.darak.dev' inet 'fdab:d9c3:fb50:10:20::41'