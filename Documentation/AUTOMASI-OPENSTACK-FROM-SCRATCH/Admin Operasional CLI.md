# Admin Operasional CLI

## Create Image (Ubuntu 22.04 LTS)

```
# Download image
wget --show-progress https://cloud-images.ubuntu.com/jammy/20260320/jammy-server-cloudimg-amd64.img

# Create image
openstack image create "Ubuntu 22.04 LTS" \
  --file jammy-server-cloudimg-amd64.img \
  --disk-format qcow2 \
  --container-format bare \
  --public \
  --property description="jammy-server-cloudimg-amd64.img"
```

```
openstack image list
```

![](files/019dfc11-f460-70af-96ee-4c7b06ee2014/image.png)

## Create Flavor

Admin -> Compute -> Flavors -> Create Flavor.

```bash
 openstack flavor create --id 1001 --ram 1024 --disk 16 --vcpus 2 spek_low
```

![](files/019dfc19-4554-76af-bf4b-3beb9c692107/image.png)

## External + Internal Network + Router

### Membuat External/Provider Network

```bash
# Membuat external network yang dipetakan sesuai konfigurasi(cat inventories/lab-5node/group_vars/network.yml)
openstack network create --share --external \
  --provider-physical-network provider \
  --provider-network-type flat public

# Membuat subnet untuk external network (sesuaikan allocation-pool agar tidak bentrok dengan IP statis lain)
openstack subnet create --network public \
  --allocation-pool start=172.16.3.100,end=172.16.3.199 \
  --dns-nameserver 8.8.8.8 \
  --gateway 172.16.3.1 \
  --subnet-range 172.16.3.0/24 public-subnet
```

### Membuat Internal/Tenant Network

```bash
# Membuat internal network yang dipetakan sesuai konfigurasi(cat inventories/lab-5node/group_vars/network.yml)
openstack network create private

# Membuat subnet untuk internal network
openstack subnet create --network private \
  --dns-nameserver 8.8.8.8 \
  --gateway 10.10.0.1 \
  --subnet-range 10.10.0.0/24 private-subnet
```

![](files/019dfca9-72fc-73bb-9dcb-cad2a40221f2/image.png)

### Membuat Virtual Router dan Menghubungkan Jaringan

```bash
# Membuat router sesuai (cat inventories/lab-5node/group_vars/network.yml)
openstack router create tenant-router

# Mengatur gateway eksternal untuk router
openstack router set tenant-router --external-gateway public

# Menambahkan jaringan internal ke router
openstack router add subnet tenant-router private-subnet
```

![](files/019dfc2f-d0fc-7598-b042-5243bb2b1d28/image.png)

---

## Port Security

:::warning
Allow all inbound port
:::

```bash
# Membuat Security Group
openstack security group create --description "Allow all inbound and outbound traffic" open_secgroup

# Buka Semua Port & Protocol Masuk (Ingress)
openstack security group rule create --proto any --ethertype IPv4 --ingress --remote-ip 0.0.0.0/0 open_secgroup

openstack security group rule create --proto any --ethertype IPv6 --ingress --remote-ip ::/0 open_secgroup

# Buka Semua Port & Protocol Keluar (Egress)
openstack security group rule create --proto any --ethertype IPv4 --egress --remote-ip 0.0.0.0/0 open_secgroup

openstack security group rule create --proto any --ethertype IPv6 --egress --remote-ip ::/0 open_secgroup
```

verifikasi

```bash
openstack security group rule list open_secgroup
```

![](files/019dfc30-a963-7080-8fd2-c1450d7fa10b/image.png)

---

## Membuat Key Pairs (Kunci SSH)

```bash
openstack keypair create default-key > default-key.pem 
hmod 600 default-key.pem
```

![](files/019dfc32-12c1-707a-bcf5-68b7b393aeb7/image.png)

---

## Cloud Init (User-data)

```bash
nano user-data.yaml
```

```bash
#cloud-config
users:
  - default
  - name: xccvme
    groups: [sudo]
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false

ssh_pwauth: true
disable_root: false

chpasswd:
  expire: false
  users:
    - name: xccvme
      password: mypasswd
      type: text
    - name: root
      password: mypasswd
      type: text

write_files:
  - path: /etc/ssh/sshd_config.d/99-custom-password-auth.conf
    permissions: '0644'
    content: |
      PasswordAuthentication yes
      PermitRootLogin yes

runcmd:
  - systemctl restart ssh || systemctl restart sshd
```

---

## Create VM

```bash
openstack server create --image "Ubuntu 22.04 LTS" \
  --flavor spek_low \
  --network public \
  --security-group open_secgroup \
  --user-data user-data.yaml \
  vm-test-1
```

<details>
<summary>Create V2</summary>

:::warning
Gunakan jikak metadata (Cloud ini t by network tidak jalan)
:::

```bash
openstack server create --image "Ubuntu 22.04 LTS" \
  --flavor spek_low \
  --network private \
  --security-group open_secgroup \
  --key-name default-key \
  --user-data user-data.yaml \
  --config-drive true \
  vm-ubuntu-01
```

</details>

```bash
openstack server list
```

![](files/019dfcd3-6824-759e-8172-b3d71ac1b807/image.png)

### Remote SSH

```bash
ssh root@172.16.3.140

root:mypasswd
```

---

![](files/019dfcd2-ecd8-7474-a7a9-4d6f6fd53204/image.png)

---

### Alokasikan Floating IP Baru(jika vm ip-private)

```bash
openstack floating ip create public
```

Pasang Floating IP ke VM

```bash
openstack server add floating ip vm-test-1 <FLOATING_IP>
```

Verifikasi

```bash
openstack server list
```

![](files/019dfc15-7fe6-7313-8289-17a949c519a3/image.png)

---

### Remote SSH

```bash
ssh root@172.16.3.161

root:mypasswd
```