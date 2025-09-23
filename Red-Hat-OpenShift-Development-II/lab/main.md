![alt text](../pic/47.png)

# Chapter 1.  Red Hat OpenShift Container Platform for Developers

## Guided Exercise: Setting up the Developer Environment
Verify that the classroom image registry is accessible and log in by using Podman.
```bash
[student@workstation ~]$ podman login -u="developer" -p="ENCRYPTED_PASSWORD" \
registry.ocp4.example.com:8443
Login Succeeded!
```
Log in to the classroom cluster by using the oc CLI and the Red Hat OpenShift web console.
```bash
[student@workstation ~]$ oc login -u developer -p developer \
  https://api.ocp4.example.com:6443
Login successful.

...output omitted...
```
Change to the architecture-setup project.
```
[student@workstation ~]$ oc project architecture-setup
...output omitted...
```
To get the web console URL, run the `oc whoami` command with the `--show-console` option.
```
[student@workstation ~]$ oc whoami --show-console
https://console-openshift-console.apps.ocp4.example.com
```
