# imagestream

```
[student@workstation images-review]$ oc import-image custom-server --confirm \
--from registry.ocp4.example.com:8443/developer/custom-server:1.0.0
```

```
[student@workstation images-review]$ oc new-app --name custom-server \
-i images-review/custom-server
```

---

# s2i containerfile

```
[student@workstation expense-service]$ oc new-app --name expense-service \
--strategy Docker \
--context-dir apps/builds-review/expense-service \
https://git.ocp4.example.com/developer/DO288-apps

[student@workstation expense-service]$ oc logs -f buildconfig/expense-service

```
- Repo DO288-apps chứa nhiều ứng dụng.

- Bạn chỉ muốn build ứng dụng expense-service nằm trong thư mục apps/builds-review/expense-service.

- Dockerfile nằm trong thư mục đó → dùng --strategy Docker

---
# image

```
[student@workstation ~]$ oc new-app --name=expense-service \
--image=\
registry.ocp4.example.com:8443/redhattraining/ocpdev-deployments-review:4.18
--> Found container image ...
...output omitted...
```






