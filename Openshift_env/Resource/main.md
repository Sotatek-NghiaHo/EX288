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











