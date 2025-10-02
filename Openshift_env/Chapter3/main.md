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
