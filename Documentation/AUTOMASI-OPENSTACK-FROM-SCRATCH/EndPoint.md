# EndPoint

```
root@Deployer:~# openstack endpoint list
openstack service list
openstack catalog list
+----------------------------------+-----------+--------------+--------------+---------+-----------+--------------------------------------------+
| ID                               | Region    | Service Name | Service Type | Enabled | Interface | URL                                        |
+----------------------------------+-----------+--------------+--------------+---------+-----------+--------------------------------------------+
| 0004118e852e48bfa9fbbf039a9e3b88 | RegionOne | cinder       | volumev3     | True    | admin     | http://172.16.2.200:8776/v3/%(project_id)s |
| 0774dbc99e36423b9abe6d8faa618244 | RegionOne | keystone     | identity     | True    | public    | http://openstack-api.internal:5000/v3      |
| 07b8913804b34cbbba2829ac9efd7696 | RegionOne | gnocchi      | metric       | True    | public    | http://172.16.2.200:8041                   |
| 07f58fb4d7144062847d4a3a01e03dd5 | RegionOne | nova         | compute      | True    | public    | http://openstack-api.internal:8774/v2.1    |
| 0c45933bb50c4175a2e157464f8acaed | RegionOne | masakari     | instance-ha  | True    | admin     | http://172.16.2.200:15868/v1/%(tenant_id)s |
| 195e7b8f20a943a0adea628f35767e3c | RegionOne | gnocchi      | metric       | True    | admin     | http://172.16.2.200:8041                   |
| 1c31853e3c7144d5a3915a575c0a1c5b | RegionOne | masakari     | instance-ha  | True    | internal  | http://172.16.2.200:15868/v1/%(tenant_id)s |
| 1f4bfd93d0fb446f873aa0ea085c8395 | RegionOne | cinder       | volumev3     | True    | public    | http://172.16.2.200:8776/v3/%(project_id)s |
| 2a76c71d3a8148e280d83e11cc5ee739 | RegionOne | gnocchi      | metric       | True    | internal  | http://172.16.2.200:8041                   |
| 33ab8833697f4743840fb0e9e340b926 | RegionOne | neutron      | network      | True    | internal  | http://172.16.2.200:9696                   |
| 38e760ec60f84e73ae45e40b7b72cfb1 | RegionOne | neutron      | network      | True    | admin     | http://172.16.2.200:9696                   |
| 3df97b2984cc4ae2ac1b6135147f2b24 | RegionOne | aodh         | alarming     | True    | internal  | http://172.16.2.200:8042                   |
| 466719829cc04552aec463efcdb1bce1 | RegionOne | cinder       | volumev3     | True    | internal  | http://172.16.2.200:8776/v3/%(project_id)s |
| 47e5c01b4ca747529339b07fc3b89af6 | RegionOne | glance       | image        | True    | admin     | http://openstack-api.internal:9292         |
| 49a1d9d73cb24e289e5f459642dcd128 | RegionOne | masakari     | instance-ha  | True    | public    | http://172.16.2.200:15868/v1/%(tenant_id)s |
| 67ae333563e34bb586e3bc30afd39519 | RegionOne | placement    | placement    | True    | public    | http://openstack-api.internal:8778         |
| 7e6db99777914bff9f5d3e24d38a3b8c | RegionOne | glance       | image        | True    | internal  | http://openstack-api.internal:9292         |
| 854181d9678340e2a92db54a18c34f6b | RegionOne | placement    | placement    | True    | internal  | http://openstack-api.internal:8778         |
| 8cba254a221a471d9b90d442d0e3e9f8 | RegionOne | nova         | compute      | True    | admin     | http://openstack-api.internal:8774/v2.1    |
| 9a5fac814a014ad3bdaeb39879efc747 | RegionOne | aodh         | alarming     | True    | admin     | http://172.16.2.200:8042                   |
| 9ad168c0387942fe9cf018ce6f7ba760 | RegionOne | aodh         | alarming     | True    | public    | http://172.16.2.200:8042                   |
| a1f3b880d53a49bea3a6b6848a175d26 | RegionOne | keystone     | identity     | True    | internal  | http://openstack-api.internal:5000/v3      |
| a9a64b90dc9c43f599cbbcfcac54874f | RegionOne | keystone     | identity     | True    | admin     | http://openstack-api.internal:5000/v3      |
| c494fd544bba4083b00941b10caf4367 | RegionOne | neutron      | network      | True    | public    | http://172.16.2.200:9696                   |
| cd29806f90a14894948ddfeac590e0c3 | RegionOne | glance       | image        | True    | public    | http://openstack-api.internal:9292         |
| ebe74d0fd30e42c9b18907bb7c5a61d1 | RegionOne | placement    | placement    | True    | admin     | http://openstack-api.internal:8778         |
| ecd386d812454a35b3d60a7d58f46b66 | RegionOne | nova         | compute      | True    | internal  | http://openstack-api.internal:8774/v2.1    |
+----------------------------------+-----------+--------------+--------------+---------+-----------+--------------------------------------------+
+----------------------------------+-----------+-------------+
| ID                               | Name      | Type        |
+----------------------------------+-----------+-------------+
| 05ae0d4e70cf483b9e0840e19704705d | aodh      | alarming    |
| 2362d9c8784f4297a12b2ddae03e2649 | neutron   | network     |
| 284eb598a0c6402380a3d1c0ba2798cc | masakari  | instance-ha |
| 2bbbdad657c643e4947a9f557bd98765 | keystone  | identity    |
| 3c9697a2d2db4a54b32a94559f1202a1 | placement | placement   |
| 42fd95acb7d44db8920c1c4f1832b6cb | glance    | image       |
| 77ca14fd528b414ca1a17e0b9047e592 | nova      | compute     |
| c4b009ee52e34a34b8e4d20e077c0fd8 | cinder    | volumev3    |
| cbb9c7c19f784d71b3742e6897f14373 | gnocchi   | metric      |
+----------------------------------+-----------+-------------+
+-----------+-------------+---------------------------------------------------------------------------+
| Name      | Type        | Endpoints                                                                 |
+-----------+-------------+---------------------------------------------------------------------------+
| aodh      | alarming    | RegionOne                                                                 |
|           |             |   internal: http://172.16.2.200:8042                                      |
|           |             | RegionOne                                                                 |
|           |             |   admin: http://172.16.2.200:8042                                         |
|           |             | RegionOne                                                                 |
|           |             |   public: http://172.16.2.200:8042                                        |
|           |             |                                                                           |
| neutron   | network     | RegionOne                                                                 |
|           |             |   internal: http://172.16.2.200:9696                                      |
|           |             | RegionOne                                                                 |
|           |             |   admin: http://172.16.2.200:9696                                         |
|           |             | RegionOne                                                                 |
|           |             |   public: http://172.16.2.200:9696                                        |
|           |             |                                                                           |
| masakari  | instance-ha | RegionOne                                                                 |
|           |             |   admin: http://172.16.2.200:15868/v1/9783463e355d40369012e84cc9262c40    |
|           |             | RegionOne                                                                 |
|           |             |   internal: http://172.16.2.200:15868/v1/9783463e355d40369012e84cc9262c40 |
|           |             | RegionOne                                                                 |
|           |             |   public: http://172.16.2.200:15868/v1/9783463e355d40369012e84cc9262c40   |
|           |             |                                                                           |
| keystone  | identity    | RegionOne                                                                 |
|           |             |   public: http://openstack-api.internal:5000/v3                           |
|           |             | RegionOne                                                                 |
|           |             |   internal: http://openstack-api.internal:5000/v3                         |
|           |             | RegionOne                                                                 |
|           |             |   admin: http://openstack-api.internal:5000/v3                            |
|           |             |                                                                           |
| placement | placement   | RegionOne                                                                 |
|           |             |   public: http://openstack-api.internal:8778                              |
|           |             | RegionOne                                                                 |
|           |             |   internal: http://openstack-api.internal:8778                            |
|           |             | RegionOne                                                                 |
|           |             |   admin: http://openstack-api.internal:8778                               |
|           |             |                                                                           |
| glance    | image       | RegionOne                                                                 |
|           |             |   admin: http://openstack-api.internal:9292                               |
|           |             | RegionOne                                                                 |
|           |             |   internal: http://openstack-api.internal:9292                            |
|           |             | RegionOne                                                                 |
|           |             |   public: http://openstack-api.internal:9292                              |
|           |             |                                                                           |
| nova      | compute     | RegionOne                                                                 |
|           |             |   public: http://openstack-api.internal:8774/v2.1                         |
|           |             | RegionOne                                                                 |
|           |             |   admin: http://openstack-api.internal:8774/v2.1                          |
|           |             | RegionOne                                                                 |
|           |             |   internal: http://openstack-api.internal:8774/v2.1                       |
|           |             |                                                                           |
| cinder    | volumev3    | RegionOne                                                                 |
|           |             |   admin: http://172.16.2.200:8776/v3/9783463e355d40369012e84cc9262c40     |
|           |             | RegionOne                                                                 |
|           |             |   public: http://172.16.2.200:8776/v3/9783463e355d40369012e84cc9262c40    |
|           |             | RegionOne                                                                 |
|           |             |   internal: http://172.16.2.200:8776/v3/9783463e355d40369012e84cc9262c40  |
|           |             |                                                                           |
| gnocchi   | metric      | RegionOne                                                                 |
|           |             |   public: http://172.16.2.200:8041                                        |
|           |             | RegionOne                                                                 |
|           |             |   admin: http://172.16.2.200:8041                                         |
|           |             | RegionOne                                                                 |
|           |             |   internal: http://172.16.2.200:8041                                      |
|           |             |                                                                           |
+-----------+-------------+---------------------------------------------------------------------------+
root@Deployer:~#
```