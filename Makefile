# Makefile
INV ?= inventories/lab-5node/hosts.yml
LIMIT ?= all

.PHONY: ping graph vars preflight base network ceph ha db msg core validate all vault-edit vault-view

ping:
	ansible -i $(INV) $(LIMIT) -m ping

graph:
	ansible-inventory -i $(INV) --graph

vars:
	ansible-inventory -i $(INV) --list

preflight:
	ansible-playbook -i $(INV) playbooks/00-preflight.yml

base:
	ansible-playbook -i $(INV) playbooks/01-base.yml

network:
	ansible-playbook -i $(INV) playbooks/02-network.yml

ceph:
	ansible-playbook -i $(INV) playbooks/03-ceph-client.yml

ha:
	ansible-playbook -i $(INV) playbooks/04-ha-vip-lb.yml

db:
	ansible-playbook -i $(INV) playbooks/05-database.yml

msg:
	ansible-playbook -i $(INV) playbooks/06-message-cache.yml

core:
	ansible-playbook -i $(INV) playbooks/07-keystone.yml
	ansible-playbook -i $(INV) playbooks/08-image-placement.yml
	ansible-playbook -i $(INV) playbooks/09-nova.yml
	ansible-playbook -i $(INV) playbooks/10-neutron.yml

validate:
	ansible-playbook -i $(INV) playbooks/99-validate.yml

all:
	ansible-playbook -i $(INV) site.yml

vault-edit:
	ansible-vault edit inventories/lab-5node/group_vars/vault.yml

vault-view:
	ansible-vault view inventories/lab-5node/group_vars/vault.yml

msgcache:
	ansible-playbook -i inventories/lab-5node/hosts.yml playbooks/06-message-cache.yml

keystone:
	ansible-playbook -i inventories/lab-5node/hosts.yml playbooks/07-keystone.yml
