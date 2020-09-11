# Foreman configuration by Ansible
This role provides a means to provision a Foreman or Satellite server with an organization and some content

This role requires Ansible Collection 'theforeman.foreman' in order to work!

## Satellite Offline installation
If you want to install Satellite via the Offline Installation ISO, make sure you have configured RHEL repo's from a Installation ISO as well.

## RHEL-based machines need extra setup!
When running this role on a RedHat system, after running 'satellite_install.yml', you need to make a change to your Ansible Inventory. This is due to the fact RedHat uses SCL for pip (which we need to get apypie), and that needs to be sourced before running any python commands.

NOTE: Please note that changing the Python interpreter might/will break other
ansible functionality!

A workaround for that might be to use a 'virtual name' in the inventory:

```
foreman-api ansible_host=rhel.example.com ansible_python_interpreter=/usr/local/bin/ansible_foreman_python
```

## Content Views (CV), Composite Content Views (COV) and publishing
When this role is used to create new content views and composites, the following strategy is applied:

* Content views are created with the same name as the product they contain
* Repositories that are newly created will be synchronized after creation (asynchronously)
* Composite content views that are newly created will be promoted to all lifecycle environments in the organization

The idea behind this is that COVs are the only things that are associated with clients. The Base CVs themselves are only present in the Library and should not be promoted to any other environment.

All created COVs have auto_publish enabled and sample playbooks to 'tag' a new version and publish it are provided.

## Host Discovery
For Host discovery, register the following records in DNS to allow the FDI to report to the correct server:

* For Foreman servers:
```
_x-foreman._tcp.dev.example.com 600 IN  SRV 0 5 443 foreman.dev.example.com
```

* For Foreman Smart Proxies:
```
_x-foreman._tcp.dev.example.com 600 IN  SRV 0 5 8443 fm-proxy.dev.example.com
```

## Bugs and workarounds
### Error creating OSes
Remove all the OSes from Hosts -> Operating systems (you can't delete the one where the foreman server is in)
