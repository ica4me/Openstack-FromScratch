# OpenStack Caracal HA From Scratch with Ansible

Project ini bertujuan membangun automation Ansible from scratch untuk OpenStack Caracal 2024.1 di Ubuntu 22.04 LTS.

Deployment ini package-based, bukan Kolla Ansible.

FullConf
```
git clone https://github.com/ica4me/Openstack-FromScratch.git openstack-caracal-ansible
```

## Topologi Lab

- 3 Controller
- 2 Compute
- 1 Deployer di luar cluster
- External Ceph cluster sudah tersedia
- VIP API: `172.16.2.200`

## Network

| NIC   | Fungsi                            | Subnet        | Catatan                                                        |
| ----- | --------------------------------- | ------------- | -------------------------------------------------------------- |
| NIC 1 | Management + API + Overlay VXLAN  | 172.16.2.0/24 | SSH, Ansible, API, HAProxy, Galera, RabbitMQ, Memcached, VXLAN |
| NIC 2 | Provider / External / Floating IP | 172.16.3.0/24 | Hanya bridge `br-ex`, tanpa IP host                            |
| NIC 3 | Storage / Ceph External Client    | 172.16.1.0/24 | Akses MON/OSD public Ceph                                      |

## Nodes

| Hostname      | Management IP |   Storage IP |
| ------------- | ------------: | -----------: |
| controller-01 |  172.16.2.211 | 172.16.1.211 |
| controller-02 |  172.16.2.212 | 172.16.1.212 |
| controller-03 |  172.16.2.213 | 172.16.1.213 |
| compute-01    |  172.16.2.221 | 172.16.1.221 |
| compute-02    |  172.16.2.222 | 172.16.1.222 |

## Daftar Service Systemd
keepalived
haproxy
mariadb
rabbitmq-server
memcached
apache2
keystone via apache/wsgi
glance-api
placement-api via apache/wsgi
nova-api
nova-scheduler
nova-conductor
nova-novncproxy
neutron-server
neutron-openvswitch-agent
neutron-l3-agent
neutron-dhcp-agent
neutron-metadata-agent
cinder-api
cinder-scheduler
cinder-volume
gnocchi-metricd
gnocchi-api via apache/wsgi
ceilometer-agent-central
ceilometer-agent-notification
aodh-api via apache/wsgi
aodh-evaluator
aodh-notifier
aodh-listener
masakari-api
masakari-engine
pacemaker
corosync
openvswitch-switch
libvirtd / virtqemud
nova-compute
neutron-openvswitch-agent
ceilometer-agent-compute
masakari-hostmonitor
masakari-instancemonitor
masakari-processmonitor
pacemaker
corosync
