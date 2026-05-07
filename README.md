# OpenStack Caracal HA From Scratch with Ansible

Automation Ansible untuk membangun OpenStack **Caracal 2024.1** di **Ubuntu Server 22.04 LTS / Jammy**.
Deployment ini menggunakan paket Ubuntu/OpenStack package-based dari Ubuntu Cloud Archive, bukan Kolla Ansible dan bukan DevStack.

Baseline repo ini dibuat diatas lab HA 5 node: **3 controller**, **2 compute**, 1 deployer di luar cluster, dan backend storage memakai **external Ceph RBD**.

---

## Dokumentasi

| Dokumen                                                                                                                                                             | Kegunaan                                                                                                            |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| [Full Step-by-Step Documentation](https://github.com/ica4me/Openstack-FromScratch/blob/main/Documentation/AUTOMASI-OPENSTACK-FROM-SCRATCH.md)                       | Panduan deployment dari awal, urutan playbook, struktur direktori, dan catatan konfigurasi utama.                   |
| [Basic Admin Operasional-CLI](https://github.com/ica4me/Openstack-FromScratch/blob/main/Documentation/AUTOMASI-OPENSTACK-FROM-SCRATCH/Admin%20Operasional%20CLI.md) | Operasional dasar setelah cluster hidup: image, flavor, network, router, floating IP, security group, dan VM test.  |
| [Final EndPoint list](https://github.com/ica4me/Openstack-FromScratch/blob/main/Documentation/AUTOMASI-OPENSTACK-FROM-SCRATCH/EndPoint.md)                          | Contoh hasil akhir service catalog dan endpoint OpenStack setelah deployment selesai.                               |
| [Testing HA Masakari](https://github.com/ica4me/Openstack-FromScratch/blob/main/Documentation/AUTOMASI-OPENSTACK-FROM-SCRATCH/Testing%20HA%20Masakari.md)           | Skenario pengujian instance HA menggunakan Masakari, termasuk metadata `HA_Enabled=True` dan simulasi host failure. |

---

## Target Platform

| Komponen          | Nilai baseline                                            |
| ----------------- | --------------------------------------------------------- |
| OS node           | Ubuntu Server 22.04 LTS / Jammy                           |
| OpenStack release | Caracal / 2024.1                                          |
| Repository paket  | Ubuntu Cloud Archive `cloud-archive:caracal`              |
| Deployment model  | Ansible from scratch, package-based                       |
| HA API            | Keepalived + HAProxy                                      |
| Database          | MariaDB Galera pada controller                            |
| Message broker    | RabbitMQ cluster pada controller                          |
| Cache             | Memcached pada controller                                 |
| Network backend   | Neutron ML2 + Open vSwitch                                |
| Tenant network    | VXLAN                                                     |
| Provider network  | Flat provider network via `br-ex`                         |
| Storage backend   | External Ceph RBD untuk Glance, Cinder, Nova, dan Gnocchi |
| Optional service  | Horizon, Telemetry, Masakari Instance HA                  |

> Catatan: playbook `00-preflight.yml` saat ini hanya memvalidasi OS Ubuntu **22.04**. Kalau dipakai untuk OS lain, validasi preflight dan nama paket service perlu disesuaikan.

---

## Topologi Lab

Baseline Node yang dipakai repo ini:

- 3 controller node
- 2 compute node
- 1 deployer node di luar cluster OpenStack
- External Ceph cluster sudah tersedia
- VIP API internal: `172.16.2.200`
- Region OpenStack: `RegionOne`
- FQDN internal API: `openstack-api.internal`

---

## Network

| NIC   | Fungsi                            | Subnet          | Catatan                                                                 |
| ----- | --------------------------------- | --------------- | ----------------------------------------------------------------------- |
| NIC 1 | Management + API + Overlay VXLAN  | `172.16.2.0/24` | SSH, Ansible, API, HAProxy, Galera, RabbitMQ, Memcached, VXLAN local IP |
| NIC 2 | Provider / External / Floating IP | `172.16.3.0/24` | Masuk ke bridge `br-ex`, tanpa IP host                                  |
| NIC 3 | Storage / Ceph External Client    | `172.16.1.0/24` | Akses ke Ceph MON/OSD public network                                    |

Default interface pada inventory Cluster:

| Fungsi               | Interface default |
| -------------------- | ----------------- |
| Management/API/VXLAN | `ens19`           |
| Provider/External    | `ens20`           |
| Storage/Ceph client  | `eth0`            |

Kalau nama NIC di server berbeda, ubah di `inventories/lab-5node/hosts.yml` dan `inventories/lab-5node/group_vars/network.yml` sebelum menjalankan playbook network.

---

## Nodes

| Inventory | Hostname OS     |  Management IP |     Storage IP | Provider NIC | Catatan                                             |
| --------- | --------------- | -------------: | -------------: | ------------ | --------------------------------------------------- |
| `ctrl01`  | `controller-01` | `172.16.2.211` | `172.16.1.211` | `ens20`      | Controller bootstrap, priority Keepalived tertinggi |
| `ctrl02`  | `controller-02` | `172.16.2.212` | `172.16.1.212` | `ens20`      | Controller                                          |
| `ctrl03`  | `controller-03` | `172.16.2.213` | `172.16.1.213` | `ens20`      | Controller                                          |
| `cmp01`   | `compute-01`    | `172.16.2.221` | `172.16.1.221` | `ens20`      | Compute + Masakari monitor                          |
| `cmp02`   | `compute-02`    | `172.16.2.222` | `172.16.1.222` | `ens20`      | Compute + Masakari monitor                          |

## ![](files/019dd308-391f-7131-ac66-2dd4d8643f9e/image.png)

## Struktur Repository

Struktur utama repo ini dibuat sederhana supaya mudah ditrace saat troubleshooting:

```text
openstack-caracal-ansible/
├── ansible.cfg
├── requirements.yml
├── site.yml
├── Makefile
├── README.md
├── admin-openrc-scratch
│
├── inventories/
│   └── lab-5node/
│       ├── hosts.yml
│       ├── group_vars/
│       │   ├── all.yml
│       │   ├── ceph.yml
│       │   ├── controllers.yml
│       │   ├── computes.yml
│       │   ├── network.yml
│       │   ├── openstack.yml
│       │   └── vault.yml
│       └── host_vars/
│           ├── ctrl01.yml
│           ├── ctrl02.yml
│           ├── ctrl03.yml
│           ├── cmp01.yml
│           └── cmp02.yml
│
├── playbooks/
│   ├── 00-preflight.yml
│   ├── 01-base.yml
│   ├── 02-network.yml
│   ├── 03-ceph-client.yml
│   ├── 04-ha-vip-lb.yml
│   ├── 05-database.yml
│   ├── 06-message-cache.yml
│   ├── 07-keystone.yml
│   ├── 08-image-placement.yml
│   ├── 09-nova.yml
│   ├── 10-neutron.yml
│   ├── 11-cinder.yml
│   ├── 12-horizon.yml
│   ├── 13-telemetry.yml
│   ├── 14-instance-ha.yml
│   └── 99-validate.yml
│
├── roles/
│   ├── base/
│   ├── ceph/
│   ├── ha/
│   ├── infra/
│   ├── network/
│   ├── openstack/
│   └── validation/
│
└── files/
    └── ceph/
        ├── ceph.conf
        ├── ceph.client.glance.keyring
        ├── ceph.client.cinder.keyring
        ├── ceph.client.nova.keyring
        └── ceph.client.gnocchi.keyring
```

---

## Clone dan Persiapan Deployer

```bash
git clone https://github.com/ica4me/Openstack-FromScratch.git openstack-caracal-ansible
cd openstack-caracal-ansible

ansible-galaxy collection install -r requirements.yml
ansible-inventory -i inventories/lab-5node/hosts.yml --graph
ansible -i inventories/lab-5node/hosts.yml all -m ping
```

Jika memakai `Makefile`:

```bash
make ping
make graph
make preflight
make all
```

Atau jalankan langsung:

```bash
ansible-playbook -i inventories/lab-5node/hosts.yml site.yml
```

---

## Urutan Deployment

Urutan ini Harus mengikuti `site.yml`:

| Phase | Playbook                 | Fungsi                                                                          |
| ----- | ------------------------ | ------------------------------------------------------------------------------- |
| 00    | `00-preflight.yml`       | Validasi OS, hostname, inventory, IP, NIC, VIP, dan akses Ceph MON              |
| 01    | `01-base.yml`            | Paket dasar, NTP/Chrony, Cloud Archive Caracal, hardening ringan, kernel tuning |
| 02    | `02-network.yml`         | Netplan, Open vSwitch, `br-ex`, provider interface                              |
| 03    | `03-ceph-client.yml`     | Deploy `ceph.conf`, keyring, dan validasi pool RBD                              |
| 04    | `04-ha-vip-lb.yml`       | Keepalived VIP dan HAProxy API frontend/backend                                 |
| 05    | `05-database.yml`        | MariaDB Galera                                                                  |
| 06    | `06-message-cache.yml`   | RabbitMQ cluster dan Memcached                                                  |
| 07    | `07-keystone.yml`        | Keystone Identity via Apache WSGI                                               |
| 08    | `08-image-placement.yml` | Glance dan Placement                                                            |
| 09    | `09-nova.yml`            | Nova controller dan Nova compute                                                |
| 10    | `10-neutron.yml`         | Neutron ML2/OVS, L3, DHCP, metadata agent                                       |
| 11    | `11-cinder.yml`          | Cinder dengan backend Ceph RBD                                                  |
| 12    | `12-horizon.yml`         | Horizon dashboard                                                               |
| 13    | `13-telemetry.yml`       | Gnocchi, Aodh, Ceilometer. Aktif jika `enable_telemetry: true`                  |
| 14    | `14-instance-ha.yml`     | Masakari Instance HA. Aktif jika `enable_masakari: true`                        |
| 99    | `99-validate.yml`        | Validasi service systemd, endpoint API, dan smoke test OpenStack                |

---

## Daftar Service Systemd

Daftar di bawah ini dirapikan berdasarkan role node. Beberapa API tidak punya service systemd sendiri karena memang dijalankan lewat Apache WSGI.

### Controller

| Layer          | Service systemd                                                                                                                    | Catatan                                                                 |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| HA API         | `keepalived`, `haproxy`                                                                                                            | VIP `172.16.2.200` dan load balancer API OpenStack                      |
| Database       | `mariadb`                                                                                                                          | Galera cluster pada controller                                          |
| Message broker | `rabbitmq-server`                                                                                                                  | RabbitMQ cluster untuk oslo.messaging                                   |
| Cache          | `memcached`                                                                                                                        | Token/session/cache backend                                             |
| Web/API WSGI   | `apache2`                                                                                                                          | Keystone, Placement API, Cinder API, Gnocchi API, Aodh API, dan Horizon |
| Image          | `glance-api`                                                                                                                       | Glance API standalone, backend image ke Ceph RBD                        |
| Placement      | `apache2`                                                                                                                          | `placement-api` berjalan lewat Apache WSGI                              |
| Nova           | `nova-api`, `nova-scheduler`, `nova-conductor`, `nova-novncproxy`                                                                  | Control plane compute                                                   |
| Neutron        | `neutron-server`, `neutron-openvswitch-agent`, `neutron-l3-agent`, `neutron-dhcp-agent`, `neutron-metadata-agent`                  | Network service dan agent network di controller                         |
| Cinder         | `cinder-scheduler`, `cinder-volume`                                                                                                | `cinder-api` berjalan lewat Apache WSGI                                 |
| Telemetry      | `gnocchi-metricd`, `ceilometer-agent-central`, `ceilometer-agent-notification`, `aodh-evaluator`, `aodh-notifier`, `aodh-listener` | Aktif jika `enable_telemetry: true`                                     |
| Instance HA    | `masakari-api`, `masakari-engine`                                                                                                  | Aktif jika `enable_masakari: true`                                      |

### Compute

| Layer          | Service systemd                                                             | Catatan                                                                                                            |
| -------------- | --------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| Virtualization | `libvirtd`                                                                  | Service libvirt yang dipakai role saat ini. Jika OS/paket berubah ke modular libvirt, cek apakah perlu `virtqemud` |
| Compute        | `nova-compute`                                                              | Nova compute worker                                                                                                |
| Network        | `openvswitch-switch`, `neutron-openvswitch-agent`                           | OVS bridge dan agent Neutron di compute                                                                            |
| Telemetry      | `ceilometer-agent-compute`                                                  | Aktif jika `enable_telemetry: true`                                                                                |
| Instance HA    | `corosync`, `pacemaker`, `masakari-hostmonitor`, `masakari-instancemonitor` | Aktif jika `enable_masakari: true`                                                                                 |

### API yang Berjalan via Apache WSGI

| Komponen      | Cara jalan | Catatan                                                    |
| ------------- | ---------- | ---------------------------------------------------------- |
| Keystone      | `apache2`  | Tidak dicek sebagai `keystone` service systemd             |
| Placement API | `apache2`  | Paketnya `placement-api`, runtime lewat Apache site        |
| Cinder API    | `apache2`  | Jangan masukkan `cinder-api` sebagai service systemd aktif |
| Gnocchi API   | `apache2`  | Service systemd yang dikelola adalah `gnocchi-metricd`     |
| Aodh API      | `apache2`  | Standalone `aodh-api` sengaja dihentikan/dinonaktifkan     |
| Horizon       | `apache2`  | Dashboard web OpenStack                                    |

> Catatan Masakari: role saat ini membuat unit custom `masakari-hostmonitor` dan `masakari-instancemonitor`. Di beberapa paket Ubuntu, nama bawaan service bisa muncul sebagai `masakari-host-monitor` dan `masakari-instance-monitor`. Samakan nama service di role dan `roles/validation/service_checks/defaults/main.yml` agar validasi tidak false-negative.

---

## Yang Wajib Disesuaikan Sebelum Dipakai di Lab/Cluster Lain atau Production

| Area                       | File utama                                                                      | Yang perlu disesuaikan                                                                                                                                                                     |
| -------------------------- | ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Jumlah host dan IP node    | `inventories/lab-5node/hosts.yml`                                               | Tambah/hapus host di grup `controllers` dan `computes`, ubah `ansible_host`, `expected_hostname`, `management_ip`, `storage_ip`, nama NIC, dan `keepalived_priority`.                      |
| Hostname dan resolusi nama | `inventories/lab-5node/group_vars/all.yml`                                      | Update `hosts_entries` agar semua node dan VIP bisa resolve konsisten dari semua host.                                                                                                     |
| VIP dan FQDN API           | `group_vars/all.yml`, `group_vars/openstack.yml`                                | Ubah `vip_internal`, `vip_interface`, `internal_fqdn`, `public_fqdn`, `endpoint_protocol`, dan `endpoint_host`. Production sebaiknya pakai FQDN valid dan TLS.                             |
| OS dan release OpenStack   | `group_vars/all.yml`, `playbooks/00-preflight.yml`                              | Baseline saat ini Ubuntu 22.04 + Caracal. Jika pakai OS/release lain, ubah `ubuntu_release`, `openstack_release`, `openstack_cloud_archive`, validasi preflight, dan cek ulang nama paket. |
| Network dan NIC            | `group_vars/network.yml`, `hosts.yml`                                           | Ubah subnet management/storage/provider, gateway, DNS, `management_iface`, `provider_iface`, `storage_iface`, `br-ex`, `physnet`, VXLAN range, dan allocation pool floating IP.            |
| External Ceph              | `group_vars/ceph.yml`, `files/ceph/*`                                           | Ubah MON host, FSID, public network, pool RBD, user/keyring Glance/Cinder/Nova/Gnocchi, dan caps Ceph. Jangan pakai keyring lab untuk production.                                          |
| Secret dan password        | `group_vars/vault.yml`, `.vault_pass`                                           | Generate ulang semua password service, DB, RabbitMQ, metadata secret, dan UUID secret RBD. Untuk production, jangan commit `.vault_pass`, vault, atau keyring asli ke repo.                |
| Controller quorum          | `hosts.yml`, `all.yml`                                                          | Controller production minimal 3 dan ganjil. Preflight saat ini memang menolak controller kurang dari 3 atau jumlah genap.                                                                  |
| Neutron HA agent           | `group_vars/network.yml`                                                        | Sesuaikan `neutron_max_l3_agents_per_router`, `neutron_min_l3_agents_per_router`, dan `neutron_dhcp_agents_per_network` agar tidak melebihi jumlah controller/network node.                |
| Masakari compute HA        | `group_vars/openstack.yml`, role `openstack/masakari`                           | `masakari_corosync_two_node: true` cocok untuk 2 compute. Jika compute 3 atau lebih, set ke `false` dan siapkan quorum/fencing yang benar.                                                 |
| Fencing production         | `roles/openstack/masakari/templates/masakarimonitors.conf.j2`, `tasks/main.yml` | Lab saat ini men-disable IPMI check dan STONITH. Production wajib memakai fencing/STONITH yang valid, bukan `stonith-enabled=false`.                                                       |
| TLS dan public access      | HAProxy, endpoint vars                                                          | Baseline masih HTTP. Production sebaiknya terminasi TLS di HAProxy atau API endpoint sesuai standar internal.                                                                              |
| User Ansible               | `ansible.cfg`, `group_vars/all.yml`                                             | Baseline memakai `ansible_user: root`. Production biasanya memakai user non-root + sudo, SSH key, dan policy akses yang lebih ketat.                                                       |
| Validasi service           | `roles/validation/service_checks/defaults/main.yml`                             | Samakan daftar service dengan nama unit aktual di OS target, terutama Masakari monitor dan libvirt.                                                                                        |

---

## Jika Jumlah Host Berbeda

### Menambah controller

1. Tambahkan host baru di `inventories/lab-5node/hosts.yml` pada grup `controllers`.
2. Tambahkan `management_ip`, `storage_ip`, `expected_hostname`, dan nama NIC yang benar.
3. Tambahkan entry baru di `hosts_entries` pada `group_vars/all.yml`.
4. Beri `keepalived_priority` yang unik. Controller utama biasanya priority paling tinggi.
5. Cek ulang parameter Neutron HA agent di `group_vars/network.yml`.
6. Jalankan ulang preflight sebelum phase lain.

Controller HA sebaiknya tetap jumlah ganjil: 3, 5, 7, dan seterusnya.

### Mengurangi controller

Untuk production, jangan turunkan controller di bawah 3. Galera, RabbitMQ, dan HA control plane butuh quorum yang sehat. Kalau hanya untuk lab kecil, preflight perlu diubah, tetapi hasilnya bukan lagi baseline HA yang sama seperti repo ini.

### Menambah compute

1. Tambahkan host baru di grup `computes` pada `hosts.yml`.
2. Tambahkan IP dan interface yang sesuai.
3. Tambahkan entry hostname di `hosts_entries`.
4. Pastikan compute bisa mengakses Ceph public network dan provider network.
5. Jika Masakari aktif, host baru akan ikut didaftarkan ke segment HA oleh playbook.

### Jika Hanya 1 compute.?

OpenStack tetap bisa berjalan dengan 1 compute, tetapi Masakari host evacuation tidak punya target yang masuk akal. Untuk lab 1 compute, lebih baik set `enable_masakari: false` atau tambah compute kedua sebelum menguji instance HA.

---

## Catatan Production

Beberapa konfigurasi di repo ini sengaja dibuat menyesuaikan untuk lab. Untuk production, minimal lakukan hal berikut:

- Pakai FQDN yang valid untuk endpoint internal/public dan aktifkan TLS.
- Pisahkan secret lab dan production. Rotate semua password, metadata secret, dan RBD secret UUID.
- Gunakan NTP internal yang stabil, bukan hanya pool publik.
- Pastikan kapasitas Galera, RabbitMQ, Memcached, HAProxy, dan Ceph sesuai beban nyata.
- Aktifkan monitoring, backup database, backup konfigurasi, dan log shipping.
- Untuk Masakari production, gunakan fencing/STONITH yang benar. Jangan mengandalkan `stonith-enabled=false`.
- Review security group, provider network, dan floating IP allocation agar tidak bentrok dengan IP statis infrastruktur.

---

## Validasi Manual Singkat (Setelah Cluster Jalan)

```bash
# Dari deployer atau bootstrap controller
source /root/admin-openrc

openstack token issue
openstack service list
openstack endpoint list
openstack compute service list
openstack network agent list
openstack volume service list
```

Cek service systemd:

```bash
systemctl --no-pager --type=service --state=running | egrep 'keepalived|haproxy|mariadb|rabbitmq|memcached|apache2|glance|nova|neutron|cinder|gnocchi|ceilometer|aodh|masakari|pacemaker|corosync|openvswitch|libvirt'
```

Atau jalankan validator bawaan Script ini:

```bash
make validate
# atau
ansible-playbook -i inventories/lab-5node/hosts.yml playbooks/99-validate.yml
```

---

## Catatan Akhir

Repo ini cocok sebagai baseline belajar dan lab teknis untuk memahami komponen OpenStack satu per satu. Untuk production, jangan hanya mengganti IP lalu langsung jalan; review inventory, secret, Ceph, TLS, quorum, fencing, dan nama service systemd sesuai OS target terlebih dahulu.

## Horizon Dahsboard

![](files/019df241-5547-755d-911f-febd52fa26a7/image.png)
