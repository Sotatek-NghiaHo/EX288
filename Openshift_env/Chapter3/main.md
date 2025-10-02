Application name	|custom-server
---|---
Image name	|custom-server:1.0.0
Image registry	|registry.ocp4.example.com:8443
Image registry namespace	|developer
Registry username	|developer
Registry password	|developer
Registry email	|developer@example.org
Registry secret name	|registry-credentials

Lệnh này bạn vừa chạy là để tạo một Secret dạng docker-registry, thường dùng để lưu thông tin đăng nhập vào một container registry (chẳng hạn như registry nội bộ của OpenShift hoặc registry bên ngoài như Quay.io, DockerHub,…).
Cụ thể, từng phần của lệnh này hoạt động như sau 👇

Cú pháp tổng quát:
```
oc create secret docker-registry <secret-name> \
  --docker-server=<registry-url> \
  --docker-username=<user> \
  --docker-password=<password> \
  --docker-email=<email>
```
🔍 Giải thích từng phần trong ví dụ của bạn:
```
oc create secret docker-registry \
registry-credentials \
--docker-server=registry.ocp4.example.com:8443 \
--docker-username=developer \
--docker-password=developer \
--docker-email=developer@example.org
```

| Thành phần                                       | Giải thích                                                                                                       |
| ------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------- |
| `oc create secret docker-registry`               | Tạo một secret **dạng đặc biệt** (`docker-registry`) chứa thông tin đăng nhập registry.                          |
| `registry-credentials`                           | Tên của secret (bạn sẽ dùng tên này khi gắn vào `ServiceAccount`, `BuildConfig`, hoặc `Deployment`).             |
| `--docker-server=registry.ocp4.example.com:8443` | URL của registry mà bạn muốn đăng nhập. Đây là **điểm endpoint** của internal registry (hoặc external registry). |
| `--docker-username=developer`                    | Tên user dùng để đăng nhập vào registry.                                                                         |
| `--docker-password=developer`                    | Mật khẩu tương ứng.                                                                                              |
| `--docker-email=developer@example.org`           | Email (không bắt buộc, thường để trống cũng được).                                                               |

-> Link the secret to the default service account.
```
[student@workstation images-review]$ oc secrets link default \
registry-credentials --for=pull
no output expected
```

---

Lệnh bạn đang dùng là để tạo một ImageStream (tên là custom-server) và import một image sẵn có từ registry vào OpenShift — điều này giúp OpenShift theo dõi và quản lý version của image thông qua ImageStream tag.

🧩 Mục đích

Tạo một ImageStream trong project hiện tại (namespace hiện hành), trỏ tới một image cụ thể trong registry (ở đây là registry.ocp4.example.com:8443/developer/custom-server:1.0.0).

ImageStream sẽ giúp bạn:

- Quản lý nhiều version (tag) của image.

- Tạo trigger build/deploy khi image cập nhật.

- Dễ dàng tham chiếu trong BuildConfig, DeploymentConfig, hoặc Pipeline.

✅ Cú pháp tổng quát:
```
oc import-image <imagestream-name> \
  --from=<registry>/<namespace>/<image-name>:<tag> \
  [--confirm] \
  [--scheduled=true]
```
🔍 Giải thích từng phần trong lệnh của bạn:
```
oc import-image custom-server --confirm \
--from registry.ocp4.example.com:8443/developer/custom-server:1.0.0
```

| Thành phần | Giải thích |
| --- | ---|
| `oc import-image` | Lệnh tạo mới hoặc cập nhật một **ImageStream**.  |
| `custom-server` | Tên của ImageStream sẽ được tạo ra trong project hiện tại.   |
| `--from registry.ocp4.example.com:8443/developer/custom-server:1.0.0` | Đường dẫn **đầy đủ** đến image trong registry (gồm server, namespace, tên image, và tag).                                    |
| `--confirm`                                                           | Bắt buộc OpenShift **tạo mới ImageStream** nếu chưa tồn tại (nếu không có flag này, lệnh chỉ hiển thị preview mà không tạo). |

_Kết quả sau khi chạy:_

Lệnh này sẽ:

- Tạo một ImageStream tên là custom-server

- Import image từ registry.ocp4.example.com:8443/developer/custom-server:1.0.0

- Gán tag 1.0.0 vào ImageStream

- Cho phép bạn deploy app bằng cách:
```
oc new-app custom-server:1.0.0
```
💡 Kiểm tra sau khi tạo:
```
oc get is
oc describe is custom-server
```

Bạn sẽ thấy output kiểu như:
```
Name: custom-server
Namespace: developer
Tags: 1.0.0
From: registry.ocp4.example.com:8443/developer/custom-server:1.0.0
```
📌 Một số tùy chọn khác:
Tham số	|Mô tả
---|---
--scheduled=true	|Cho phép OpenShift đồng bộ định kỳ image từ registry.
--reference-policy=local	|Giữ image trong internal registry thay vì reference trực tiếp.
--insecure=true	|Cho phép kết nối HTTP nếu registry không có TLS.

✅ Tóm tắt nhanh:

- `oc import-image` dùng để tạo ImageStream từ image đã có trong registry.
- `--confirm` giúp tạo mới nếu chưa có,
- `--from` xác định nguồn image để import.

**Create an OpenShift application by using the custom-server image stream.**

Deploy an application by using the image stream.
```
[student@workstation images-review]$ oc new-app --name custom-server \
-i images-review/custom-server
--> Found image ...
...output omitted...
--> Creating resources ...
    deployment.apps "custom-server" created
    service "custom-server" created
--> Success
...output omitted...
```
| Thành phần                       | Giải thích                                                                                                                                                                                                    |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `oc new-app`                     | Lệnh khởi tạo ứng dụng mới trong OpenShift.                                                                                                                                                                   |
| `--name custom-server`           | Đặt tên ứng dụng là `custom-server`. Tên này sẽ được dùng cho **DeploymentConfig**, **Service**, và các đối tượng liên quan.                                                                                  |
| `-i images-review/custom-server` | Dùng image (hoặc ImageStreamTag) làm nền tảng để deploy. Ở đây `images-review/custom-server` nghĩa là: <br>🔹 `images-review`: namespace chứa ImageStream <br>🔹 `custom-server`: tên ImageStream hoặc image. <br> Nếu bạn muốn chỉ rõ tag, có thể viết: `-i images-review/custom-server:1.0.0`|

Wait until the application pod is ready and running.
```
oc get all -l app=custom-server
oc logs deploy/custom-server
oc get pods

---
[student@workstation images-review]$ oc get pod
NAME                     READY   STATUS    RESTARTS   AGE
custom-server-7d597c89c4-lng8p   1/1     Running   0          30s
```

Cú pháp tổng quát:
```
oc new-app [<source> | -i <image-stream/image> | <template>] \
  [--name=<app-name>] \
  [--env KEY=VALUE] \
  [--build-env KEY=VALUE] \
  [--context-dir=<path>] \
  [--strategy=<source|docker|pipeline>] \
  [--allow-missing-imagestream-tags]
```
Một số ví dụ khác:

1️⃣ Tạo app từ Git repo (S2I)
```
oc new-app https://github.com/sclorg/nodejs-ex.git --name=node-app
```
2️⃣ Tạo app từ image bên ngoài registry
```
oc new-app --name=my-nginx \
  --docker-image=quay.io/bitnami/nginx:latest
```
3️⃣ Tạo app từ template
```
oc new-app --template=mysql-persistent
```
4️⃣ Truyền environment variable
```
oc new-app -i myimage --name=myapp \
  -e DB_USER=user -e DB_PASS=pass
```
| Tham số                    | Ý nghĩa                                          |
| -------------------------- | ------------------------------------------------ |
| `--name`                   | Tên ứng dụng (Deployment/Service)                |
| `-i` hoặc `--image-stream` | Triển khai từ ImageStream                        |
| `--docker-image`           | Triển khai từ image registry ngoài               |
| `--env`                    | Thiết lập biến môi trường                        |
| `--context-dir`            | Chỉ định sub-folder trong Git repo               |
| `--strategy`               | Chọn chiến lược build (source, docker, pipeline) |

---

# Bonus

```
oc import-image myapp --from=quay.io/myorg/myapp --confirm --all
```
Import (kéo) tất cả các tag có trong repository `quay.io/myorg/myapp` vào trong ImageStream `myapp` trong project hiện tại.

---
> is sẽ lấy tag đầu tiên khi oc describe is <is_name> đúng ko

Không.
ImageStream không tự động "lấy tag đầu tiên" làm mặc định.
Nó chỉ liệt kê tất cả các tag mà ImageStream đang quản lý (theo thứ tự thời gian import, không phải mặc định).
Còn bạn phải chỉ rõ tag (:latest, :1.0, …) khi sử dụng.

🧠 Giải thích chi tiết:
1️⃣ Khi bạn import hoặc tạo ImageStream, nó có thể có nhiều tag:
```
oc import-image myapp --from=quay.io/myorg/myapp --confirm --all
```

Khi đó, ImageStream myapp có thể có:
```
myapp:1.0
myapp:2.0
myapp:latest
```
2️⃣ Lệnh oc describe is myapp

Hiển thị thông tin:
```
Name:           myapp
Namespace:      developer
Created:        3 hours ago
Labels:         app=myapp
Annotations:    openshift.io/image.dockerRepositoryCheck=2025-10-02T04:50:00Z
Tags:
  1.0
    from: quay.io/myorg/myapp:1.0
    image: sha256:aaa111
  2.0
    from: quay.io/myorg/myapp:2.0
    image: sha256:bbb222
  latest
    from: quay.io/myorg/myapp:2.0
    image: sha256:bbb222
```

🔸 Mỗi Tag là một ImageStreamTag (IST)  
🔸 Không có “tag mặc định” nào — bạn phải chỉ rõ tag khi dùng.

3️⃣ Khi bạn tạo app:

Nếu bạn không chỉ rõ tag, OpenShift sẽ:

- Mặc định dùng tag :latest (nếu tag này tồn tại)

- Nếu latest không tồn tại → báo lỗi

Ví dụ:
```
oc new-app myapp
```

= tương đương với
```
oc new-app myapp:latest
```
---
## ImageStream giúp bạn chuyển đổi giữa các phiên bản image

Giả sử bạn đang deploy app `custom-server` dùng ImageStreamTag `custom-server:1.0`:
```
oc new-app custom-server:1.0
```

Nếu bạn sau này muốn nâng cấp app lên version mới, bạn chỉ cần import tag 2.0 và đổi deployment:
```
oc import-image custom-server:2.0 \
  --from=registry.ocp4.example.com:8443/developer/custom-server:2.0 \
  --confirm
```
➡️ Không deploy gì cả.  
➡️ Nó chỉ cập nhật ImageStreamTag custom-server:2.0 để trỏ đến image mới nhất của tag đó trong registry.
Nói nôm na: nó ghi lại metadata của image mới (digest SHA, label, timestamp, …).

Hoặc cập nhật trigger:
```
oc set triggers dc/custom-server --from-image=custom-server:2.0 --auto
```

👉 Khi ImageStreamTag 2.0 được cập nhật, DeploymentConfig custom-server sẽ tự động redeploy.

Nếu bạn dùng Deployment (kiểu Kubernetes thuần)

- Deployment không hỗ trợ imageChange trigger như DC.

- Muốn auto-redeploy, bạn cần Pipeline hoặc Operator theo dõi IS để cập nhật Deployment.

👉 Vì vậy trong môi trường OpenShift truyền thống (EX288), DeploymentConfig + ImageStream + trigger là combo chuẩn CI/CD auto update.

## WorkFlow
`ImageStream + DeploymentConfig + Trigger` trong OpenShift.
Mình sẽ hướng dẫn bạn từng bước, có YAML, lệnh, và giải thích rõ cơ chế nhé.

🧩 1️⃣ Bối cảnh

Bạn có image custom-server:1.0 trong registry nội bộ:
```
registry.ocp4.example.com:8443/developer/custom-server:1.0
```

Bạn muốn:

- Tạo một ImageStream theo dõi image này

- Triển khai app bằng DeploymentConfig

- Kích hoạt tự động redeploy khi lên version 2.0

🧩 2️⃣ Tạo ImageStream ban đầu (v1)
```
oc import-image custom-server:1.0 \
  --from=registry.ocp4.example.com:8443/developer/custom-server:1.0 \
  --confirm
```

🔹 Lệnh này tạo ImageStream custom-server với tag 1.0  
🔹 Metadata digest lưu trong IS, chưa có deploy gì cả

Kiểm tra:
```
oc get is
oc describe is custom-server
```
🧩 3️⃣ Tạo DeploymentConfig dùng IS custom-server:1.0  
✅ Cách 1: Dùng lệnh oc new-app
```
oc new-app custom-server:1.0 --name=custom-server
```

Tự động tạo:

- DeploymentConfig/custom-server

- Service/custom-server

- ImageStream (nếu chưa có)

⚠️ Nếu ImageStream custom-server:1.0 đã tồn tại → DC sẽ link trực tiếp.

✅ Cách 2: Viết YAML cho dễ hiểu (DC cơ bản có trigger)
```
apiVersion: apps.openshift.io/v1
kind: DeploymentConfig
metadata:
  name: custom-server
spec:
  replicas: 1
  selector:
    app: custom-server
  template:
    metadata:
      labels:
        app: custom-server
    spec:
      containers:
      - name: custom-server
        image: " "           # để trống vì OpenShift sẽ lấy từ ImageStream
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
  triggers:
  - type: ConfigChange
  - type: ImageChange
    imageChangeParams:
      automatic: true
      containerNames:
      - custom-server
      from:
        kind: ImageStreamTag
        name: "custom-server:1.0"
```

Áp dụng YAML:
```
oc apply -f dc-custom-server.yaml
```
🧩 4️⃣ Kiểm tra trigger
```
oc describe dc custom-server | grep -A5 Triggers
```

Kết quả:
```
Triggers:
  ConfigChange
  ImageChange
    ImageStreamTag custom-server:1.0
```

✅ Nghĩa là khi custom-server:1.0 đổi digest → DC sẽ redeploy tự động.

🧩 5️⃣ Deploy ban đầu

Khi DC được tạo, OpenShift sẽ tự rollout:
```
oc rollout status dc/custom-server
```
🧩 6️⃣ Bây giờ muốn lên version 2.0

Giả sử bạn build xong image mới `custom-server:2.0` và push vào registry:
```
registry.ocp4.example.com:8443/developer/custom-server:2.0
```
✅ Cách 1: Giữ nguyên tag 1.0 (CI/CD tự redeploy)

Nếu bạn muốn tự động redeploy mà không đổi tag, 
bạn push image mới đè tag cũ (1.0) lên registry   
→ Sau đó `oc import-image custom-server:1.0 --confirm`

➡️ ImageStreamTag custom-server:1.0 đổi digest  
➡️ Trigger ImageChange kích hoạt   
➡️ DC redeploy 🔁

✅ Cách 2: Dùng tag mới 2.0 (deploy version mới riêng biệt)

Import tag mới:
```
oc import-image custom-server:2.0 \
  --from=registry.ocp4.example.com:8443/developer/custom-server:2.0 \
  --confirm
```

Cập nhật trigger DC sang tag 2.0:
```
oc set triggers dc/custom-server --from-image=custom-server:2.0 --auto
```

Kiểm tra lại:
```
oc describe dc custom-server | grep custom-server
```

→ giờ DC theo dõi `custom-server:2.0`

Khi `oc import-image custom-server:2.0` đổi digest → DC auto redeploy

🧩 7️⃣ Kiểm tra rollout
oc rollout status dc/custom-server
oc get pods -w


Khi IS đổi digest → DC trigger → Pod mới xuất hiện.

✅ Tóm tắt logic CI/CD auto update:

| Bước | Hành động                                     | Kết quả             |
| ---- | --------------------------------------------- | ------------------- |
| 1    | `oc import-image custom-server:1.0 --confirm` | Tạo IS tag 1.0      |
| 2    | `oc new-app custom-server:1.0`                | DC theo dõi tag 1.0 |
| 3    | Push image mới (cùng tag 1.0)                 |                     |
| 4    | `oc import-image custom-server:1.0 --confirm` | IS đổi digest       |
| 5    | DC có trigger → auto redeploy                 | ✅ CI/CD             |

-> 

Rất hay 👏 — đúng rồi, ta cùng làm rõ oc new-app có tự tạo trigger hay không nhé, vì đây là một điểm rất quan trọng trong bài thi EX288.

🧠 Câu trả lời ngắn gọn:

✅ Có, lệnh oc new-app <ImageStreamTag> sẽ tự tạo DeploymentConfig có trigger loại ImageChange và ConfigChange.

🔍 Giải thích chi tiết

Khi bạn chạy:
```
oc new-app custom-server:1.0 --name=custom-server
```

OpenShift sẽ:

- Tạo DeploymentConfig (dc/custom-server)

- Gắn vào container trong DC nguồn image từ ImageStreamTag custom-server:1.0

- Tự động tạo hai trigger mặc định:
```
triggers:
  - type: ConfigChange
  - type: ImageChange
```
🧩 Cụ thể hơn:

- ConfigChange Trigger → Khi bạn thay đổi cấu hình trong DC (VD: env, replicas), OpenShift sẽ rollout lại.

- ImageChange Trigger → Khi ImageStreamTag (ví dụ custom-server:1.0) thay đổi digest, DC sẽ tự rollout pod mới.

🔎 Kiểm tra sau khi tạo

Bạn có thể xác nhận bằng:
```
oc describe dc custom-server | grep -A5 Triggers
```

Kết quả mẫu:
```
Triggers:
  ConfigChange
  ImageChange
    ImageStreamTag custom-server:1.0
```

→ Nghĩa là DC này đang lắng nghe tag custom-server:1.0
→ Khi oc import-image custom-server:1.0 --confirm cập nhật digest → DC auto redeploy.

---
1️⃣ Tổng quan: ImageStream không chứa image

ImageStream (IS) không thực sự chứa image, mà chỉ là metadata (thông tin tham chiếu) trỏ tới image trong một registry nào đó.

Mỗi tag trong IS (ví dụ custom-server:1.0) sẽ trỏ tới digest cụ thể trong registry nguồn.

🧩 2️⃣ Phân biệt Internal Registry vs External Registry
| Loại registry            | Đặc điểm                                                                        | Cách OpenShift truy cập                                                                                                                                           | Ghi chú                                                                               |
| ------------------------ | ------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| 🏠 **Internal Registry** | Là registry tích hợp sẵn trong cluster (quản lý bởi OpenShift)                  | Sử dụng `image-registry.openshift-image-registry.svc:5000/<namespace>/<image>` hoặc shortcut `image-registry.openshift-image-registry.svc:5000/project/image:tag` | Mặc định DC/BC/Pipeline **có quyền pull/push** (nếu cùng project hoặc được cấp quyền) |
| 🌍 **External Registry** | Là registry bên ngoài (Quay.io, Docker Hub, Harbor, Nexus, GitLab, ECR, GCR...) | Sử dụng URL cụ thể (`quay.io/org/image:tag`, `docker.io/user/image:tag`)                                                                                          | Phải tạo **secret kiểu docker-registry** để xác thực (nếu private)                    |

🧠 Vấn đề hay gặp khi dùng External Registry
❌ 1. Không import được image
oc import-image myapp:1.0 --from=quay.io/myorg/myapp:1.0 --confirm


Nếu registry yêu cầu login, bạn cần tạo secret:

oc create secret docker-registry registry-credentials \
  --docker-server=quay.io \
  --docker-username=<username> \
  --docker-password=<password> \
  --docker-email=<email>


Sau đó gắn secret vào ServiceAccount:

oc secrets link default registry-credentials --for=pull


Rồi mới oc import-image được.

❌ 2. Không auto trigger được

Nếu bạn deploy app từ external image trực tiếp (oc new-app quay.io/myorg/myapp:1.0)
→ Không có ImageStreamTag → DC không có ImageChange trigger
→ Không có tự động redeploy khi image thay đổi

🩵 Cách khắc phục: Import image đó về IS rồi dùng IS:

oc import-image myapp:1.0 --from=quay.io/myorg/myapp:1.0 --confirm
oc new-app myapp:1.0

❌ 3. Không pull được image (Pod lỗi ImagePullBackOff)

Nguyên nhân: Pod chạy trong namespace không có quyền pull từ external registry

Giải pháp:

Tạo secret docker-registry

Link secret vào SA default

oc secrets link default registry-credentials --for=pull

🏠 Với Internal Registry

✅ Ưu điểm:

Không cần auth nếu cùng project

Có thể trigger tự động

Có thể dùng ImageStreamTag để CI/CD dễ dàng

Có thể push trực tiếp từ BuildConfig, Pipeline, hoặc oc push

✅ Lỗi thường gặp:

Quên bật image registry (oc get pods -n openshift-image-registry)

Không expose registry ra ngoài nên không push được từ local

Quên gán quyền system:image-puller giữa project A → B nếu project B muốn dùng image của project A:

oc policy add-role-to-user system:image-puller system:serviceaccount:B:default -n A

🧩 3️⃣ Tóm tắt khi thi EX288
| Trường hợp                     | Cách tốt nhất                                        |
| ------------------------------ | ---------------------------------------------------- |
| Image từ **external registry** | Luôn `oc import-image` → tạo IS → `oc new-app` từ IS |
| Image từ **internal registry** | Dùng URL nội bộ hoặc IS có sẵn                       |
| Cần auto trigger CI/CD         | Phải dùng **ImageStreamTag** (IS + DC)               |
| Cần auth                       | Tạo secret kiểu `docker-registry` + link vào SA      |

✅ Tóm lại:

- IS có thể trỏ đến internal hoặc external registry

- Nếu external → cần secret

- Nếu internal → tự pull được trong project

- DC chỉ auto redeploy khi theo dõi ImageStreamTag (không phải image URL)

- oc import-image chỉ cập nhật metadata, không kéo image về cluster, mà để trigger DC

🏠 Bài 1: Dùng Internal Registry (có sẵn trong OpenShift)

🌍 Bài 2: Dùng External Registry (ví dụ Quay.io)

Mỗi bài mình hướng dẫn từng bước: import image → tạo IS → deploy → trigger → kiểm tra.

## 🏠 BÀI 1: INTERNAL REGISTRY (image-registry.openshift-image-registry.svc:5000)

🎯 Mục tiêu: Deploy app custom-server từ internal registry, auto redeploy khi image mới được push.

🔹 Bước 1: Push image vào Internal Registry

Giả sử bạn đã có image local custom-server:1.0
```
podman login -u developer -p $(oc whoami -t) \
  image-registry.openshift-image-registry.svc:5000
```

Tag và push:
```
podman tag custom-server:1.0 \
  image-registry.openshift-image-registry.svc:5000/developer/custom-server:1.0

podman push image-registry.openshift-image-registry.svc:5000/developer/custom-server:1.0
```

🔸 developer = namespace hiện tại  
🔸 Internal registry cho phép push khi bạn login bằng token (oc whoami -t)

🔹 Bước 2: Tạo ImageStream
```
oc import-image custom-server:1.0 \
  --from=image-registry.openshift-image-registry.svc:5000/developer/custom-server:1.0 \
  --confirm
```

Kiểm tra:
```
oc get is
oc describe is custom-server
```
🔹 Bước 3: Tạo ứng dụng từ ImageStreamTag
```
oc new-app custom-server:1.0 --name=custom-server
```
→ Tạo dc/custom-server có ImageChange trigger theo dõi custom-server:1.0.

🔹 Bước 4: Cập nhật image mới (CI/CD auto)

Giả sử bạn build version mới (1.0 mới digest khác):
```
podman build -t custom-server:1.0 .
podman push image-registry.openshift-image-registry.svc:5000/developer/custom-server:1.0
```

Import lại để cập nhật digest:
```
oc import-image custom-server:1.0 --confirm
```

📌 Khi digest thay đổi → DC auto redeploy (vì có trigger)

Kiểm tra:
```
oc rollout status dc/custom-server
oc get pods -w
```

✅ Pod mới sẽ được tạo tự động.

## 🌍 BÀI 2: EXTERNAL REGISTRY (ví dụ Quay.io)

🎯 Mục tiêu: Deploy app từ Quay.io, có auth, IS + trigger auto redeploy khi image update

🔹 Bước 1: Tạo Secret để pull từ Quay.io
```
oc create secret docker-registry quay-credentials \
  --docker-server=quay.io \
  --docker-username=myuser \
  --docker-password=mypassword \
  --docker-email=myuser@example.com
```

Gắn secret vào ServiceAccount default:
```
oc secrets link default quay-credentials --for=pull
```
🔹 Bước 2: Import image từ Quay.io vào ImageStream

Giả sử bạn có image quay.io/myorg/custom-server:1.0
```
oc import-image custom-server:1.0 \
  --from=quay.io/myorg/custom-server:1.0 \
  --confirm
```

Kiểm tra:
```
oc describe is custom-server
```
🔹 Bước 3: Tạo ứng dụng từ ImageStreamTag
```
oc new-app custom-server:1.0 --name=custom-server
```

→ DC có trigger từ custom-server:1.0

🔹 Bước 4: Khi có image mới (CI/CD)

Giả sử bạn build & push image mới (vẫn tag 1.0) lên Quay:
```
podman push quay.io/myorg/custom-server:1.0
```

Import lại để cập nhật digest:
```
oc import-image custom-server:1.0 --confirm
```

➡️ Digest đổi → DC auto redeploy

Kiểm tra rollout:
```
oc rollout status dc/custom-server
oc get pods -w
```
🔹 Bước 5 (Optional): Tự động import định kỳ

Nếu muốn OpenShift tự import mà không cần bạn chạy lệnh:
```
oc import-image custom-server \
  --from=quay.io/myorg/custom-server \
  --confirm --all --scheduled=true
```

📌 Khi Quay có image mới → IS cập nhật → DC trigger redeploy

🧭 Tóm tắt khác biệt
| Thành phần   | Internal Registry                                  | External Registry             |
| ------------ | -------------------------------------------------- | ----------------------------- |
| URL          | `image-registry.openshift-image-registry.svc:5000` | `quay.io/myorg/...`           |
| Auth         | Dùng token `oc whoami -t`                          | Tạo `docker-registry secret`  |
| Push         | Dễ (có quyền mặc định)                             | Cần login external            |
| Pull         | Tự động trong project                              | Cần secret                    |
| Auto trigger | Có (IS + DC)                                       | Có (nếu import-image dùng IS) |


> nói ngắn gọn là internal thì chỉ cần podman login, external thì cần tạo secret, sao external ko thể podman login ?

🏠 Internal registry

Là một phần của cluster OpenShift, được quản lý bởi OpenShift API

Bạn có thể podman login bằng token người dùng OpenShift:
```
podman login -u developer -p $(oc whoami -t) image-registry.openshift-image-registry.svc:5000
```

Vì registry nội bộ tin cậy OpenShift OAuth token, nên chỉ cần token của `oc whoami -t`  
✅ Dùng cho cả push (developer) và pull (pod)  
✅ Không cần secret nếu trong cùng project

🌍 External registry (VD: Quay.io, Docker Hub)

Là bên ngoài OpenShift → Không hiểu token OpenShift
```
podman login chỉ dùng trên máy local (để push image)
```
Pod trong cluster không dùng được login của bạn
→ OpenShift cần biết cách pull image khi Pod khởi động  
→ Giải pháp: tạo Secret kiểu docker-registry lưu credentials
```
oc create secret docker-registry quay-cred \
  --docker-server=quay.io \
  --docker-username=<user> \
  --docker-password=<pass> \
  --docker-email=<email>

oc secrets link default quay-cred --for=pull
```

✅ Secret này gắn với ServiceAccount, để Pod pull được image  
❌ podman login chỉ hiệu lực trên CLI local, không giúp Pod gì cả

🧠 Tóm tắt

| Registry | Cách xác thực                                          | Dùng cho                   | Ghi chú                         |
| -------- | ------------------------------------------------------ | -------------------------- | ------------------------------- |
| Internal | `podman login -u developer -p $(oc whoami -t)`         | Push/pull từ trong cluster | Token do OpenShift cấp          |
| External | `oc create secret docker-registry` + `oc secrets link` | Pod pull image             | Pod không dùng được login local |

➡️ Vì vậy:

- Internal: podman login = đủ
- External: podman login chỉ để push local, còn Pod thì phải có secret

🚀 Tình huống:

Bạn có 1 Pod (hay Deployment) cần chạy image từ registry bên ngoài (VD: quay.io/user/app:latest)

❌ Nếu bạn chỉ podman login trên máy local

- Lệnh này chỉ lưu credential trên máy bạn (file ~/.docker/config.json)

- Khi bạn oc apply -f deployment.yaml, Pod chạy trong cluster (không trên máy bạn)

→ Pod không biết bạn đã login ở local  
→ Kết quả: Pod pull image thất bại (ImagePullBackOff)

✅ Cách đúng trong OpenShift

Phải tạo 1 Secret để Pod dùng khi pull image từ registry ngoài.

---
```
apiVersion: image.openshift.io/v1
kind: ImageStream
metadata:
  name: nodejs  # (1)
spec: {}
status:
  dockerImageRepository: image-registry.openshift-image-registry.svc:5000/openshift/nodejs  # (2)
  publicDockerImageRepository: default-route-openshift-image-registry.apps.ocp4.example.com/openshift/nodejs  # (3)
  tags:
  - tag: 20-ubi8  # (4)
    items:
    - created: "2025-06-09T16:22:18Z"
      dockerImageReference: registry.ocp4.example.com:8443/ubi8/nodejs-20@sha256:f7e5...1577
  - tag: latest
    items:
    - created: "2025-06-09T16:22:18Z"
      dockerImageReference: registry.ocp4.example.com:8443/ubi9/nodejs-20@sha256:cdff...a9c8

```
Giải thích từng phần:  
🔹 (1) metadata.name

Đây là tên của ImageStream, ví dụ: nodejs

Trong 1 Project, tên IS là duy nhất

Bạn có thể deploy app bằng oc new-app nodejs:20-ubi8

👉 IS = đại diện logic của 1 image (và các version/tag của nó)

🔹 (2) dockerImageRepository

Là địa chỉ trong nội bộ cluster (internal registry)
```
image-registry.openshift-image-registry.svc:5000/openshift/nodejs
```

Pod bên trong cluster dùng địa chỉ này để pull image (rất nhanh, an toàn)

Không truy cập được từ bên ngoài (chỉ trong cluster)

🔹 (3) publicDockerImageRepository

Là địa chỉ public (external route) nếu cluster bật route cho registry
```
default-route-openshift-image-registry.apps.ocp4.example.com/openshift/nodejs
```

Bạn có thể push/pull từ bên ngoài cluster (VD: từ laptop) qua HTTPS

Cần `oc whoami -t + podman login` để xác thực

💡 Internal registry có thể có 2 endpoint:

Nội bộ cluster → dùng cho Pod

Route công khai → dùng cho dev push/pull bên ngoài

🔹 (4) tags

Là các phiên bản (tag) của ImageStream

Mỗi tag trỏ đến 1 dockerImageReference cụ thể (digest sha256)

Ví dụ:

- nodejs:20-ubi8 → registry.ocp4.example.com:8443/ubi8/nodejs-20@sha256:f7e5

- nodejs:latest → registry.ocp4.example.com:8443/ubi9/nodejs-20@sha256:cdff

🧩 Nghĩa là: 1 ImageStream có thể chứa nhiều tag
→ mỗi tag đại diện cho 1 phiên bản khác nhau của image

🧠 Tổng kết logic:

| Thành phần                    | Ý nghĩa                 | Dùng ở đâu                 |
| ----------------------------- | ----------------------- | -------------------------- |
| `metadata.name`               | Tên ImageStream         | `oc new-app nodejs:latest` |
| `dockerImageRepository`       | Địa chỉ nội bộ          | Pod trong cluster dùng     |
| `publicDockerImageRepository` | Địa chỉ public (route)  | Dev push/pull từ local     |
| `tags`                        | Danh sách version (tag) | Dùng để trigger deploy     |


✅ ImageStream có thể có cả internal và external endpoint  
→ Internal cho Pod  
→ External cho dev push/pull

✅ Mỗi tag trong IS là một phiên bản (available tag) → bạn chọn để deploy hoặc trigger CI/CD.

