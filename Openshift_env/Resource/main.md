Sự khác nhau giữa `oc get` và `oc describe`

| Đặc điểm            | `oc get`                                                                 | `oc describe`                                                                                      |
| ------------------- | ------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- |
| **Mục đích chính**  | Hiển thị **danh sách** hoặc **tóm tắt thông tin** của tài nguyên         | Hiển thị **thông tin chi tiết** của **một** tài nguyên cụ thể                                      |
| **Độ chi tiết**     | Ngắn gọn, thường chỉ gồm tên, trạng thái, namespace, v.v.                | Rất chi tiết – gồm các sự kiện, điều kiện, image, label, annotation, selector, v.v.                |
| **Đầu ra (output)** | Có thể ở dạng **table**, **yaml**, **json**, **wide**, v.v.              | Luôn ở dạng **text chi tiết** (không thể xuất yaml/json)                                           |
| **Phạm vi dùng**    | Dùng để **liệt kê nhiều tài nguyên cùng loại** hoặc xem nhanh trạng thái | Dùng để **chẩn đoán lỗi**, xem nguyên nhân pod fail, xem sự kiện, chi tiết container, volume, v.v. |
| **Hiệu năng**       | Nhanh, nhẹ                                                               | Chậm hơn (do truy vấn nhiều thông tin hơn)                                                         |

2. Ví dụ minh họa  
🔹 Lấy danh sách pod  
`oc get pods`

Xem chi tiết một pod
```
oc describe pod api-6db489d4b7-abc34
```

> Dòng Events cuối cùng thường rất hữu ích khi debug lỗi.

3. Các tùy chọn (option) thường dùng  
🟩 oc get

| Option                       | Mô tả                                                           |
| ---------------------------- | --------------------------------------------------------------- |
| `-o wide`                    | Hiển thị thêm thông tin (ví dụ IP, node, container image, v.v.) |
| `-o yaml` / `-o json`        | Xuất chi tiết cấu hình tài nguyên dưới dạng YAML/JSON           |
| `-n <namespace>`             | Chỉ định namespace cần xem                                      |
| `--show-labels`              | Hiển thị label của tài nguyên                                   |
| `-w`                         | Theo dõi (watch) sự thay đổi theo thời gian thực                |
| `--sort-by=<field>`          | Sắp xếp theo trường (vd: `.metadata.name`)                      |
| `-A` hoặc `--all-namespaces` | Hiển thị tài nguyên ở tất cả namespaces                         |

--- 

# Set volume
Cú pháp tổng thể
```
oc set volume <resource>/<name> [options]
```


Lệnh oc set volume dùng để thêm, xóa hoặc cập nhật volume cho các tài nguyên như:

- Deployment
- DeploymentConfig
- DaemonSet
- StatefulSet
- ReplicationController


```
oc set volume deploy/postgresql \
--add --name=postgresql-data -t pvc \
--claim-name=postgres-pvc \
--mount-path /var/lib/pgsql/data
```


Gắn một PersistentVolumeClaim có tên `postgres-pvc` vào deployment `postgresql`, mount vào thư mục `/var/lib/pgsql/data` trong container, với tên volume là `postgresql-data`.

> Điều này giúp PostgreSQL lưu dữ liệu lâu dài, không bị mất khi pod bị xoá hoặc reschedule sang node khác.

Dưới đây là bảng giải thích ngắn gọn từng tham số trong lệnh:

| Thành phần                         | Ý nghĩa                                  | Ghi chú                       |
| ---------------------------------- | ---------------------------------------- | ----------------------------- |
| `deploy/postgresql`                | Chỉ định **Deployment** tên `postgresql` | Tài nguyên cần gắn volume     |
| `--add`                            | Thêm volume mới                          | Không ghi đè volume cũ        |
| `--name=postgresql-data`           | Tên volume trong pod                     | Dùng để tham chiếu nội bộ     |
| `-t pvc`                           | Kiểu volume là **PersistentVolumeClaim** | Lưu trữ dữ liệu bền vững      |
| `--claim-name=postgres-pvc`        | Tên PVC đã tạo trước đó                  | Liên kết đến PersistentVolume |
| `--mount-path /var/lib/pgsql/data` | Đường dẫn mount trong container          | Nơi PostgreSQL lưu dữ liệu    |


Một số tùy chọn khác của oc set volume

| Tham số                         | Mô tả                                      |
| ------------------------------- | ------------------------------------------ |
| `--remove --name=<volume-name>` | Xóa volume theo tên                        |
| `--list`                        | Liệt kê các volume hiện tại của deployment |
| `--overwrite`                   | Ghi đè nếu volume đã tồn tại               |
| `--configmap=<name>`            | Gắn volume từ ConfigMap                    |
| `--secret=<name>`               | Gắn volume từ Secret                       |
| `--mount-path <path>`           | Chỉ định vị trí mount trong container      |

----


| Mục đích                 | Lệnh                                                             | Ghi chú                       |
| ------------------------ | ---------------------------------------------------------------- | ----------------------------- |
| Liệt kê tất cả project   | `oc projects`                                                    | hoặc `oc get projects`        |
| Xem project hiện tại     | `oc project` *(không có tham số)*                                | In ra project đang dùng       |
| Chuyển sang project khác | `oc project <project_name>`                                      | Giống “cd” vào namespace khác |
| Tạo project mới          | `oc new-project <project_name>`                                  | Tạo và chuyển vào luôn        |
| Tạo project có mô tả     | `oc new-project <name> --display-name="..." --description="..."` | Thêm metadata                 |

---

🧩 Tổng quan: oc new-app làm gì?

oc new-app giúp bạn tạo một ứng dụng hoàn chỉnh (gồm Deployment, Service, BuildConfig, ImageStream, v.v.)
từ một nguồn mô tả ứng dụng như:

một container image có sẵn,

một source code repo,

một template,

hoặc ImageStream trong OpenShift.

🚀 1️⃣ Tạo app từ container image (kiểu bạn vừa làm)
Cú pháp:
```
oc new-app --name=<tên_app> <image_URL>
```

hoặc dạng chi tiết:
```
oc new-app --name=expense-service \
--image=registry.ocp4.example.com:8443/redhattraining/ocpdev-deployments-review:4.18
```
🔹 Ý nghĩa:

Dùng image đã build sẵn trong registry (nội bộ hoặc public).

Không cần build lại — OpenShift chỉ tạo Deployment + Service.

📦 Kết quả:

Deployment (chạy container từ image)

Service (nếu app lắng nghe trên cổng TCP)

🔹 Ví dụ khác:
oc new-app --name=myweb docker.io/library/nginx:latest

🧠 2️⃣ Tạo app từ source code (Git repo)
Cú pháp:
```
oc new-app <builder_image>~<source_repo>
```
🔹 Ví dụ:
```
oc new-app quay.io/redhattraining/python-39:latest~https://git.ocp4.example.com/developer/expense-service.git
```

→ OpenShift sẽ:

Clone repo Git.

Dùng image builder (python-39) để build source code (S2I build).

Tạo ImageStream + BuildConfig + Deployment + Service.

📦 Kết quả:

ImageStream

BuildConfig

Deployment

Service

⚙️ 3️⃣ Tạo app từ local source code (binary build)

Khi bạn muốn build code từ thư mục local thay vì Git repo.

Bước 1 — Tạo build config:
oc new-build python:3.9 --binary --name=expense-service

Bước 2 — Upload code local để build:
oc start-build expense-service --from-dir=./expense-service --follow

Bước 3 — Tạo app từ image sau khi build:
```
oc new-app expense-service
```
🧩 4️⃣ Tạo app từ template

Nếu có template YAML định nghĩa sẵn (Deployment, Service, Route, v.v.)

Cú pháp:
```
oc new-app --template=<namespace>/<template_name> -p <param>=<value>
```
🔹 Ví dụ:
```
oc new-app --template=openshift/postgresql-persistent \
  -p DATABASE_SERVICE_NAME=postgresql \
  -p POSTGRESQL_USER=user1 \
  -p POSTGRESQL_PASSWORD=pass1 \
  -p POSTGRESQL_DATABASE=mydb
```

→ OpenShift sẽ xử lý template (oc process) và tạo các tài nguyên tương ứng.

🧱 5️⃣ Tạo app từ ImageStream

Khi image đã có sẵn trong OpenShift registry nội bộ (không cần pull từ bên ngoài).

Cú pháp:
```
oc new-app <imagestream_name>[:tag]
```
🔹 Ví dụ:
```
oc new-app python:3.9~https://github.com/myorg/myapp.git
```

Hoặc nếu ImageStream đã có trong project:
```
oc new-app myapp:latest
```
🧠 6️⃣ Tạo app bằng Dockerfile trực tiếp (build từ repo có Dockerfile)

Nếu repo Git của bạn chứa Dockerfile, bạn có thể chỉ định:
```
oc new-app https://git.ocp4.example.com/developer/DO288-apps.git \
  --context-dir=apps/builds-review/expense-service \
  --strategy=Docker
```

→ OpenShift sẽ dùng Docker build strategy để tạo image.

🧾 7️⃣ Tạo app từ combination (multiple sources)

Bạn có thể kết hợp nhiều nguồn:
```
oc new-app myfrontend mybackend database
```

hoặc
```
oc new-app mysql-ephemeral php:7.4~https://github.com/myorg/php-app.git
```

OpenShift sẽ tự “nối” các service lại (liên kết DB ↔ app).

📘 Tổng kết dễ nhớ 

| Loại nguồn             | Cú pháp ví dụ                                  | Kết quả sinh ra                        | Khi nào dùng                      |
| ---------------------- | ---------------------------------------------- | -------------------------------------- | --------------------------------- |
| **Image**              | `oc new-app --image=docker.io/nginx`           | Deployment + Service                   | Có image sẵn                      |
| **Git source (S2I)**   | `oc new-app python:3.9~https://gitrepo`        | BuildConfig + ImageStream + Deployment | Có code, cần build                |
| **Local dir (binary)** | `oc new-build ... --binary` + `oc start-build` | Build từ local code                    | Không dùng Git                    |
| **Template**           | `oc new-app --template=<namespace>/<template>` | Tạo app theo mẫu                       | Khi có template có sẵn            |
| **ImageStream**        | `oc new-app myimage:latest`                    | Deployment + Service                   | Image đã có trong registry nội bộ |
| **Dockerfile**         | `oc new-app <git_repo> --strategy=Docker`      | Docker build                           | Repo có Dockerfile                |


💡 Tip hữu ích

Muốn xem OpenShift hiểu gì trước khi thực sự tạo app:
```
oc new-app ... --dry-run -o yaml
```

→ Hiển thị YAML mà nó sẽ apply, không tạo thật (rất hữu ích khi test).

👉 Tóm tắt ngắn gọn cuối cùng:

oc new-app có thể khởi tạo ứng dụng từ:
🧱 Image, 🧬 Source code, 🧾 Template, 🧰 ImageStream, hoặc 📦 Dockerfile.

Nó giúp bạn đi từ “nguồn” → ứng dụng chạy được trên cluster chỉ trong 1 lệnh.

---

| Mục đích               | Lệnh chính                        | Ghi nhớ                    |
| ---------------------- | --------------------------------- | -------------------------- |
| Mount PVC              | `oc set volume --type=pvc`        | Lưu trữ dữ liệu            |
| Mount Secret (file)    | `oc set volume --type=secret`     | Dữ liệu nhạy cảm dạng file |
| Mount ConfigMap (file) | `oc set volume --type=configmap`  | Cấu hình dạng file         |
| Env từ Secret          | `oc set env --from=secret/...`    | Biến môi trường bảo mật    |
| Env từ ConfigMap       | `oc set env --from=configmap/...` | Biến môi trường cấu hình   |
| Kiểm tra env           | `oc set env --list`               | Xem nhanh các env hiện có  |
| Xóa volume             | `oc set volume --remove`          | Gỡ volume đã gắn           |
| Xóa env                | `oc set env KEY-`                 | Gỡ biến cụ thể             |

✅ TỔNG HỢP GHI NHỚ NHANH

| Loại tài nguyên | Lệnh chính                             | Dùng khi                  |
| --------------- | -------------------------------------- | ------------------------- |
| ConfigMap       | `oc create configmap ...`              | Cấu hình app              |
| Secret          | `oc create secret generic ...`         | Dữ liệu nhạy cảm          |
| Secret Docker   | `oc create secret docker-registry ...` | Đăng nhập registry        |
| PVC             | `oc create pvc ...`                    | Lưu trữ dữ liệu           |
| App/Deployment  | `oc new-app ...`                       | Triển khai app nhanh      |
| Route           | `oc expose svc/...`                    | Public service            |
| Project         | `oc new-project ...`                   | Làm việc tách biệt        |
| File YAML       | `oc create -f ...`                     | Áp dụng manifest thủ công |


---
🧩 Câu hỏi: `--from-literal` là gì?

Cờ `--from-literal` (option này dùng trong các lệnh như oc create configmap hoặc oc create secret)
→ nghĩa là tạo key-value trực tiếp từ dòng lệnh, không cần file bên ngoài.

🔹 Cú pháp tổng quát
🔸 Tạo ConfigMap từ literal:
```
oc create configmap <tên_configmap> --from-literal=<key>=<value> [--from-literal=<key>=<value> ...]
```
🔸 Tạo Secret từ literal:
```
oc create secret generic <tên_secret> --from-literal=<key>=<value> [--from-literal=<key>=<value> ...]
```
🔹 Ví dụ minh họa 1: ConfigMap
```
oc create configmap app-config \
  --from-literal=APP_MODE=production \
  --from-literal=LOG_LEVEL=debug
```

✅ Kết quả:
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_MODE: production
  LOG_LEVEL: debug
```
🔹 Ví dụ minh họa 2: Secret
```
oc create secret generic postgresql \
  --from-literal=database-name=expenses \
  --from-literal=database-user=user1 \
  --from-literal=database-pass=pass123
```

✅ Kết quả (nội dung secret sẽ được base64 hóa):
```
apiVersion: v1
kind: Secret
metadata:
  name: postgresql
data:
  database-name: ZXhwZW5zZXM=      # base64("expenses")
  database-user: dXNlcjE=          # base64("user1")
  database-pass: cGFzczEyMw==      # base64("pass123")
```
🔹 So sánh: `--from-literal` vs `--from-file`

| Tùy chọn          | Nguồn dữ liệu                      | Ví dụ                           | Khi nào dùng               |
| ----------------- | ---------------------------------- | ------------------------------- | -------------------------- |
| `--from-literal`  | Tạo key=value trực tiếp trong lệnh | `--from-literal=APP_MODE=prod`  | Nhanh, gọn, dữ liệu ít     |
| `--from-file`     | Lấy nội dung file làm value        | `--from-file=config.properties` | Khi có file cấu hình thật  |
| `--from-env-file` | Lấy nhiều key=value từ file `.env` | `--from-env-file=.env`          | Khi có file môi trường sẵn |

🔹 Ví dụ kết hợp nhiều literal:
```
oc create configmap my-config \
  --from-literal=TIMEZONE=Asia/Ho_Chi_Minh \
  --from-literal=DEBUG=false \
  --from-literal=MAX_CONN=20
```

→ tạo 1 ConfigMap chứa 3 key.

🔹 Kiểm tra lại:
```
oc describe configmap my-config
# hoặc
oc get configmap my-config -o yaml
```
✅ Tóm lại:

| Lệnh                       | Mục đích                        | Ý nghĩa                     |
| -------------------------- | ------------------------------- | --------------------------- |
| `--from-literal=key=value` | Thêm key-value trực tiếp        | Nhanh, tiện, không cần file |
| `--from-file=file`         | Đọc nội dung file               | Mỗi file = 1 key            |
| `--from-env-file=.env`     | Nạp nhiều key-value từ file env | Dễ quản lý môi trường       |







