# Testing HA Masakari

```
openstack server list
openstack server show vm-test-1 | grep hypervisor_hostname
```

![](files/019dfcd6-8989-707a-aa29-91636a435aa3/image.png)

Tambah Metadata HA_Enabled=True

```
openstack server set --property HA_Enabled=True vm-test-1
```

```
openstack server show vm-test-1 -c properties
```

![](files/019dfcd8-f609-7489-8151-6b3293809fa3/image.png)

Paksa host failure Compte-01

```
ssh compute-01 "poweroff"
```

```
watch -n 5 "openstack notification list; openstack compute service list; openstack server show vm-test-1 -c status -c OS-EXT-STS:power_state -c OS-EXT-S
RV-ATTR:host -c OS-EXT-SRV-ATTR:hypervisor_hostname"
```

![](files/019dfcfe-c3af-751c-bb94-cb248d435cd5/image.png)