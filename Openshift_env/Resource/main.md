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
lệnh hh` là một trong những lệnh quan trọng nhất của Helm, đặc biệt khi bạn muốn xem nội dung YAML thực tế mà Helm sẽ apply lên Kubernetes — mà không thực sự cài đặt (deploy) gì cả.

| Thành phần                    | Giải thích ngắn gọn                                                          |
| ----------------------------- | ---------------------------------------------------------------------------- |
| **Lệnh**                      | `helm template`                                                              |
| **Chức năng chính**           | Render (biên dịch) các file **Helm chart** thành **manifest YAML thuần túy** |
| **Không áp dụng lên cluster** | ✅ Chỉ tạo file YAML, không gọi `kubectl apply`                               |
| **Mục đích**                  | Kiểm tra, debug, hoặc xuất YAML để review trước khi deploy                   |

Cú pháp cơ bản
```
helm template [RELEASE_NAME] [CHART_PATH] [flags]
```
Các tùy chọn phổ biến của helm template

| **Tùy chọn (Option)**    | **Mô tả / Chức năng**                                           | **Ví dụ minh họa**                                              |
| ------------------------ | --------------------------------------------------------------- | --------------------------------------------------------------- |
| `-f, --values <file>`    | Chỉ định file chứa giá trị (thay cho `values.yaml`)             | `helm template myapp ./chart -f custom-values.yaml`             |
| `--set key=value`        | Ghi đè giá trị trực tiếp trên dòng lệnh                         | `helm template myapp ./chart --set image.tag=v2`                |
| `--set-file key=path`    | Ghi đè giá trị bằng nội dung từ file                            | `helm template myapp ./chart --set-file config=app.conf`        |
| `--set-string key=value` | Ép kiểu giá trị thành chuỗi (ngăn Helm hiểu nhầm kiểu dữ liệu)  | `helm template myapp ./chart --set-string version=01`           |
| `--output-dir <dir>`     | Lưu YAML được render vào thư mục chỉ định (chia theo resource)  | `helm template myapp ./chart --output-dir ./rendered`           |
| `--namespace <ns>`       | Chỉ định namespace cho manifest được tạo ra                     | `helm template myapp ./chart --namespace test-ns`               |
| `--show-only <file>`     | Chỉ render một template cụ thể trong chart                      | `helm template myapp ./chart --show-only templates/deploy.yaml` |
| `--api-versions <list>`  | Cung cấp thêm API version khi render (hữu ích khi kiểm tra CRD) | `helm template myapp ./chart --api-versions=apps/v1`            |
| `--include-crds`         | Bao gồm cả **CRDs** (CustomResourceDefinition) trong kết quả    | `helm template myapp ./chart --include-crds`                    |
| `--release-name`         | Buộc Helm sử dụng tên release trong manifest                    | `helm template myapp ./chart --release-name`                    |
| `--version <ver>`        | Chọn phiên bản chart cụ thể (khi dùng chart từ repo)            | `helm template myapp bitnami/nginx --version 15.1.0`            |
| `--debug`                | Hiển thị thêm thông tin debug khi render                        | `helm template myapp ./chart --debug`                           |
| `--kube-version <ver>`   | Giả lập phiên bản Kubernetes cụ thể (để kiểm thử)               | `helm template myapp ./chart --kube-version 1.29`               |
| `--validate`             | Kiểm tra manifest với API của Kubernetes (nếu có cluster)       | `helm template myapp ./chart --validate`                        |

Dưới đây là bảng so sánh ngắn gọn giữa helm install và helm upgrade 👇

| Lệnh | Mục đích  | Khi nào dùng | Cú pháp cơ bản | Các option hay dùng | Ghi chú |
| ------------------ | ---------------------------------------------------------- | ---------------------------------------------------- | --------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------- |
| **`helm install`** | Cài đặt **chart mới** vào Kubernetes (tạo một release mới) | Khi **chưa có release** nào với tên đó               | `helm install <release_name> <chart> [flags]` | `--values` / `-f`: chỉ định file values<br>`--set`: ghi đè giá trị trực tiếp<br>`--namespace`: chọn namespace<br>`--create-namespace`: tự tạo namespace nếu chưa có<br>`--dry-run`: kiểm tra trước khi cài                                                             | Nếu tên release đã tồn tại → lỗi             |
| **`helm upgrade`** | **Cập nhật** một release đã có bằng chart hoặc values mới  | Khi **đã cài đặt release** trước đó và muốn cập nhật | `helm upgrade <release_name> <chart> [flags]` | `--install`: nếu release chưa có thì tự động cài (kết hợp install + upgrade)<br>`--values` / `-f`: file values mới<br>`--set`: ghi đè giá trị<br>`--reuse-values`: giữ nguyên giá trị cũ, chỉ thay đổi phần được cập nhật<br>`--force`: ép xóa và cài lại các resource | Dùng để nâng cấp version hoặc cấu hình chart |


👉 Tóm tắt dễ nhớ:

- helm install: tạo mới
- helm upgrade: cập nhật cái đã có
- helm upgrade --install: tự động “cài nếu chưa có, cập nhật nếu đã có”

---















