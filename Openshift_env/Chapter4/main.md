Description	|Value
---|---
Application name	|expense-service
Source code location	|https://git.ocp4.example.com/developer/DO288-apps
Source code directory	|apps/builds-review/expense-service
Build strategy	|Docker
Application URL|	http://expense-service-builds-review.apps.ocp4.example.com
GitLab username|	developer
GitLab password	|d3v3lop3r


```
[student@workstation expense-service]$ oc new-app --name expense-service \
--strategy Docker \
--context-dir apps/builds-review/expense-service \
https://git.ocp4.example.com/developer/DO288-apps
--> Found container image 11c20bc (23 months old) ...
...output omitted...
--> Creating resources ...
    imagestream.image.openshift.io "ocpdev-ubi8-openjdk-17-base" created
    imagestream.image.openshift.io "expense-service" created
    buildconfig.build.openshift.io "expense-service" created
    deployment.apps "expense-service" created
    service "expense-service" created
--> Success
...output omitted...
```

1. `--strategy` là gì?

👉 `--strategy` = Build Strategy = Cách OpenShift dùng để xây dựng image container.

OpenShift có nhiều chiến lược build (build strategy):

| Strategy     | Mô tả                                                                                                                                     | Khi nào dùng                                               |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| **Source**   | OpenShift tự động build code (Java, NodeJS, Python...) bằng S2I (Source-to-Image). Nó tìm file như `pom.xml`, `package.json`... để build. | Khi bạn có **source code thuần** (không có Dockerfile).    |
| **Docker**   | OpenShift sử dụng **Dockerfile** có sẵn trong source để build image (gọi là Docker build strategy).                                       | Khi project **có Dockerfile** và bạn muốn kiểm soát build. |
| **Pipeline** | Dùng Tekton pipeline để build và deploy.                                                                                                  | Khi bạn muốn CI/CD nâng cao.                               |
| **Custom**   | Bạn tự định nghĩa image build riêng.                                                                                                      | Ít dùng trong DO288.                                       |


2. `--context-dir` là gì?

👉 `--context-dir `= Context Directory = Thư mục con chứa ứng dụng trong repository Git.

Nói cách khác, repo của bạn có nhiều thư mục, bạn chỉ build một phần con.

Ví dụ repo này:
```
DO288-apps/
└── apps/
    ├── builds-review/
    │   ├── expense-service/
    │   │   ├── Dockerfile
    │   │   └── src/...
    │   └── ...
    └── other-app/
```
Nếu bạn chỉ muốn build ứng dụng `expense-service`, bạn phải chỉ rõ đường dẫn bên trong repo:
```
--context-dir apps/builds-review/expense-service
```

➡️ Nghĩa là: “Trong repo này, thư mục cần build nằm ở `apps/builds-review/expense-service`”.

🧩 Kết hợp lại:
```
oc new-app --name expense-service \
  --strategy Docker \
  --context-dir apps/builds-review/expense-service \
  https://git.ocp4.example.com/developer/DO288-apps
```

Giải nghĩa:

- Tạo 1 ứng dụng tên expense-service.

- Dùng Docker strategy → đọc file Dockerfile để build image.

- Lấy code trong repo https://git.ocp4.example.com/developer/DO288-apps.

- Chỉ lấy thư mục con apps/builds-review/expense-service làm build context (nơi có Dockerfile và code).

✅ Sau khi chạy lệnh này, OpenShift sẽ:

- Tạo BuildConfig (theo strategy Docker).

- Tạo ImageStream cho ứng dụng.

- Tạo Deployment và Service (nếu phát hiện port trong Dockerfile).

- Tự động trigger build đầu tiên.

![alt text](image.png)





